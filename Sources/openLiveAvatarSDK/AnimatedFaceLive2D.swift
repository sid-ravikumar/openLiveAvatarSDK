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

struct Vertex {
  var x: GLfloat
  var y: GLfloat
  var z: GLfloat
  var r: GLfloat
  var g: GLfloat
  var b: GLfloat
  var a: GLfloat
}

public class AnimatedFaceLive2D: NSObject, GLKViewDelegate {
    var ebo = GLuint()
    var vbo = GLuint()
    var vao = GLuint()
    private var effect = GLKBaseEffect()
    private var rotation = 90.0
    
    public func glkView(_ view: GLKView, drawIn rect: CGRect) {
            updateSizeAndPositionOfLive2DModel()
            let r = 200
            let g = 200
            let b = 200
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
    
    /// live2D view behind
    var live2DView: EAGLContext!
    var live2DModel: Live2DModelOpenGL!
    
    /// time stamp of the previous frame (in seconds)
    var timeStampOfPreviousFrame: TimeInterval = Date().timeIntervalSince1970
    private var timeofcurrent = Date().timeIntervalSince1970
    
    public override init() {
        super.init()
        Live2DCubism.initL2D()
        print("init AnimatedFaceLive2D")
        live2DView = EAGLContext(api: .openGLES2)
        if live2DView == nil {
            print("Failed to create ES context")
            return
        }
    }
    
    public func SetupLive2DModel() {
        EAGLContext.setCurrent(live2DView)
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
            print("texture it is: ", index, num)
            live2DModel.setTexture(Int32(index), to: num)
        }
        live2DModel.setPremultipliedAlpha(false)
    }
    
    private func updateSizeAndPositionOfLive2DModel() {
        let size = UIScreen.main.bounds.size
        
        let zoom: Float = 2
        let x: Float = Float(0)
        let y: Float = Float(0  - 2.46)

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
        print("angle x y, ", faceNode.eulerAngles.x, faceNode.eulerAngles.y)

        live2dModel.setParam("ParamAngleY", value: 5*(faceNode.eulerAngles.x-0.02) * -360 / Float.pi)
        live2dModel.setParam("ParamAngleX", value: 2.2*(faceNode.eulerAngles.y-0.1) * 360 / Float.pi)
        live2dModel.setParam("ParamAngleZ", value: 0.6*faceNode.eulerAngles.z * -360 / Float.pi)
//
        live2dModel.setParam("ParamBodyPosition", value: 10 + faceNode.position.z * 20)
        live2dModel.setParam("ParamBodyAngleZ", value: faceNode.position.x * 20)
        live2dModel.setParam("ParamBodyAngleY", value: faceNode.position.y * 20)
//
        live2dModel.setParam("ParamEyeBallX", value: avatarState.lookAtPoint.x * 2)
        live2dModel.setParam("ParamEyeBallY", value: avatarState.lookAtPoint.y * 2)

        live2dModel.setParam("ParamBrowLY", value: -(0.5 - avatarState.browOuterUpLeft))
        live2dModel.setParam("ParamBrowRY", value: -(0.5 - avatarState.browOuterUpRight))
        live2dModel.setParam("ParamBrowLAngle", value: 22 * (avatarState.browInnerUp - avatarState.browOuterUpLeft))
        live2dModel.setParam("ParamBrowRAngle", value: 22 * (avatarState.browInnerUp - avatarState.browOuterUpRight))

        live2dModel.setParam("ParamBrowLY", value: avatarState.browOuterUpLeft*5-1)
        live2dModel.setParam("ParamBrowRY", value:  avatarState.browOuterUpRight*5-1)
        
        live2dModel.setParam("ParamEyeLOpen", value: 1.0 - avatarState.eyeBlinkLeft)
        live2dModel.setParam("ParamEyeROpen", value: 1.0 - avatarState.eyeBlinkRight)
        
        live2dModel.setParam("ParamMouthOpenY", value: 0.05+avatarState.jawOpen * 3.5)
        live2dModel.setParam("ParamEyeLSmile", value: 0.1+avatarState.eyeSquintLeft * 2.8)
        
        live2dModel.setParam("ParamEyeRSmile", value: avatarState.eyeSquintRight)
        
//      live2dModel.setParam("ParamCheek", value: avatarState.cheekPuff)
//      live2dModel.setParam("ParamBreath", value: Float(cos(Double(i) * 3.0) + 1.0) / 2.0)
//      live2dModel.setParam("ParamCheek", value: 0) // default value [-1.0, 1.0]
//      print(Date().timeIntervalSince1970 - timeofcurrent) // 0.0166s
        self.timeofcurrent = Date().timeIntervalSince1970
    }
    
    deinit {
        print("deinit")
        glDeleteBuffers(1, &vao)
        glDeleteBuffers(1, &vbo)
        glDeleteBuffers(1, &ebo)
        
        live2DModel = nil
        Live2DCubism.dispose()
        EAGLContext.setCurrent(live2DView)

        if EAGLContext.current() == self.live2DView {
            EAGLContext.setCurrent(nil)
        }
        self.live2DView = nil
    }
}

extension Array {
  func size() -> Int {
    return MemoryLayout<Element>.stride * self.count
  }
}
