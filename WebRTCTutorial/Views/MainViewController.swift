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
    var viewModel: WebRTCViewModel!
    
    
    // MARK: UI
    let signalingStatusLabel = UILabel()
    let signalingServerConnectButton = UIButton(type: .system)
    let callButton = UIButton(type: .system)
    let backButton = UIButton(type: .system)
    
    
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
    
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        viewModel = WebRTCViewModel()
        
        binding()
    }
    
    deinit {
        Log.d(self)
    }
    
    
    // MARK: User Interaction
    @objc private func didTapSignalingConnectServerButton() {
        viewModel.connectToSignalingServer()
    }
    
    @objc private func didTapCallButton() {
        viewModel.makeCall()
    }
    
    @objc private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    private func moveToVideoCallVC() {
        DispatchQueue.main.async { [weak self] in
            let videoCallVC = VideoCallViewController()
            videoCallVC.modalPresentationStyle = .fullScreen
            videoCallVC.viewModel = self?.viewModel
            self?.present(videoCallVC, animated: true, completion: nil)
        }
    }
    
    // MARK: UI
    private func setupUI() {
        view.backgroundColor = .white
        
        setupSignalingStatusLabel()
        setupSignalingConnectButton()
        setupCallButton()
        setupBackButton()
    }
    
    private func setupSignalingStatusLabel() {
        view.addSubview(signalingStatusLabel)
        
        signalingStatusLabel.text = "Finding the signaling server...."
        signalingStatusLabel.font = .systemFont(ofSize: 25)
        signalingStatusLabel.textColor = .black
        signalingStatusLabel.snp.makeConstraints {
            $0.top.equalTo(view).offset(100)
            $0.left.equalTo(view).offset(20)
        }
    }
    
    private func setupSignalingConnectButton() {
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
    
    private func setupCallButton() {
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
    
    private func setupBackButton() {
        view.addSubview(backButton)
        
        backButton.setTitle("back", for: .normal)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        backButton.snp.makeConstraints {
            $0.left.equalTo(view).offset(20)
            $0.top.equalTo(view).offset(45)
        }
    }
}
