//
//  DevilWebRtcVideoView.swift
//  devilwebrtc
//
//  Created by Mu Young Ko on 2023/09/25.
//

import Foundation
import UIKit
import AWSKinesisVideo
import WebRTC

class DevilWebRtcVideoView: UIView {
    
    public var localVideoView: UIView?
    
    public var sendVideo: Bool = true
    public var sendAudio: Bool = true
    
    private var webRTCClient: WebRTCClient
    private var signalingClient: SignalingClient
    private var localSenderClientID: String
    private var isMaster: Bool
    
    
    init(webRTCClient: WebRTCClient, signalingClient: SignalingClient, localSenderClientID: String, isMaster: Bool, mediaServerEndPoint: String?) {
        
        self.webRTCClient = webRTCClient
        self.signalingClient = signalingClient
        self.localSenderClientID = localSenderClientID
        self.isMaster = isMaster
        
        super.init(frame: CGRect.zero)
        
        if !isMaster {
            // In viewer mode send offer once connection is established
            webRTCClient.offer { sdp in
                self.signalingClient.sendOffer(rtcSdp: sdp, senderClientid: self.localSenderClientID)
            }
        }
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func start(parentView : UIView) {
        
        #if arch(arm64)
        // Using metal (arm64 only)

        let localRenderer = RTCMTLVideoView(frame: localVideoView?.frame ?? CGRect.zero)
        localRenderer.videoContentMode = .scaleAspectFill

        let remoteRenderer = RTCMTLVideoView(frame: self.frame)
        remoteRenderer.videoContentMode = .scaleAspectFill

        #else
        // Using OpenGLES for the rest
        let localRenderer = RTCEAGLVideoView(frame: localVideoView?.frame ?? CGRect.zero)
        let remoteRenderer = RTCEAGLVideoView(frame: self.frame)
        #endif

        if(sendVideo) {
            webRTCClient.startCaptureLocalVideo(renderer: localRenderer)
        }
        webRTCClient.renderRemoteVideo(to: remoteRenderer)

        if let localVideoView = self.localVideoView {
            embedView(localRenderer, into: localVideoView)
        }
        embedView(remoteRenderer, into: self)
        self.sendSubviewToBack(remoteRenderer)
    }

    func destroy() {
        self.signalingClient.disconnect();
        self.webRTCClient.shutdown();
    }
    
    private func embedView(_ view: UIView, into containerView: UIView) {
        containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view": view]))

        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view": view]))
        containerView.layoutIfNeeded()
    }

    func sendAnswer(recipientClientID: String) {
        webRTCClient.answer { localSdp in
            self.signalingClient.sendAnswer(rtcSdp: localSdp, recipientClientId: recipientClientID)
            print("Sent answer. Update peer connection map and handle pending ice candidates")
            self.webRTCClient.updatePeerConnectionAndHandleIceCandidates(clientId: recipientClientID)
        }
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if(self.window == nil) {
            self.webRTCClient.shutdown()
            self.signalingClient.disconnect()
        }
    }
}
