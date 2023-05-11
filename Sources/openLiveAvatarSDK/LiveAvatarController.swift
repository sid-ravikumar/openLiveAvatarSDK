import Foundation
import ARKit

public class LiveAvatarController: NSObject {
    private let synchronizer: AvatarStateSynchronizer
    private var avatars: [String: Avatar] = [:]
    public var frontARSCNView = ARSCNView()
    private var timeofcurrent = Date().timeIntervalSince1970
    public var skView: SKView
    var faceScene: AnimatedFaceScene?
    
    public init(apiKey: String, channelName: String) {
        print("Information Information")
        self.synchronizer = AvatarStateSynchronizer(apiKey: apiKey, channelName: channelName)
        skView = SKView()
        faceScene = AnimatedFaceScene()
        skView.presentScene(faceScene?.animatedFaceScene)
        //faceScene.didMove(to: skView)
        super.init()
    }
    
    public func startCapture() {
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking not supported on this device")
            return
        }
        print("Face tracking is supported")

        frontARSCNView.delegate = self
        frontARSCNView.session.delegate = self
        
        setupARFaceTracking()
        
        synchronizer.subscribeToStateUpdates(event:  "avatar-state-update") { [weak self] (result: Result<AvatarState, Error>) in
            switch result {
            case .success(let avatarState):
                self?.faceScene?.updateFaceComponents(self?.getBlendShapes(avatarState) ?? [ARFaceAnchor.BlendShapeLocation: NSNumber]())
                self?.skView.presentScene(self?.faceScene)
            case .failure(let error):
                print("Failed to receive avatar state update:", error)
            }
        }
    }
    
    public func getBlendShapes(_ avatarState: AvatarState) -> [ARFaceAnchor.BlendShapeLocation: NSNumber]{
        var blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber] = [ARFaceAnchor.BlendShapeLocation: NSNumber]()
        blendShapes[.eyeBlinkLeft] = NSNumber(value: avatarState.eyeBlinkLeft)
        blendShapes[.eyeBlinkRight] = NSNumber(value: avatarState.eyeBlinkRight)
        blendShapes[.mouthFunnel] = NSNumber(value: avatarState.mouthFunnel)
        blendShapes[.jawOpen] = NSNumber(value: avatarState.jawOpen)
        return blendShapes
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

extension LiveAvatarController: ARSessionDelegate {
    /// ARFaceTrackingSetup
    func setupARFaceTracking() {
        // check if the device supports ARFaceTracking
        guard ARFaceTrackingConfiguration.isSupported else { return }
        print("device supports ARFaceTracking")
        let configuration = ARFaceTrackingConfiguration()
        // When you enable the `isLightEstimationEnabled` setting, a face-tracking configuration estimates directional and environmental lighting (an `ARDirectionalLightEstimate` object) by referring to the detected face as a light probe. [no need for now]
        // true: CPU 51% Memory 164MB
        // false: CPU 45% Memory 178MB
        configuration.isLightEstimationEnabled = false
        if #available(iOS 13.0, *) {
            configuration.maximumNumberOfTrackedFaces = 1
            print("Turning maximumNumberOfTrackedFaces to 1")
        } else {
            print("Turning maximumNumberOfTrackedFaces to 0")
        } // default value is one
        
        frontARSCNView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    public func session(_: ARSession, didFailWithError error: Error) {
        print("The AR session started.")
        
        guard error is ARError else { return }

        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion,
        ]
        let errorMessage = messages.compactMap { $0 }.joined(separator: "\n")

        DispatchQueue.main.async {
            print("The AR session failed. ::" + errorMessage)
        }
    }

    public func sessionWasInterrupted(_: ARSession) {
        print("The AR session sessionWasInterrupted.")
    }

    public func sessionInterruptionEnded(_: ARSession) {
        print("The AR session sessionInterruptionEnded.")
        DispatchQueue.main.async {
            self.setupARFaceTracking()
        }
    }
}

extension LiveAvatarController: ARSCNViewDelegate {
    // MARK: - Properties
    // MARK: - ARSCNViewDelegate
    /// - Tag: ARNodeTracking
    public func renderer(_: SCNSceneRenderer, didAdd _: SCNNode, for _: ARAnchor) {
        print("renderer being called")
    }

    /// - Tag: ARFaceGeometryUpdate
    public func renderer(_: SCNSceneRenderer, didUpdate _: SCNNode, for anchor: ARAnchor) {
        print("renderer being called2")
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        guard let eyeBlinkLeft = faceAnchor.blendShapes[.eyeBlinkLeft] as? Float,
              let eyeBlinkRight = faceAnchor.blendShapes[.eyeBlinkRight] as? Float,
              let mouthFunnel = faceAnchor.blendShapes[.mouthFunnel] as? Float,
              let jawOpen = faceAnchor.blendShapes[.jawOpen] as? Float
        else { return }
        
        let avatarState = AvatarState(eyeBlinkRight: eyeBlinkRight, eyeBlinkLeft: eyeBlinkLeft, mouthFunnel: mouthFunnel, jawOpen: jawOpen)
        do {
            try synchronizer.publishStateUpdate(event: "avatar-state-update", data: avatarState)
        } catch {
            print(error)
        }
    }
}
