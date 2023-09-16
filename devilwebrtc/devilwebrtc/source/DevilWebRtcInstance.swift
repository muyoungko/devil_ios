//
//  DevilWebRtcInstance.swift
//  devilwebrtc
//
//  Created by Mu Young Ko on 2023/09/16.
//
import AWSCore
import AWSCognitoIdentityProvider
import AWSKinesisVideo
import AWSKinesisVideoSignaling
import AWSMobileClient
import Foundation
import WebRTC

@objc
public class DevilWebRtcInstance: NSObject {
    // cognito credentials
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    var userDetailsResponse: AWSCognitoIdentityUserGetDetailsResponse?
    var userSessionResponse: AWSCognitoIdentityUserSession?

    // variables controlled by UI
    var sendAudioEnabled: Bool = true
    var isMaster: Bool = false
    var signalingConnected: Bool = false
    
    var channelName: String = ""
    var regionName: String = ""
    var clientID: String = ""
    var accessKey: String = "AKIATLXC6DG566WPULMH"
    var secretKey: String = "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"
    
    // clients for WEBRTC Connection
    var signalingClient: SignalingClient?
    var webRTCClient: WebRTCClient?

    // sender IDs
    var remoteSenderClientId: String?
    lazy var localSenderId: String = {
        return connectAsViewClientId
    }()

    
    var vc: VideoViewController?
    
    var peerConnection: RTCPeerConnection?

    
    /*
     This function sets up the WEBRTC Connection
     Once the inputs are read and validated we take the following steps to establish a connection to the SDP Server
     1. Retrieve the Channel ARN from provided channel name + region
       a.  If channel name does not exist then create the channel and use the new Channel ARN
     2. Check whether feed will be stored to a stream with media server.
       a. Note that this only applies for Master feeds (and must have video + audio)
     3. Get Endpoints for Signalling Channel
       a. If we
     4. Gather ICE Candidates
     5. Connect to signalling client associated with channelARN

     After the connection is established switch to VideoView
     */
    func connectAsRole() {
        // Attempt to gather User Inputs
        let awsRegionValue = self.regionName
        let awsRegionType = self.regionName.aws_regionTypeValue()
        // If ClientID is not provided generate one
        if (self.clientID.isEmpty) {
            self.localSenderId = NSUUID().uuidString.lowercased()
            print("Generated clientID is \(self.localSenderId)")
        }
        
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: self.accessKey, secretKey: self.secretKey)
        
        // Kinesis Video Client Configuration
        let configuration = AWSServiceConfiguration(region: awsRegionType, credentialsProvider: credentialsProvider)
        AWSKinesisVideo.register(with: configuration!, forKey: awsKinesisVideoKey)

        // Attempt to retrieve signalling channel.  If it does not exist create the channel
        var channelARN = retrieveChannelARN(channelName: self.channelName)
        if channelARN == nil {
//            channelARN = createChannel(channelName: self.channelName)
        }
        
        // check whether signalling channel will save its recording to a stream
        // only applies for master
        var usingMediaServer : Bool = false
        if self.isMaster {
            usingMediaServer = isUsingMediaServer(channelARN: channelARN!, channelName: self.channelName)
            // Make sure that audio is enabled if ingesting webrtc connection
            if(usingMediaServer && !self.sendAudioEnabled) {
//                popUpError(title: "Invalid Configuration", message: "Audio must be enabled to use MediaServer")
                return
            }
        }
        
        // get signalling channel endpoints
        let endpoints = getSignallingEndpoints(channelARN: channelARN!, region: awsRegionValue, isMaster: self.isMaster, useMediaServer: usingMediaServer)
        let wssURL = createSignedWSSUrl(channelARN: channelARN!, region: awsRegionValue, wssEndpoint: endpoints["WSS"]!, isMaster: self.isMaster)
        print("WSS URL :", wssURL?.absoluteString as Any)
        // get ice candidates using https endpoint
        let httpsEndpoint =
            AWSEndpoint(region: awsRegionType,
                        service: .KinesisVideo,
                        url: URL(string: endpoints["HTTPS"]!!))
        let RTCIceServersList = getIceCandidates(channelARN: channelARN!, endpoint: httpsEndpoint!, regionType: awsRegionType, clientId: localSenderId)
        webRTCClient = WebRTCClient(iceServers: RTCIceServersList, isAudioOn: sendAudioEnabled)
        webRTCClient!.delegate = self

