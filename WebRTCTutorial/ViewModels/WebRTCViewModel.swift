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
        debugPrint(self, "Deinit")
    }
    
    private func connectToSignalingServer() {
        signalingClient.connect()
    }
    
    func makeCall() {
        webRTCClient.connect { [weak self] offerSDP in
            self?.signalingClient.send(sdp: offerSDP)
        }
    }
    
    func disconnect() {
        webRTCClient.disconnect()
        // TODO: isCalling 값을 webclient로부터 가져와서 disconnect 되었을 때 false로 바꾸고
        // false를 받으면 VideoCall에서 dismiss하는 것으로 바꾸어야 한다
    }
    
    
    // MARK: Candidate
    func didGenerateCandidate(iceCandidate: RTCIceCandidate) {
        debugPrint("discovered local candidate")
        signalingClient.send(candidate: iceCandidate)
    }
    
    
    // MARK: Video
    func localVideoView() -> UIView {
        return webRTCClient.localVideoView()
    }
    
    func remoteVideoView() -> UIView {
        return webRTCClient.remoteVideoView()
    }
    
    
    // MARK: Send
    func sendData(_ data: Data) {
        webRTCClient.sendData(data)
    }
    
    func sendMessage(_ message: String) {
        webRTCClient.sendMessage(message)
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
        switch sdp.type {
        case .offer:
            print("offer")
            webRTCClient.receiveOffer(offerSDP: sdp) { [weak self] sdp in
                guard let self = self else { return }
                self.signalingClient.send(sdp: sdp)
                if !self.isCalling.value {
                    self.isCalling.value = true
                }
            }
        case .answer:
            print("answer")
            webRTCClient.receiveAnswer(answerSDP: sdp)
        case .prAnswer:
            print("prAnswer")
        @unknown default:
            fatalError("unknown default")
        }
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        webRTCClient.receiveCandidate(remoteCandidate: candidate)
        
        if !self.isCalling.value {
            self.isCalling.value = true
        }
    }
}


extension WebRTCViewModel: WebRTCClientDelegate {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        didGenerateCandidate(iceCandidate: candidate)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        
    }
    
    func didReceiveData(data: Data) {
        debugPrint(self, "didReceiveData")
        receivedData.value = data
    }
    
    func didReceiveMessage(message: String) {
        debugPrint(self, "didReceiveMessage")
        receivedMessage.value = message
    }
    
    func didConnectWebRTC() {
        
    }
    
    func didDisconnectWebRTC() {
        
    }
}


// MARK: Calling
extension WebRTCViewModel {
    func startVideo() {
        webRTCClient.startLocalVideo()
    }
}
