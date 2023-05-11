import SpriteKit
import ARKit

public class AnimatedFaceScene: NSObject {
    // Set up face component nodes
    public var animatedFaceScene = SKScene();
    let leftEye = SKSpriteNode(imageNamed: "leftEye")
    let rightEye = SKSpriteNode(imageNamed: "rightEye")
    let mouth = SKSpriteNode(imageNamed: "mouth")
    
    let leftEyeScale = 0.05
    let rightEyeScale = 0.05
    let mouthScale = 0.2
    // Add other face components as needed
    
    public func moveIt(view : UIView) {
        animatedFaceScene = SKScene(size: view.bounds.size)
        leftEye.position = CGPoint(x: 300, y: 600)
        rightEye.position = CGPoint(x: 100, y: 600)
        mouth.position = CGPoint(x: 200, y: 400)
        // Set up other face components
        print("test1")
        
        leftEye.setScale(leftEyeScale)
        rightEye.setScale(rightEyeScale)
        mouth.setScale(mouthScale)
        animatedFaceScene.addChild(leftEye)
        animatedFaceScene.addChild(rightEye)
        animatedFaceScene.addChild(mouth)
    }

    // Update face component animations based on blend shape coefficients
    func updateFaceComponents(_ blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber]) {
        // Example: Update eye scale based on eye blink blend shape coefficients
        if let leftEyeBlink = blendShapes[.eyeBlinkLeft]?.floatValue {
            leftEye.yScale = leftEyeScale - Double(leftEyeBlink) * leftEyeScale
        }
        
        if let rightEyeBlink = blendShapes[.eyeBlinkRight]?.floatValue {
            rightEye.yScale = leftEyeScale - Double(rightEyeBlink) * rightEyeScale
        }
        
        if let mouthFunnel = blendShapes[.mouthFunnel]?.floatValue {
            mouth.xScale = mouthScale - Double(mouthFunnel) * mouthScale
        }
        
        if let jawOpen = blendShapes[.jawOpen]?.floatValue {
            print(jawOpen)
            mouth.yScale = Double(jawOpen) * mouthScale
        }
        
//        if let cheekPuff = blendShapes[.cheekPuff]?.floatValue {
//            print(cheekPuff)
//        }
        
//        if let jawOpen = blendShapes[.jawOpen]?.floatValue {
//            rightEye.yScale = leftEyeScale - Double(jawOpen) * rightEyeScale
//        }
        // Update other face components based on blend shape coefficients
    }
}
