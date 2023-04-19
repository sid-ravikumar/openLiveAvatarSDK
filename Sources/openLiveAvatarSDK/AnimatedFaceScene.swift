import SpriteKit
import ARKit

class AnimatedFaceScene: SKScene {
    // Set up face component nodes
    let leftEye = SKSpriteNode(imageNamed: "leftEye")
    let rightEye = SKSpriteNode(imageNamed: "rightEye")
    let mouth = SKSpriteNode(imageNamed: "mouth")
    
    let leftEyeScale = 0.05
    let rightEyeScale = 0.05
    let mouthScale = 0.2
    // Add other face components as needed

    override func didMove(to view: SKView) {
        // Set up face component nodes in the scene
        leftEye.position = CGPoint(x: 300, y: 600)
        rightEye.position = CGPoint(x: 100, y: 600)
        mouth.position = CGPoint(x: 200, y: 400)
        // Set up other face components
        
        leftEye.setScale(leftEyeScale)
        rightEye.setScale(rightEyeScale)
        mouth.setScale(mouthScale)

        addChild(leftEye)
        addChild(rightEye)
        addChild(mouth)
        // Add other face components to the scene
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
