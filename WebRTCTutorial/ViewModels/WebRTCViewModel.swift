//
//  WebRTCViewModel.swift
//  WebRTCTutorial
//
//  Created by 정김기보 on 2021/03/08.
//

import Foundation
import WebRTC

class WebRTCViewModel {
    // MARK: DI
    var signalingClient: SignalingClient!
    var webRTCClient: WebRTCClient!
    
    
    // MARK: Dynamics
    var isSignalingServerConnected: Dynamic<Bool> = Dynamic(false)
    var isCalling: Dynamic<Bool> = Dynamic(false)
    var receivedData: Dynamic<Data?> = Dynamic(nil)
    var receivedMessage: Dynamic<String?> = Dynamic(nil)
    
    
    // MARK: LifeCycle
    init() {
        signalingClient = SignalingClient(webSocket: StarscreamWebSocket(url: Config.default.signalingServerUrl))
        signalingClient.signalClientDelegate = self
        
        webRTCClient = WebRTCClient()
        webRTCClient.delegate = self
        
        connectToSignalingServer()
    }
    
    deinit {
        Log.d(self, "Deinit")
    }
    
    func connectToSignalingServer() {
        if !isSignalingServerConnected.value {
            signalingClient.connect()
        }
    }
    
    func makeCall() {
        webRTCClient.connect { [weak self] offerSDP in
            self?.signalingClient.send(sdp: offerSDP)
        }
    }
    
    func disconnect() {
        webRTCClient.disconnect()
    }
    
    
    // MARK: Candidate
    func didGenerateCandidate(iceCandidate: RTCIceCandidate) {
        Log.i("didGenerateCandidate(iceCandidate: RTCIceCandidate)")
        signalingClient.send(candidate: iceCandidate)
    }
    
    
    // MARK: Video
    func localVideoView() -> UIView {
        return webRTCClient.localVideoView()
    }
    
    func remoteVideoView() -> UIView {
        return webRTCClient.remoteVideoView()
    }
    
    func switchCamera() {
        webRTCClient.switchCamera()
    }
    
    
    // MARK: Send
    func sendData(_ data: Data) {
        webRTCClient.sendData(data)
    }
    
    func sendMessage(_ message: String) {
        webRTCClient.sendMessage(message)
    }
    
    func sendFileImage(to imageData: Data, name: String) {
        
    }
}


extension WebRTCViewModel: SignalClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        isSignalingServerConnected.value = true
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        isSignalingServerConnected.value = false
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        Log.i("signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) \(sdp.type)")
        switch sdp.type {
        case .offer:
            webRTCClient.receiveOffer(offerSDP: sdp) { [weak self] sdp in
                guard let self = self else { return }
                self.signalingClient.send(sdp: sdp)
                if !self.isCalling.value {
                    self.isCalling.value = true
                }
            }
        case .answer:
            webRTCClient.receiveAnswer(answerSDP: sdp)
            if !self.isCalling.value {
                self.isCalling.value = true
            }
        case .prAnswer:
            break
        @unknown default:
            break
        }
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        Log.i("signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate)")
        webRTCClient.receiveCandidate(remoteCandidate: candidate)
    }
}


extension WebRTCViewModel: WebRTCClientDelegate {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        didGenerateCandidate(iceCandidate: candidate)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        
    }
    
    func didReceiveData(data: Data) {
        receivedData.value = data
    }
    
    func didReceiveMessage(message: String) {
        receivedMessage.value = message
    }
    
    func didConnectWebRTC() {
        
    }
    
    func didDisconnectWebRTC() {
        isCalling.value = false
    }
}


// MARK: Calling
extension WebRTCViewModel {
    func startVideo() {
        webRTCClient.startLocalVideo()
    }
}