        // Connect to signalling channel with wss endpoint
        print("Connecting to web socket from channel config")
        signalingClient = SignalingClient(serverUrl: wssURL!)
        signalingClient!.delegate = self
        signalingClient!.connect()

        // Create the video view
        let seconds = 2.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            
            //연결 완료 TODO
//            self.vc = VideoViewController(webRTCClient: self.webRTCClient!, signalingClient: self.signalingClient!, localSenderClientID: self.localSenderId, isMaster: self.isMaster, mediaServerEndPoint: endpoints["WEBRTC"] ?? nil)
//            self.present(self.vc!, animated: true, completion: nil)
        }
    }


    // create a signalling channel with the provided channelName.
    // Return the ARN of created channel on success, nil on failure
    func createChannel(channelName: String) -> String? {
        var channelARN : String?
        /*
            equivalent AWS CLI command:
            aws kinesisvideo create-signaling-channel --channel-name channelName --region cognitoIdentityUserPoolRegion
        */
        let kvsClient = AWSKinesisVideo(forKey: awsKinesisVideoKey)
        let createSigalingChannelInput = AWSKinesisVideoCreateSignalingChannelInput.init()
        createSigalingChannelInput?.channelName = channelName
        kvsClient.createSignalingChannel(createSigalingChannelInput!).continueWith(block: { (task) -> Void in
            if let error = task.error {
                print("Error creating channel \(error)")
            } else {
                print("Channel ARN : ", task.result?.channelARN)
                channelARN = task.result?.channelARN
            }
        }).waitUntilFinished()
        return channelARN
    }

    // attempt to retrieve channelARN with provided channelName.
    // Returns channelARN if channel exists otherwise returns nil
    // Note: if this function returns nil check whether it failed because channel doesn not exist or because the credentials are invalid
    func retrieveChannelARN(channelName: String) -> String? {
        var channelARN : String?
        /*
            equivalent AWS CLI command:
            aws kinesisvideo describe-signaling-channel --channelName channelName --region cognitoIdentityUserPoolRegion
        */
        let describeInput = AWSKinesisVideoDescribeSignalingChannelInput()
        describeInput?.channelName = channelName
        let kvsClient = AWSKinesisVideo(forKey: awsKinesisVideoKey)
        kvsClient.describeSignalingChannel(describeInput!).continueWith(block: { (task) -> Void in
            if let error = task.error {
                print("Error describing channel: \(error)")
            } else {
                print("Channel ARN : ", task.result!.channelInfo!.channelARN ?? "Channel ARN empty.")
                channelARN = task.result?.channelInfo?.channelARN
            }
        }).waitUntilFinished()
        return channelARN
    }
    
    // check media server is enabled for signalling channel
    func isUsingMediaServer(channelARN: String, channelName: String) -> Bool {
        var usingMediaServer : Bool = false
        /*
            equivalent AWS CLI command:
            aws kinesisvideo describe-media-storage-configuration --channel-name channelARN --region cognitoIdentityUserPoolRegion
        */
        let mediaStorageInput = AWSKinesisVideoDescribeMediaStorageConfigurationInput()
        mediaStorageInput?.channelARN = channelARN
        let kvsClient = AWSKinesisVideo(forKey: awsKinesisVideoKey)
        kvsClient.describeMediaStorageConfiguration(mediaStorageInput!).continueWith(block: { (task) -> Void in
            if let error = task.error {
                print("Error retriving Media Storage Configuration: \(error)")
            } else {
                usingMediaServer = task.result?.mediaStorageConfiguration!.status == AWSKinesisVideoMediaStorageConfigurationStatus.enabled
                // the app doesn't use the streamARN but could be useful information for the user
                if (usingMediaServer) {
                    print("Stream ARN : ", task.result?.mediaStorageConfiguration!.streamARN ?? "No Stream ARN.")
                }
            }
        }).waitUntilFinished()
        return usingMediaServer
    }
    
    // Get list of Ice Server Config
    func getIceCandidates(channelARN: String, endpoint: AWSEndpoint, regionType: AWSRegionType, clientId: String) -> [RTCIceServer] {
        var RTCIceServersList = [RTCIceServer]()
        
        let kvsStunUrlStrings = ["stun:stun.kinesisvideo." + self.regionName + ".amazonaws.com:443"]
        /*
            equivalent AWS CLI command:
            aws kinesis-video-signaling get-ice-server-config --channel-arn channelARN --client-id clientId --region cognitoIdentityUserPoolRegion
        */
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: "AKIATLXC6DG566WPULMH", secretKey: "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")
        let configuration =
            AWSServiceConfiguration(region: regionType,
                                    endpoint: endpoint,
                                    credentialsProvider: credentialsProvider)
        AWSKinesisVideoSignaling.register(with: configuration!, forKey: awsKinesisVideoKey)
        let kvsSignalingClient = AWSKinesisVideoSignaling(forKey: awsKinesisVideoKey)

        let iceServerConfigRequest = AWSKinesisVideoSignalingGetIceServerConfigRequest.init()

        iceServerConfigRequest?.channelARN = channelARN
        iceServerConfigRequest?.clientId = clientId
        kvsSignalingClient.getIceServerConfig(iceServerConfigRequest!).continueWith(block: { (task) -> Void in
            if let error = task.error {
                print("Error to get ice server config: \(error)")
            } else {
                print("ICE Server List : ", task.result!.iceServerList!)

                for iceServers in task.result!.iceServerList! {
                    RTCIceServersList.append(RTCIceServer.init(urlStrings: iceServers.uris!, username: iceServers.username, credential: iceServers.password))
                }

                RTCIceServersList.append(RTCIceServer.init(urlStrings: kvsStunUrlStrings))
            }
        }).waitUntilFinished()
        return RTCIceServersList
    }
   
    // Get signalling endpoints for the given signalling channel ARN
    func getSignallingEndpoints(channelARN: String, region: String, isMaster: Bool, useMediaServer: Bool) -> Dictionary<String, String?> {
        
        var endpoints = Dictionary <String, String?>()
        /*
            equivalent AWS CLI command:
            aws kinesisvideo get-signaling-channel-endpoint --channel-arn channelARN --single-master-channel-endpoint-configuration Protocols=WSS,HTTPS[,WEBRTC],Role=MASTER|VIEWER --region cognitoIdentityUserPoolRegion
            Note: only include WEBRTC in Protocols if you need a media-server endpoint
        */
        let singleMasterChannelEndpointConfiguration = AWSKinesisVideoSingleMasterChannelEndpointConfiguration()
        singleMasterChannelEndpointConfiguration?.protocols = videoProtocols
        singleMasterChannelEndpointConfiguration?.role = getSingleMasterChannelEndpointRole(isMaster: isMaster)
        
        if(useMediaServer){
            singleMasterChannelEndpointConfiguration?.protocols?.append("WEBRTC")
        }
 
        let kvsClient = AWSKinesisVideo(forKey: awsKinesisVideoKey)

        let signalingEndpointInput = AWSKinesisVideoGetSignalingChannelEndpointInput()
        signalingEndpointInput?.channelARN = channelARN
        signalingEndpointInput?.singleMasterChannelEndpointConfiguration = singleMasterChannelEndpointConfiguration

        kvsClient.getSignalingChannelEndpoint(signalingEndpointInput!).continueWith(block: { (task) -> Void in
            if let error = task.error {
               print("Error to get channel endpoint: \(error)")
            } else {
                print("Resource Endpoint List : ", task.result!.resourceEndpointList!)
            }
            //TODO: Test this popup
            guard (task.result?.resourceEndpointList) != nil else {
                //self.popUpError(title: "Invalid Region Field", message: "No endpoints found")
                return
            }
            for endpoint in task.result!.resourceEndpointList! {
                switch endpoint.protocols {
                case .https:
                    endpoints["HTTPS"] = endpoint.resourceEndpoint
                case .wss:
                    endpoints["WSS"] = endpoint.resourceEndpoint
                case .webrtc:
                    endpoints["WEBRTC"] = endpoint.resourceEndpoint
                case .unknown:
                    print("Error: Unknown endpoint protocol ", endpoint.protocols, "for endpoint" + endpoint.description())
                }
            }
        }).waitUntilFinished()
        return endpoints
    }
    
    func createSignedWSSUrl(channelARN: String, region: String, wssEndpoint: String?, isMaster: Bool) -> URL? {
        // get AWS credentials to sign WSS Url with
        var AWSCredentials : AWSCredentials?
        AWSMobileClient.default().getAWSCredentials { credentials, _ in
            AWSCredentials = credentials
        }
        
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: "AKIATLXC6DG566WPULMH", secretKey: "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")
        
        var sessionKey: String?
        credentialsProvider.credentials().continueWith(block: { (task) -> Void in
            if let error = task.error {
                print("Error creating channel \(error)")
            } else {
                print("task.result?.secretKey : ", task.result?.sessionKey)
            }
        }).waitUntilFinished()
        
        
