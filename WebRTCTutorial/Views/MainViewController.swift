//
//  MainViewController.swift
//  WebRTCTutorial
//
//  Created by 정김기보 on 2021/02/26.
//

import UIKit
import AVFoundation
import WebRTC
import Starscream
import SnapKit

class MainViewController: UIViewController {
    
    //MARK: Properties
    var webRTCClient: WebRTCClient!
    var signalingClient: SignalingClient!
    var tryToConnectWebSocket: Timer!
    var cameraSession: CameraSession?
    var webSocket: WebSocket!
    
    
    // You can create video source from CMSampleBuffer :)
    var useCustomCapturer: Bool = false
    var cameraFilter: CameraFilter?
    
    
    // MARK: UI
    var signalingStatusLabel = UILabel()
    var callButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        #if targetEnvironment(simulator)
        // simulator does not have camera
        self.useCustomCapturer = false
        #endif
        
        signalingClient = SignalingClient(webSocket: StarscreamWebSocket(url: Config.default.signalingServerUrl))
        signalingClient.signalClientDelegate = self
        webRTCClient = WebRTCClient(iceServers: Config.default.webRTCIceServers)
        webRTCClient.delegate = self
        connect()
    }
    
    func connect() {
        signalingClient.connect()
    }
    
    @objc func didTapCallButton() {
        webRTCClient.connect { offerSDP in
            self.signalingClient.send(sdp: offerSDP)
        }
    }
    
    
    func setupUI() {
        view.backgroundColor = .white
        
        setupSignalingStatusLabel()
        setupCallButton()
    }
    
    func setupSignalingStatusLabel() {
        view.addSubview(signalingStatusLabel)
        
        signalingStatusLabel.text = "Not connected"
        signalingStatusLabel.textColor = .red
        signalingStatusLabel.font = .systemFont(ofSize: 20)
        signalingStatusLabel.snp.makeConstraints {
            $0.top.equalTo(view).offset(100)
            $0.left.equalTo(view).offset(20)
        }
    }
    
    func setupCallButton() {
        view.addSubview(callButton)
        
        callButton.backgroundColor = .yellow
        callButton.setTitle("Call", for: .normal)
        callButton.addTarget(self, action: #selector(didTapCallButton), for: .touchUpInside)
        callButton.snp.makeConstraints {
            $0.centerX.equalTo(view)
            $0.bottom.equalTo(view).offset(-120)
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }
    }
}


// MARK: SignalClientDelegate
extension MainViewController: SignalClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        print("signalClientDidConnect")
        signalingStatusLabel.text = "Connected to SignalingServer"
        signalingStatusLabel.textColor = .green
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        print("signalClientDidDisconnect")
        signalingStatusLabel.text = "Disconnected to SignalingServer"
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        print("signalClient - didReceiveRemoteSdp")
        // 여기서 remote의 offer를 받음
        // 받은 후 answer를 날려야 함
        // 만약 로컬 sdp가 없으면 answer를 날리고
        // 로컬sdp를 세팅
        webRTCClient.answer { sdp in
            
        }
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        print("signalClient - didReceiveCandidate")
    }
}


// MARK: WebRTCClientDelegate
extension MainViewController: WebRTCClientDelegate {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
    
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        
    }
    
    func didConnectWebRTC() {
        
    }
    
    func didDisconnectWebRTC() {
    
    }
}
