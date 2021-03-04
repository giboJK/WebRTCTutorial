//
//  MainViewController.swift
//  WebRTCTutorial
//
//  Created by 정김기보 on 2021/02/26.
//

import UIKit
import WebRTC
import Starscream
import SnapKit

class MainViewController: UIViewController {
    
    //MARK: Properties
    var webRTCClient: WebRTCClient!
    var signalingClient: SignalingClient!
    
    
    
    // MARK: UI
    let signalingStatusLabel = UILabel()
    let callButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        signalingClient = SignalingClient(webSocket: StarscreamWebSocket(url: Config.default.signalingServerUrl))
        signalingClient.signalClientDelegate = self
        webRTCClient = WebRTCClient(iceServers: Config.default.webRTCIceServers)
        webRTCClient.delegate = self
        connect()
    }
    
    deinit {
        print("Deint", self)
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
    
    private func moveToVideoCallVC() {
        DispatchQueue.main.async { [weak self] in
            let videoCallVC = VideoCallViewController()
            videoCallVC.modalPresentationStyle = .fullScreen
            videoCallVC.webRTCClient = self?.webRTCClient
            videoCallVC.signalingClient = self?.signalingClient
            self?.present(videoCallVC, animated: true, completion: nil)
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
        switch sdp.type {
        case .offer:
            print("offer")
            webRTCClient.receiveOffer(offerSDP: sdp) { sdp in
                self.signalingClient.send(sdp: sdp)
                self.moveToVideoCallVC()
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
        print("signalClient - didReceiveCandidate")
        // 여러 번 호출 되지 않게 하자
        webRTCClient.receiveCandidate(remoteCandidate: candidate)
        self.moveToVideoCallVC()
    }
}


// MARK: WebRTCClientDelegate
extension MainViewController: WebRTCClientDelegate {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        didGenerateCandidate(iceCandidate: candidate)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        
    }
    
    func didConnectWebRTC() {
        
    }
    
    func didDisconnectWebRTC() {
    
    }
    
    // MARK: Candidate
    func didGenerateCandidate(iceCandidate: RTCIceCandidate) {
        print("discovered local candidate")
        self.signalingClient.send(candidate: iceCandidate)
    }
}
