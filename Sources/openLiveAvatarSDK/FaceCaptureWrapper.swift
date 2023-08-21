//
//  File.swift
//  
//
//  Created by Yifu Yin on 6/13/23.
//

import Foundation
import ARKit
import SceneKit

public class FaceCaptureWrapper: NSObject {
    
    public var emit_id: String = ""
    public var frontARSCNView = ARSCNView()
    private var timeofcurrent = Date().timeIntervalSince1970
    var functionToEmitMessageFrom : ((AvatarState) -> Void)?
    
    public func addEmitFunction(emittingFunc: @escaping ((AvatarState) -> Void), id: String) {
        self.functionToEmitMessageFrom = emittingFunc
        self.emit_id = id
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
    }
    
    public func addToUIWindow(view: UIView){
        view.addSubview(frontARSCNView)
    }
}

extension FaceCaptureWrapper: ARSessionDelegate {
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
            errorWithInfo.localizedRecoverySuggestion
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

extension FaceCaptureWrapper: ARSCNViewDelegate {
    // MARK: - Properties
    // MARK: - ARSCNViewDelegate
    /// - Tag: ARNodeTracking
    public func renderer(_: SCNSceneRenderer, didAdd _: SCNNode, for _: ARAnchor) {}

    /// - Tag: ARFaceGeometryUpdate
    public func renderer(_: SCNSceneRenderer, didUpdate _: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        guard let eyeBlinkLeft = faceAnchor.blendShapes[.eyeBlinkLeft] as? Float,
              let eyeBlinkRight = faceAnchor.blendShapes[.eyeBlinkRight] as? Float,
              let browInnerUp = faceAnchor.blendShapes[.browInnerUp] as? Float,
              let browOuterUpLeft = faceAnchor.blendShapes[.browOuterUpLeft] as? Float,
              let browOuterUpRight = faceAnchor.blendShapes[.browOuterUpRight] as? Float,
              let mouthFunnel = faceAnchor.blendShapes[.mouthFunnel] as? Float,
              let jawOpen = faceAnchor.blendShapes[.jawOpen] as? Float,
              let cheekPuff = faceAnchor.blendShapes[.cheekPuff] as? Float
        else { return }
        
        if #available(iOS 12.0, *) {
            let avatarState = AvatarState(eyeBlinkRight: eyeBlinkRight, eyeBlinkLeft: eyeBlinkLeft, mouthFunnel: mouthFunnel, jawOpen: jawOpen, id: self.emit_id, browInnerUp: browInnerUp, browOuterUpLeft: browOuterUpLeft, browOuterUpRight: browOuterUpRight, cheekPuff: cheekPuff, lookAtPoint: faceAnchor.lookAtPoint, transform: faceAnchor.transform)
            self.functionToEmitMessageFrom!(avatarState)
        } else {
            print("Unable to support older iOS!")
        }
    }
}
