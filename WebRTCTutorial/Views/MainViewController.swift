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
    let callButton = UIButton(type: .system)
    
    
    func binding() {
        viewModel.isSignalingServerConnected.bind { [weak self] isConnected in
            if isConnected {
                self?.signalingStatusLabel.text = "Connected to SignalingServer"
                self?.signalingStatusLabel.textColor = .green
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
    
    @objc func didTapCallButton() {
        viewModel.makeCalling()
    }
    
    
    // MARK: UI
    func setupUI() {
        view.backgroundColor = .white
        
        setupSignalingStatusLabel()
        setupCallButton()
    }
    
    func setupSignalingStatusLabel() {
        view.addSubview(signalingStatusLabel)
        
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
            videoCallVC.viewModel = self?.viewModel
            self?.present(videoCallVC, animated: true, completion: nil)
        }
    }
}
