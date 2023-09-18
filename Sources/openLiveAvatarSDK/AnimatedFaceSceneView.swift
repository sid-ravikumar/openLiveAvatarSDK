//
//  File.swift
//
//
//  Created by Yifu Yin on 5/23/23.
//

import Foundation
import ARKit

public class AnimatedFaceSceneView: GLKView, Avatar {
    
    @objc @IBInspectable public var id: String?
    private var timeofcurrent = Date().timeIntervalSince1970
    var faceScene: AnimatedFaceLive2D!
    public override init(frame: CGRect, context: EAGLContext) {
        print("frame init with context")
        super.init(frame: frame, context: context)
        self.context = setupView(id: nil).live2DView
    }
    
    public init(frame : CGRect, id: String?) {
        //self.skView = faceScene.animatedFaceScene
        print("frame +id init")
        super.init(frame: frame)
        self.context = setupView(id: id).live2DView
        self.id = id
    }
    
    public override init(frame: CGRect) {
        print("frame init")
        super.init(frame: frame)
        self.context = setupView(id: nil).live2DView
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        //super.init(frame: CGRect(
//            origin: CGPoint(x: 200, y: 0),
//            size: CGSize(width: 100, height: 100)
//        ))
        print("coder init")
        self.context = setupView(id: "main-3").live2DView
    }
    
    public func setupView(id: String?) -> AnimatedFaceLive2D {
        faceScene = AnimatedFaceLive2D()
        self.backgroundColor =  UIColor(white:1, alpha: 0)
        faceScene.SetupLive2DModel()
        self.delegate = faceScene
        return faceScene
    }
    
    public func addId(id : String) {
        self.id = id
    }
    
    public func addToUIWindow(view: UIView, frame: CGRect) -> UIView {
        view.addSubview(self)
        return self
    }
    
    public func update(avatarState: AvatarState) {
        // if id is set, check the id and only update when event emit_id is the same as the view id.
        if let idUnwrapped = id {
            if(avatarState.id == idUnwrapped){
                self.redraw(avatarState: avatarState)
            }
        } else {
            // if id is not set, just animate everytime.
            self.redraw(avatarState: avatarState)
        }
    }
    
    public func redraw(avatarState: AvatarState) {
        faceScene.updateFaceComponents(avatarState: avatarState)
        self.bindDrawable()
        self.display()
    }
    
    
    deinit {
        print("deinit AnimatedFaceSceneListenerWrapper")
    }
}
