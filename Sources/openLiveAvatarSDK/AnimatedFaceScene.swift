import SpriteKit
import ARKit

public class AnimatedFaceScene: NSObject {
    // Set up face component nodes
    public var animatedFaceScene = SKScene();
    var leftEye = SKSpriteNode(imageNamed: "leftEye")
    var rightEye = SKSpriteNode(imageNamed: "rightEye")
    var mouth = SKSpriteNode(imageNamed: "mouth")
    var maxWidth = 400.0;
    var maxHeight = 700.0;
    
    public init(leftEyeImage : String, rightEyeImage : String, mouthImage : String) {
        super.init()
        leftEye = SKSpriteNode(imageNamed: leftEyeImage)
        rightEye = SKSpriteNode(imageNamed: rightEyeImage)
        mouth = SKSpriteNode(imageNamed: mouthImage)
    }
    
    let leftEyeScale = 0.05
    let rightEyeScale = 0.05
    let mouthScale = 0.2
    
    var leftEyeScaleCorrected = 0.0
    var rightEyeScaleCorrected = 0.0
    var mouthScaleCorrected = 0.0
    // Add other face components as needed
    
    public func moveIt(bound : CGSize) {
        let percentageWidth = bound.width / self.maxWidth;
        let percentageHeight = bound.height / self.maxHeight;
        animatedFaceScene = SKScene(size: bound)
        leftEye.position = CGPoint(x: 300*percentageWidth, y: 600*percentageHeight)
        rightEye.position = CGPoint(x: 100*percentageWidth, y: 600*percentageHeight)
        mouth.position = CGPoint(x: 200*percentageWidth, y: 400*percentageHeight)
        
        leftEyeScaleCorrected = leftEyeScale*percentageWidth
        rightEyeScaleCorrected = rightEyeScale*percentageWidth
        mouthScaleCorrected = mouthScale*percentageWidth
        
        leftEye.setScale(leftEyeScaleCorrected)
        rightEye.setScale(rightEyeScaleCorrected)
        mouth.setScale(mouthScaleCorrected)
        animatedFaceScene.addChild(leftEye)
        animatedFaceScene.addChild(rightEye)
        animatedFaceScene.addChild(mouth)
    }

    // Update face component animations based on blend shape coefficients
    func updateFaceComponents(avatarState : AvatarState) {
        // Example: Update eye scale based on eye blink blend shape coefficients
        let leftEyeBlink = avatarState.eyeBlinkLeft
        leftEye.yScale = leftEyeScaleCorrected - Double(leftEyeBlink) * leftEyeScaleCorrected
        
        let rightEyeBlink = avatarState.eyeBlinkRight
        rightEye.yScale = rightEyeScaleCorrected - Double(rightEyeBlink) * rightEyeScaleCorrected
        
        let mouthFunnel = avatarState.mouthFunnel
        mouth.xScale = mouthScaleCorrected - Double(mouthFunnel) * mouthScaleCorrected
        
        let jawOpen = avatarState.jawOpen
        print(jawOpen)
        mouth.yScale = Double(jawOpen) * mouthScaleCorrected
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