//        while(AWSCredentials?.sessionKey == nil)
//        {
//            usleep(5)
//        }

        var httpURlString = wssEndpoint!
            + "?X-Amz-ChannelARN=" + channelARN
        if !isMaster {
            httpURlString += "&X-Amz-ClientId=" + self.localSenderId
        }
        let httpRequestURL = URL(string: httpURlString)
        let wssRequestURL = URL(string: wssEndpoint!)
        
        
//        let wssURL = KVSSigner
//            .sign(signRequest: wssRequestURL!,
//                  secretKey: (AWSCredentials?.secretKey)!,
//                  accessKey: (AWSCredentials?.accessKey)!,
//                  sessionToken: (AWSCredentials?.sessionKey)!,
//                  wssRequest: wssRequestURL!,
//                  region: region)
        
        let wssURL = KVSSigner
            .sign(signRequest: httpRequestURL!,
                  secretKey: "ah+TDByNpk8zyNPOSMNAuTlxPnfGbsiI1FF7/afy",
                  accessKey: "AKIATLXC6DG566WPULMH",
                  sessionToken: "",
                  wssRequest: wssRequestURL!,
                  region: region)
        return wssURL
    }
    
    // get appropriate AWSKinesisVideoChannelRole
    func getSingleMasterChannelEndpointRole(isMaster: Bool) -> AWSKinesisVideoChannelRole {
        if isMaster {
            return .master
        }
        return .viewer
    }
}


