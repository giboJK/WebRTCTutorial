//
//  MainViewController.swift
//  WebRTCTutorial
//
//  Created by 정김기보 on 2021/02/26.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    
    //MARK: Properties
    
    var isSignalingClientConnected: Bool = false
    var isCalling: Bool = false
    var viewModel: WebRTCViewModel!
    
    
    // MARK: UI
    let signalingStatusLabel = UILabel()
    let signalingServerConnectButton = UIButton(type: .system)
    let callButton = UIButton(type: .system)
    
    
    func binding() {
        viewModel.isSignalingServerConnected.bind { [weak self] isConnected in
            if isConnected {
                self?.signalingStatusLabel.text = "Connected to SignalingServer"
                self?.signalingStatusLabel.textColor = .systemGreen
            } else {
                self?.signalingStatusLabel.text = "Not connected."
                self?.signalingStatusLabel.textColor = .systemRed
            }
        }
        
        viewModel.isCalling.bind { [weak self] isCalling in
            if isCalling {
                self?.moveToVideoCallVC()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        viewModel = WebRTCViewModel()
        
        binding()
    }
    
    deinit {
        print("Deint", self)
    }
    
    @objc func didTapSignalingConnectServerButton() {
        viewModel.connectToSignalingServer()
    }
    
    @objc func didTapCallButton() {
        viewModel.makeCall()
    }
    
    
    // MARK: UI
    func setupUI() {
        view.backgroundColor = .white
        
        setupSignalingStatusLabel()
        setupSignalingConnectButton()
        setupCallButton()
    }
    
    func setupSignalingStatusLabel() {
        view.addSubview(signalingStatusLabel)
        
        signalingStatusLabel.text = "Finding the signaling server...."
        signalingStatusLabel.font = .systemFont(ofSize: 25)
        signalingStatusLabel.snp.makeConstraints {
            $0.top.equalTo(view).offset(100)
            $0.left.equalTo(view).offset(20)
        }
    }
    
    func setupSignalingConnectButton() {
        view.addSubview(signalingServerConnectButton)
        
        signalingServerConnectButton.backgroundColor = .yellow
        signalingServerConnectButton.setTitle("Connect to signaling server", for: .normal)
        signalingServerConnectButton.addTarget(self, action: #selector(didTapSignalingConnectServerButton), for: .touchUpInside)
        signalingServerConnectButton.snp.makeConstraints {
            $0.centerX.equalTo(view)
            $0.bottom.equalTo(view).offset(-240)
            $0.width.equalTo(260)
            $0.height.equalTo(60)
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
            $0.height.equalTo(60)
        }
    }
    
    private func moveToVideoCallVC() {
        DispatchQueue.main.async { [weak self] in
            let videoCallVC = VideoCallViewController()
            videoCallVC.modalPresentationStyle = .fullScreen
            videoCallVC.viewModel = self?.viewModel
            self?.present(videoCallVC, animated: true, completion: nil)
        }
    }
}
