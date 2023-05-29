import Foundation
import ARKit

public class LiveAvatarController: NSObject {
    private let synchronizer: AvatarStateSynchronizer
    private var avatars: [String: AnimatedFaceSceneWrapper] = [:]
    private var timeofcurrent = Date().timeIntervalSince1970
    
    public init(apiKey: String, channelName: String) {
        self.synchronizer = AvatarStateSynchronizer(apiKey: apiKey, channelName: channelName)
        
        super.init()
        
        synchronizer.subscribeToStateUpdates(event:  "avatar-state-update") { [weak self] (result: Result<AvatarState, Error>) in
            switch result {
            case .success(let avatarState):
                print("success")
                self?.updateAvatars(with: avatarState)
            case .failure(let error):
                print("Failed to receive avatar state update:", error)
            }
        }
    }
    
    public func addWrapperToUIVIew(view:UIView) {
        let wrapper = AnimatedFaceSceneWrapper(frame: view.frame, emittingFunc: self.emittingFromFacesceneWrapperCallback)
        wrapper.startCapture()
        self.addAvatar(id: "init", avatar: wrapper)
        wrapper.addToUIWindow(view: view)
    }
    
    public func emittingFromFacesceneWrapperCallback(avatarState : AvatarState){
        do {
            try synchronizer.publishStateUpdate(event: "avatar-state-update", data: avatarState)
        } catch {
            print(error)
        }
    }
    
    public func addAvatar(id: String, avatar: AnimatedFaceSceneWrapper) {
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
