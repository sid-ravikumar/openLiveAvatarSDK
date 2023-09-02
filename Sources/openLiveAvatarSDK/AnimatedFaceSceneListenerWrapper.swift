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
    public var skView: GLKView!
    var faceScene: AnimatedFaceLive2D!
    
    public init(frame : CGRect, id: String) {
        self.id = id
        faceScene = AnimatedFaceLive2D(id: id)
        
        //self.skView = faceScene.animatedFaceScene
        super.init()
    }
    
    public func addToUIWindow(view: UIView, frame: CGRect) -> UIView {
        skView = GLKView(frame: frame, context: faceScene.live2DView)
        skView.backgroundColor =  UIColor(white:1, alpha: 0)
        faceScene.SetupLive2DModel()
        
        skView.delegate = faceScene
        print(view.addSubview(skView), skView)
        return skView
    }
    
    public func update(avatarState: AvatarState) {
       // if(avatarState.id == self.id){
        faceScene.updateFaceComponents(avatarState: avatarState)
        skView.bindDrawable()
        skView.display()
//        if(avatarState.id == "main-1"){
 //       skView.
//            skView.enableSetNeedsDisplay = true
//        }
        //skView.setNeedsDisplay()
       // }
    }
    
    deinit {
        print("deinit AnimatedFaceSceneListenerWrapper")
    }
}
