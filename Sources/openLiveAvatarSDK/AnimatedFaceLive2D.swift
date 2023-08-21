//
//  File.swift
//  
//
//  Created by Yifu Yin on 8/6/23.
//

import Foundation
import GLKit
import SceneKit
import ObjcCubismSdk

public class AnimatedFaceLive2D: NSObject, GLKViewDelegate {
    public func glkView(_ view: GLKView, drawIn rect: CGRect) {
        // print("glkview updateL ", rect, debugid)
        moveIt(bound: rect)
    }
    
    /// live2D view behind
    var live2DView: EAGLContext!
    var live2DModel: Live2DModelOpenGL!
    
    var debugid: String!
    
    /// time stamp of the previous frame (in seconds)
    var timeStampOfPreviousFrame: TimeInterval = Date().timeIntervalSince1970
    private var timeofcurrent = Date().timeIntervalSince1970
    
    public init(id : String) {
        super.init()
        live2DView = EAGLContext(api: .openGLES2)
        if live2DView == nil {
            print("Failed to create ES context")
            return
        }
        debugid = id
    }
    
    public func SetupLive2DModel() {
        EAGLContext.setCurrent(live2DView)
        print("created new SetupLive2DModel", debugid)
        Live2DCubism.initL2D()
        print(Live2DCubism.live2DVersion() ?? "cannot get Live2DCubism.live2DVersion")
        
        guard let jsonPath = Bundle.module.path(forResource: "hiyori_pro_t10.model3", ofType: "json") else {
            print("Failed to find model json file")
            return
        }
        
        live2DModel = Live2DModelOpenGL(jsonPath: jsonPath)
        for index in 0 ..< live2DModel.getNumberOfTextures() {
            let fileName = live2DModel.getFileName(ofTexture: index)!
            let filePath = Bundle.module.path(forResource: fileName, ofType: nil)!
            let textureInfo = try! GLKTextureLoader.texture(withContentsOfFile: filePath, options: [GLKTextureLoaderApplyPremultiplication: false, GLKTextureLoaderGenerateMipmaps: true])

            let num = textureInfo.name
            live2DModel.setTexture(Int32(index), to: num)
        }
        live2DModel.setPremultipliedAlpha(false)
    }
    
    public func moveIt(bound : CGRect) {
        updateSizeAndPositionOfLive2DModel(bound: bound)
        
        let r = 0
        let g = 0
        let b = 0

        glClearColor(Float(r) / 255, Float(g) / 255, Float(b) / 255, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))

        // MARK: update frame

        // get time intercal to update physics (in seconds)
        let deltaTimeInterval = Date().timeIntervalSince1970 - timeStampOfPreviousFrame // The first frame may not be correct
//        print(deltaTimeInterval) // FIXME: why only 30 fps??? 0.033s AR render is 0.0166s
        live2DModel.updatePhysics(Float(deltaTimeInterval))
        timeStampOfPreviousFrame = Date().timeIntervalSince1970

        live2DModel.update()
        live2DModel.draw()
    }
    
    private func updateSizeAndPositionOfLive2DModel(bound : CGRect) {
        let size = UIScreen.main.bounds.size
        
        let zoom: Float = 2
        let x: Float = Float(bound.origin.x)
        let y: Float = Float(bound.origin.y  - 2.46)

        let scx: Float = (Float)(5.6 / live2DModel.getCanvasWidth()) * zoom
        let scy: Float = (Float)(5.6 / live2DModel.getCanvasWidth() * (Float)(size.width / size.height)) * zoom

        let matrix4 = SCNMatrix4(
            m11: scx, m12: 0, m13: 0, m14: 0,
            m21: 0, m22: scy, m23: 0, m24: 0,
            m31: 0, m32: 0, m33: 1, m34: 0,
            m41: x, m42: y, m43: 0, m44: 1
        )
        live2DModel.setMatrix(matrix4)
    }

    // Update face component animations based on blend shape coefficients
    func updateFaceComponents(avatarState : AvatarState) {
        // print("update face component", avatarState)
        let live2dModel = self.live2DModel!
        let newFaceMatrix = SCNMatrix4(avatarState.transform)
        let faceNode = SCNNode()
        faceNode.transform = newFaceMatrix

        live2dModel.setParam("ParamAngleY", value: faceNode.eulerAngles.x * -360 / Float.pi)
        live2dModel.setParam("ParamAngleX", value: faceNode.eulerAngles.y * 360 / Float.pi)
        live2dModel.setParam("ParamAngleZ", value: faceNode.eulerAngles.z * -360 / Float.pi)
//
        live2dModel.setParam("ParamBodyPosition", value: 10 + faceNode.position.z * 20)
        live2dModel.setParam("ParamBodyAngleZ", value: faceNode.position.x * 20)
        live2dModel.setParam("ParamBodyAngleY", value: faceNode.position.y * 20)
//
        live2dModel.setParam("ParamEyeBallX", value: avatarState.lookAtPoint.x * 2)
        live2dModel.setParam("ParamEyeBallY", value: avatarState.lookAtPoint.y * 2)

        live2dModel.setParam("ParamBrowLY", value: -(0.5 - avatarState.browOuterUpLeft))
        live2dModel.setParam("ParamBrowRY", value: -(0.5 - avatarState.browOuterUpRight))
        live2dModel.setParam("ParamBrowLAngle", value: 16 * (avatarState.browInnerUp - avatarState.browOuterUpLeft) - 1.6)
        live2dModel.setParam("ParamBrowRAngle", value: 16 * (avatarState.browInnerUp - avatarState.browOuterUpRight) - 1.6)

        live2dModel.setParam("ParamEyeLOpen", value: 1.0 - avatarState.eyeBlinkLeft)
        live2dModel.setParam("ParamEyeROpen", value: 1.0 - avatarState.eyeBlinkRight)

        live2dModel.setParam("ParamMouthOpenY", value: avatarState.jawOpen * 1.8)
        live2dModel.setParam("ParamMouthForm", value: 1 - avatarState.mouthFunnel * 2)

        live2dModel.setParam("ParamCheek", value: avatarState.cheekPuff)
//        live2dModel.setParam("ParamBreath", value: Float(cos(Double(i) * 3.0) + 1.0) / 2.0)
        live2dModel.setParam("ParamCheek", value: 0) // default value [-1.0, 1.0]
//        print(Date().timeIntervalSince1970 - timeofcurrent) // 0.0166s
        self.timeofcurrent = Date().timeIntervalSince1970
    }
    
    deinit {
        print("deinit")
        live2DModel = nil
        Live2DCubism.dispose()
        EAGLContext.setCurrent(live2DView)

        if EAGLContext.current() == self.live2DView {
            EAGLContext.setCurrent(nil)
        }
        self.live2DView = nil
    }
}
