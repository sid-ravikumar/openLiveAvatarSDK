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
        // print("glkview updateL ", view, debugid)
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
            // print(live2DModel)
            live2DModel.update()
            live2DModel.draw()
    }
    
    /// debug codes
    /// //
    //            var Vertices = [
    //              Vertex(x:  1, y: -1, z: 0, r: 1, g: 0, b: 0, a: 1),
    //              Vertex(x:  1, y:  1, z: 0, r: 0, g: 1, b: 0, a: 1),
    //              Vertex(x: -1, y:  1, z: 0, r: 0, g: 0, b: 1, a: 1),
    //              Vertex(x: -1, y: -1, z: 0, r: 0, g: 0, b: 0, a: 1),
    //            ]
    //
    //            var Indices: [GLubyte] = [
    //              0, 1, 2,
    //              2, 3, 0
    //            ]
    //
    //            // 1
    //            let vertexAttribColor = GLuint(GLKVertexAttrib.color.rawValue)
    //            // 2
    //            let vertexAttribPosition = GLuint(GLKVertexAttrib.position.rawValue)
    //            // 3
    //            let vertexSize = MemoryLayout<Vertex>.stride
    //            // 4
    //            let colorOffset = MemoryLayout<GLfloat>.stride * 3
    //            // 5
    //            let colorOffsetPointer = UnsafeRawPointer(bitPattern: colorOffset)
    //            glGenVertexArraysOES(1, &vao)
    //            glBindVertexArrayOES(vao)
    //
    //            glGenBuffers(1, &vbo)
    //            glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
    //            glBufferData(GLenum(GL_ARRAY_BUFFER), // 1
    //                         Vertices.size(),        // 2
    //                         Vertices,               // 3
    //                         GLenum(GL_STATIC_DRAW)) // 4
    //
    //            glEnableVertexAttribArray(vertexAttribPosition)
    //            glVertexAttribPointer(vertexAttribPosition,       // 1
    //                                  3,                          // 2
    //                                  GLenum(GL_FLOAT),           // 3
    //                                  GLboolean(UInt8(GL_FALSE)), // 4
    //                                  GLsizei(vertexSize),        // 5
    //                                  nil)                        // 6
    //
    //            glEnableVertexAttribArray(vertexAttribColor)
    //            glVertexAttribPointer(vertexAttribColor,
    //                                  4,
    //                                  GLenum(GL_FLOAT),
    //                                  GLboolean(UInt8(GL_FALSE)),
    //                                  GLsizei(vertexSize),
    //                                  colorOffsetPointer)
    //
    //            glGenBuffers(1, &ebo)
    //            glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), ebo)
    //            glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER),
    //                         Indices.size(),
    //                         Indices,
    //                         GLenum(GL_STATIC_DRAW))
    //
    //            glBindVertexArrayOES(0)
    //            glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    //            glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
    //
    //            effect.prepareToDraw()
    //
    //            // 1
    //            let aspect = 1
    //            // 2
    //            let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), Float(aspect), 4.0, 10.0)
    //            // 3
    //            effect.transform.projectionMatrix = projectionMatrix
    //
    //            // MARK: update frame
    //            // get time intercal to update physics (in seconds)
    //            let deltaTimeInterval = Date().timeIntervalSince1970 - timeStampOfPreviousFrame // The first frame may not be correct
    //
    //            // 1
    //            var modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -6.0)
    //            // 2
    //            rotation += 90 * 0.1
    //            modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(Float(rotation)), 0, 0, 1)
    //            // 3
    //            effect.transform.modelviewMatrix = modelViewMatrix
    //
    //
    //            glBindVertexArrayOES(vao);
    //            glDrawElements(GLenum(GL_TRIANGLES),     // 1
    //                           GLsizei(Indices.count),   // 2
    //                           GLenum(GL_UNSIGNED_BYTE), // 3
    //                           nil)                      // 4
    //            glBindVertexArrayOES(0)
    
    /// live2D view behind
    var live2DView: EAGLContext!
    var live2DModel: Live2DModelOpenGL!
    var eaglLayer:CAEAGLLayer!
    
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
        
        
        guard let jsonPath = Bundle.module.path(forResource: "hiyori_pro_t10.model3", ofType: "json") else {
            print("Failed to find model json file")
            return
        }
        
        live2DModel = Live2DModelOpenGL(jsonPath: jsonPath)
        print("live 2d model it is: ", live2DModel)
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

        live2dModel.setParam("ParamMouthOpenY", value: 0.3+avatarState.jawOpen * 2.8)
        live2dModel.setParam("ParamEyeLSmile", value: 0.1+avatarState.eyeSquintLeft * 2.8)
//        live2dModel.setParam("ParamMouthForm", value: 1 - avatarState.mouthFunnel * 2)
        
        live2dModel.setParam("ParamEyeRSmile", value: avatarState.eyeSquintRight)

        //live2dModel.setParam("ParamCheek", value: avatarState.cheekPuff)
//        live2dModel.setParam("ParamBreath", value: Float(cos(Double(i) * 3.0) + 1.0) / 2.0)
        //live2dModel.setParam("ParamCheek", value: 0) // default value [-1.0, 1.0]
//        print(Date().timeIntervalSince1970 - timeofcurrent) // 0.0166s
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
