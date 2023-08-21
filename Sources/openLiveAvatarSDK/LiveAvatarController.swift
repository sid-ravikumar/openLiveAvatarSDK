import Foundation
import ARKit

public class LiveAvatarController: NSObject {
    private let synchronizer: AvatarStateSynchronizer
    private var avatars: [String: Avatar] = [:]
    private var faceCaptureWrapper : FaceCaptureWrapper?
    private var timeofcurrent = Date().timeIntervalSince1970
    
    public init(apiKey: String, channelName: String) {
        self.synchronizer = AvatarStateSynchronizer(apiKey: apiKey, channelName: channelName)
        super.init()
        
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
    
    public func setupFaceCapture(addFaceCaptureToView: UIView, emitId: String) {
        faceCaptureWrapper = FaceCaptureWrapper.init()
        faceCaptureWrapper?.addEmitFunction(emittingFunc: self.emittingFromFacesceneWrapperCallback, id: emitId)
        faceCaptureWrapper?.addToUIWindow(view: addFaceCaptureToView)
        faceCaptureWrapper?.startCapture()
    }
    
    public func addLiveAvatarFromTargetId(frame: CGRect, addLiveAvatarToView:UIView, emitId: String) {
        let wrapper = AnimatedFaceSceneListenerWrapper(frame: frame, id: emitId)
        self.addAvatar(id: emitId, avatar: wrapper)
        wrapper.addToUIWindow(view: addLiveAvatarToView, frame: frame)
    }
    
    public func addLiveAvatarFromTargetId2(frame: CGRect, addLiveAvatarToView:UIView, emitId: String) {
        let wrapper = AnimatedFaceSceneListenerWrapper(frame: frame, id: emitId)
        self.addAvatar(id: emitId, avatar: wrapper)
        wrapper.addToUIWindow2(view: addLiveAvatarToView, frame: frame)
    }
    
    public func emittingFromFacesceneWrapperCallback( avatarState : AvatarState){
        //print("emitting: " + avatarState.id)
        updateAvatars(with: avatarState)
//        do {
//            try synchronizer.publishStateUpdate(event: "avatar-state-update", data: avatarState)
//        } catch {
//            print(error)
//        }
    }
    
    public func addAvatar(id: String, avatar: Avatar) {
        avatars[id] = avatar
    }

    public func removeAvatar(id: String) {
        avatars.removeValue(forKey: id)
    }

    private func updateAvatars(with state: AvatarState) {
        for (_, avatar) in avatars {
            avatar.update(avatarState: state)
        }
    }
}
