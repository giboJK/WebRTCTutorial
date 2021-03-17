//
//  SignalingClient.swift
//  WebRTCTutorial
//
//  Created by 정김기보 on 2021/02/26.
//

import Foundation
import WebRTC

protocol SignalClientDelegate: AnyObject {
    func signalClientDidConnect(_ signalClient: SignalingClient)
    func signalClientDidDisconnect(_ signalClient: SignalingClient)
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription)
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate)
}

final class SignalingClient {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let webSocket: WebSocketProvider
    weak var signalClientDelegate: SignalClientDelegate?
    
    init(webSocket: WebSocketProvider) {
        self.webSocket = webSocket
        self.webSocket.webSocketProviderDelegate = self
    }
    
    func connect() {
        self.webSocket.connect()
    }
    
    func send(sdp rtcSdp: RTCSessionDescription) {
        let message = Message.sdp(SessionDescription(from: rtcSdp))
        do {
            let dataMessage = try self.encoder.encode(message)
            
            self.webSocket.send(data: dataMessage)
        }
        catch {
            debugPrint("Warning: Could not encode sdp: \(error)")
        }
    }
    
    func send(candidate rtcIceCandidate: RTCIceCandidate) {
        Log.i("send(candidate rtcIceCandidate: RTCIceCandidate)")
        let message = Message.candidate(IceCandidate(from: rtcIceCandidate))
        do {
            let dataMessage = try self.encoder.encode(message)
            self.webSocket.send(data: dataMessage)
        }
        catch {
            debugPrint("Warning: Could not encode candidate: \(error)")
        }
    }
}

extension SignalingClient: WebSocketProviderDelegate {
    func webSocketDidConnect(_ webSocket: WebSocketProvider) {
        Log.i("webSocketDidConnect(_ webSocket: WebSocketProvider)")
        self.signalClientDelegate?.signalClientDidConnect(self)
    }
    
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider) {
        self.signalClientDelegate?.signalClientDidDisconnect(self)
        
        // try to reconnect every two seconds
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            debugPrint("Trying to reconnect to signaling server...")
            self.webSocket.connect()
        }
    }
    
    func webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data) {
        Log.i("webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data)")
        let message: Message
        do {
            message = try self.decoder.decode(Message.self, from: data)
        }
        catch {
            debugPrint("Warning: Could not decode incoming message: \(error)")
            return
        }
        
        switch message {
        case .candidate(let iceCandidate):
            self.signalClientDelegate?.signalClient(self, didReceiveCandidate: iceCandidate.rtcIceCandidate)
        case .sdp(let sessionDescription):
            self.signalClientDelegate?.signalClient(self, didReceiveRemoteSdp: sessionDescription.rtcSessionDescription)
        }
    }
}
