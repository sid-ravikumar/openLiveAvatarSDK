import SpriteKit
import ARKit

public class AnimatedFaceScene: NSObject {
    // Set up face component nodes
    public var animatedFaceScene = SKScene();
    var leftEye = SKSpriteNode(imageNamed: "leftEye")
    var rightEye = SKSpriteNode(imageNamed: "rightEye")
    var mouth = SKSpriteNode(imageNamed: "mouth")
    
    public init(leftEyeImage : String, rightEyeImage : String, mouthImage : String) {
        super.init()
        leftEye = SKSpriteNode(imageNamed: leftEyeImage)
        rightEye = SKSpriteNode(imageNamed: rightEyeImage)
        mouth = SKSpriteNode(imageNamed: mouthImage)
    }
    
    let leftEyeScale = 0.05
    let rightEyeScale = 0.05
    let mouthScale = 0.2
    // Add other face components as needed
    
    public func moveIt(bound : CGSize) {
        animatedFaceScene = SKScene(size: bound)
        leftEye.position = CGPoint(x: 300, y: 600)
        rightEye.position = CGPoint(x: 100, y: 600)
        mouth.position = CGPoint(x: 200, y: 400)
        
        leftEye.setScale(leftEyeScale)
        rightEye.setScale(rightEyeScale)
        mouth.setScale(mouthScale)
        animatedFaceScene.addChild(leftEye)
        animatedFaceScene.addChild(rightEye)
        animatedFaceScene.addChild(mouth)
    }

    // Update face component animations based on blend shape coefficients
    func updateFaceComponents(avatarState : AvatarState) {
        // Example: Update eye scale based on eye blink blend shape coefficients
        let leftEyeBlink = avatarState.eyeBlinkLeft   // {
        leftEye.yScale = leftEyeScale - Double(leftEyeBlink) * leftEyeScale
        //}
        
        let rightEyeBlink = avatarState.eyeBlinkRight // {
        rightEye.yScale = rightEyeScale - Double(rightEyeBlink) * rightEyeScale
        //}
        
        let mouthFunnel = avatarState.mouthFunnel     // {
        mouth.xScale = mouthScale - Double(mouthFunnel) * mouthScale
        //}
        
        let jawOpen = avatarState.jawOpen             // {
        print(jawOpen)
        mouth.yScale = Double(jawOpen) * mouthScale
//        }
//        if let cheekPuff = blendShapes[.cheekPuff]?.floatValue {
//            print(cheekPuff)
//        }
//        if let jawOpen = blendShapes[.jawOpen]?.floatValue {
//            rightEye.yScale = leftEyeScale - Double(jawOpen) * rightEyeScale
//        }
//        Update other face components based on blend shape coefficients
    }
}
