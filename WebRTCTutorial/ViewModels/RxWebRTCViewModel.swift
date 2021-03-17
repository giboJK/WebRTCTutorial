//
//  RxWebRTCViewModel.swift
//  WebRTCTutorial
//
//  Created by 정김기보 on 2021/03/17.
//

import Foundation
import RxCocoa
import RxSwift
import WebRTC

class RxWebRTCViewModel {
    // MARK: DI
    var signalingClient: SignalingClient!
    var webRTCClient: WebRTCClient!
    
    
    // MARK: LifeCycle
    init() {
        signalingClient = SignalingClient(webSocket: StarscreamWebSocket(url: Config.default.signalingServerUrl))
        signalingClient.signalClientDelegate = self
        
        webRTCClient = WebRTCClient()
        webRTCClient.delegate = self
    }
    
    
    
}

extension RxWebRTCViewModel: SignalClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient) {
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
    }
}


extension RxWebRTCViewModel: WebRTCClientDelegate {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        
    }
    
    func didReceiveData(data: Data) {
    }
    
    func didReceiveMessage(message: String) {
    }
    
    func didConnectWebRTC() {
        
    }
    
    func didDisconnectWebRTC() {
    }
}
