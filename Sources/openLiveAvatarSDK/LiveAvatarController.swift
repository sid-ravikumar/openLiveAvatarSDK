import Foundation
import ARKit
import ObjcCubismSdk

public class LiveAvatarController: NSObject {
    private let synchronizer: AvatarStateSynchronizer
    private var avatars : [String: AnimatedFaceSceneView] = [:]
    private var faceCaptureView : FaceCaptureView!
    private var timeofcurrent = Date().timeIntervalSince1970
    
    public init(apiKey: String, channelName: String) {
        self.synchronizer = AvatarStateSynchronizer(apiKey: apiKey, channelName: channelName)
        super.init()
        
        print(Live2DCubism.live2DVersion() ?? "cannot get Live2DCubism.live2DVersion")
        
        print("Subscribed to the LiveAvatarController wiht all events")
        synchronizer.subscribeToStateUpdates(event:  "avatar-state-update") { [weak self] (result: Result<AvatarState, Error>) in
            
            switch result {
            case .success(let avatarState):
                
                print("received event result ", avatarState)
                self?.updateAvatars(with: avatarState)
            case .failure(let error):
                print("Failed to receive avatar state update:", error)
            }
        }
    }
    
    public func setupFaceCaptureViewAndAddToView(addFaceCaptureToView: UIView, emitId: String) {
        faceCaptureView = FaceCaptureView.init()
        faceCaptureView.addEmitFunctionAndId(emittingFunc: self.emittingFromFacesceneWrapperCallback, id: emitId)
        faceCaptureView.addToUIWindow(view: addFaceCaptureToView)
        faceCaptureView.startCapture()
    }
    
    public func faceCaptureAddEmit(faceCaptureToView: FaceCaptureView) {
        faceCaptureToView.addEmitFunction(emittingFunc: self.emittingFromFacesceneWrapperCallback)
    }
    
    public func faceCaptureAddEmitAndId(faceCaptureToView: FaceCaptureView, emit_id : String) {
        faceCaptureToView.addEmitFunctionAndId(emittingFunc: self.emittingFromFacesceneWrapperCallback, id: emit_id)
    }
    
    public func addLiveAvatarFromTargetId(frame: CGRect, addLiveAvatarToView:UIView, emitId: String) -> UIView {
        let wrapper = AnimatedFaceSceneView(frame: frame, id: emitId)
        self.addAvatar(avatar: wrapper)
        return wrapper.addToUIWindow(view: addLiveAvatarToView, frame: frame)
    }
    
    public func emittingFromFacesceneWrapperCallback( avatarState : AvatarState ){
//      print("emitting: " + avatarState.id)
        updateAvatars(with: avatarState)
//        do {
//            try synchronizer.publishStateUpdate(event: "avatar-state-update", data: avatarState)
//        } catch {
//            print(error)
//        }
    }
    
    public func addAvatar(avatar: AnimatedFaceSceneView) {
        if let avatar_id_unwrapped = avatar.id {
            avatars[avatar_id_unwrapped] = avatar
        } else {
            print("AnimatedFaceSceneView ID is unset!")
        }
    }

    public func removeAvatar(avatar: AnimatedFaceSceneView) {
        if let avatar_id_unwrapped = avatar.id {
            avatars.removeValue(forKey: avatar_id_unwrapped)
        } else {
            print("AnimatedFaceSceneView ID is unset!")
        }
    }

    private func updateAvatars(with state: AvatarState) {
        for (_, avatar) in avatars {
            avatar.update(avatarState: state)
        }
    }
}
