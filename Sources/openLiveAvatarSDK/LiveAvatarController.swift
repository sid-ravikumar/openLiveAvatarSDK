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
        
        synchronizer.subscribeToStateUpdates(event:  "avatar-state-update") { [weak self] (result: Result<AvatarState, Error>) in
            switch result {
            case .success(let avatarState):
                self?.updateAvatars(with: avatarState)
            case .failure(let error):
                print("Failed to receive avatar state update:", error)
            }
        }
    }
    
    public func addFaceCaptureToUIView(view:UIView, emit_id: String) {
        faceCaptureWrapper = FaceCaptureWrapper.init()
        faceCaptureWrapper?.addEmitFunction(emittingFunc: self.emittingFromFacesceneWrapperCallback, id: emit_id)
        faceCaptureWrapper?.addToUIWindow(view: view)
        faceCaptureWrapper?.startCapture()
    }
    
    public func addListenerWrapperToUIVIew(rect: CGRect, view:UIView, name: String) {
        let wrapper = AnimatedFaceSceneListenerWrapper(frame: rect, id: name)
        self.addAvatar(id: name, avatar: wrapper)
        wrapper.addToUIWindow(view: view)
    }
    
    public func emittingFromFacesceneWrapperCallback( avatarState : AvatarState){
        do {
            try synchronizer.publishStateUpdate(event: "avatar-state-update", data: avatarState)
        } catch {
            print(error)
        }
    }
    
    public func addAvatar(id: String, avatar: Avatar) {
        avatars[id] = avatar
    }

    public func removeAvatar(id: String) {
        avatars.removeValue(forKey: id)
    }

    private func updateAvatars(with state: AvatarState) {
        
        for (idx, avatar) in avatars {
            avatar.update(avatarState: state)
        }
    }
}
