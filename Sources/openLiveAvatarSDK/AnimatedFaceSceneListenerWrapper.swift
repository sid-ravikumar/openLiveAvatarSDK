//
//  File.swift
//
//
//  Created by Yifu Yin on 5/23/23.
//

import Foundation
import ARKit

public class AnimatedFaceSceneListenerWrapper: NSObject, Avatar {
    public var id: String
    private var timeofcurrent = Date().timeIntervalSince1970
    public var skView: SKView
    var faceScene: AnimatedFaceScene
    let floatingWindow = UIWindow(frame: UIScreen.main.bounds)
    
    public init(frame : CGRect, id: String) {
        self.id = id
        self.skView = SKView(frame: frame)
        faceScene = AnimatedFaceScene(leftEyeImage: "leftEye", rightEyeImage: "rightEye", mouthImage: "mouth")
        faceScene.moveIt(bound: frame.size)
        skView.ignoresSiblingOrder = true
        self.skView.presentScene(faceScene.animatedFaceScene)
        super.init()
    }
    
    public func addToUIWindow(view: UIView){
        view.addSubview(skView)
    }
    
    public func update(avatarState: AvatarState) {
        if(avatarState.id == self.id){
            faceScene.updateFaceComponents(avatarState: avatarState)
        }
    }
}