extension DevilWebRtcInstance: SignalClientDelegate {
    func signalClientDidConnect(_: SignalingClient) {
        signalingConnected = true
    }

    func signalClientDidDisconnect(_: SignalingClient) {
        signalingConnected = false
    }

    func setRemoteSenderClientId() {
        if self.remoteSenderClientId == nil {
            remoteSenderClientId = connectAsViewClientId
        }
    }
    
    func signalClient(_: SignalingClient, senderClientId: String, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        print("Received remote sdp from [\(senderClientId)]")
        if !senderClientId.isEmpty {
            remoteSenderClientId = senderClientId
        }
        setRemoteSenderClientId()
        webRTCClient!.set(remoteSdp: sdp, clientId: senderClientId) { _ in
            print("Setting remote sdp and sending answer.")
            self.vc!.sendAnswer(recipientClientID: self.remoteSenderClientId!)

        }
    }

    func signalClient(_: SignalingClient, senderClientId: String, didReceiveCandidate candidate: RTCIceCandidate) {
        print("Received remote candidate from [\(senderClientId)]")
        if !senderClientId.isEmpty {
            remoteSenderClientId = senderClientId
        }
        setRemoteSenderClientId()
        webRTCClient!.set(remoteCandidate: candidate, clientId: senderClientId)
    }
}

extension DevilWebRtcInstance: WebRTCClientDelegate {
    func webRTCClient(_: WebRTCClient, didGenerate candidate: RTCIceCandidate) {
        print("Generated local candidate")
        setRemoteSenderClientId()
        signalingClient?.sendIceCandidate(rtcIceCandidate: candidate, master: isMaster,
                                          recipientClientId: remoteSenderClientId!,
                                          senderClientId: localSenderId)
    }

    func webRTCClient(_: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        switch state {
        case .connected, .completed:
            print("WebRTC connected/completed state")
        case .disconnected:
            print("WebRTC disconnected state")
        case .new:
            print("WebRTC new state")
        case .checking:
            print("WebRTC checking state")
        case .failed:
            print("WebRTC failed state")
        case .closed:
            print("WebRTC closed state")
        case .count:
            print("WebRTC count state")
        @unknown default:
            print("WebRTC unknown state")
        }
    }

    func webRTCClient(_: WebRTCClient, didReceiveData _: Data) {
        print("Received local data")
    }
}

extension String {
    func trim() -> String {
        return trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}
