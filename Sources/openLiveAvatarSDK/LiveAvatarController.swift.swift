import Foundation
import ARKit

public class LiveAvatarController: NSObject {
    private let synchronizer: AvatarStateSynchronizer
    private var avatars: [String: Avatar] = [:]

    public init(apiKey: String, channelName: String) {
        self.synchronizer = AvatarStateSynchronizer(apiKey: apiKey, channelName: channelName)
        super.init()
    }

    public func startCapture() {
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking not supported on this device")
            return
        }

        //call ExARLive2D classes to start capturing face motion

        synchronizer.subscribeToStateUpdates(event: "avatar-state-update") { [weak self] (result: Result<AvatarState, Error>) in
            switch result {
            case .success(let avatarState):
                self?.updateAvatars(with: avatarState)
            case .failure(let error):
                print("Failed to receive avatar state update:", error)
            }
        }
    }

    public func stopCapture() {
        //call ExARLive2D classes to stop capturing face motion
    }

    public func addAvatar(id: String, avatar: Avatar) {
        avatars[id] = avatar
    }

    public func removeAvatar(id: String) {
        avatars.removeValue(forKey: id)
    }

    private func updateAvatars(with state: AvatarState) {
        for (_, avatar) in avatars {
            avatar.update(with: state)
        }
    }
}
