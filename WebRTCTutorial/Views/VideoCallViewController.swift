//
//  VideoCallViewController.swift
//  WebRTCTutorial
//
//  Created by 정김기보 on 2021/03/04.
//

import UIKit
import WebRTC
import SnapKit

class VideoCallViewController: UIViewController {
    
    //MARK: Properties
    var webRTCClient: WebRTCClient!
    var signalingClient: SignalingClient!
    var cameraSession: CameraSession?
    
    
    // You can create video source from CMSampleBuffer :)
    var useCustomCapturer: Bool = false
    var cameraFilter: CameraFilter?
    
    
    // MARK: UI
    let backButton = UIButton(type: .system)
    let remoteVideoViewContainter = UIView()
    let localVideoViewContainter = UIView()
    let likeButton = UIButton(type: .custom)
    let heartButton = UIButton(type: .custom)
    let starButton = UIButton(type: .custom)
    let receivedEmoticonImageView = UIImageView()
    
    
    // MARK: Data
    let likeDataString: String = "like"
    let heartDataString: String = "heart"
    let starDataString: String = "star"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if targetEnvironment(simulator)
        // simulator does not have camera
        self.useCustomCapturer = false
        #endif
        setupCamera()
        webRTCClient.startLocalVideo()
        setupUI()
    }
    
    deinit {
        print("Deint", self)
    }
    
    func setupCamera() {
        if useCustomCapturer {
            print("--- use custom capturer ---")
            self.cameraSession = CameraSession()
            self.cameraSession?.delegate = self
            self.cameraSession?.setupSession()
            
            self.cameraFilter = CameraFilter()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        setupRemoteVideoContainer()
        setupRemoteVideoView()
        setupLocalVideoContainer()
        setupLocalVideoView()
        
        setupLikeButton()
        setupHeartButton()
        setupStarButton()
        
        setupBackButton()
    }
    
    private func setupRemoteVideoContainer() {
        view.addSubview(remoteVideoViewContainter)
        
        remoteVideoViewContainter.backgroundColor = .lightGray
        remoteVideoViewContainter.snp.makeConstraints {
            $0.left.equalTo(view)
            $0.right.equalTo(view)
            $0.top.equalTo(view)
            $0.height.equalTo(view).multipliedBy(0.5)
        }
    }
    
    private func setupLocalVideoContainer() {
        view.addSubview(localVideoViewContainter)
        
        localVideoViewContainter.backgroundColor = .darkGray
        localVideoViewContainter.snp.makeConstraints {
            $0.left.equalTo(view)
            $0.bottom.equalTo(remoteVideoViewContainter)
            $0.height.equalTo(view).multipliedBy(0.3)
            $0.width.equalTo(view.snp.height).multipliedBy(2.7/16)
        }
    }
    
    private func setupRemoteVideoView() {
        let remoteVideoView = webRTCClient.remoteVideoView()
        remoteVideoViewContainter.addSubview(remoteVideoView)
        
        remoteVideoView.snp.makeConstraints {
            $0.top.equalTo(view)
            $0.left.equalTo(view)
            $0.right.equalTo(view)
            $0.height.equalTo(view).multipliedBy(0.5)
        }
    }
    
    private func setupLocalVideoView() {
        let localVideoView = webRTCClient.localVideoView()
        localVideoViewContainter.addSubview(localVideoView)
        
        localVideoView.snp.makeConstraints {
            $0.left.equalTo(view)
            $0.bottom.equalTo(remoteVideoViewContainter)
            $0.height.equalTo(view).multipliedBy(0.3)
            $0.width.equalTo(view.snp.height).multipliedBy(2.7/16)
        }
    }
    
    private func setupBackButton() {
        view.addSubview(backButton)
        
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        backButton.snp.makeConstraints {
            $0.left.equalTo(view).offset(20)
            $0.top.equalTo(view).offset(50)
        }
    }
    
    private func setupLikeButton() {
        view.addSubview(likeButton)
        
        likeButton.setImage(UIImage(named: "like"), for: .normal)
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        likeButton.snp.makeConstraints {
            $0.top.equalTo(remoteVideoViewContainter.snp.bottom).offset(13)
            $0.right.equalTo(view).offset(-13)
            $0.width.height.equalTo(32)
        }
    }
    
    private func setupHeartButton() {
        view.addSubview(heartButton)
        
        heartButton.setImage(UIImage(named: "heart"), for: .normal)
        heartButton.addTarget(self, action: #selector(didTapHeartButton), for: .touchUpInside)
        heartButton.snp.makeConstraints {
            $0.top.equalTo(remoteVideoViewContainter.snp.bottom).offset(10)
            $0.right.equalTo(likeButton.snp.left).offset(-13)
            $0.width.height.equalTo(32)
        }
    }
    
    private func setupStarButton() {
        view.addSubview(starButton)
        
        starButton.setImage(UIImage(named: "star"), for: .normal)
        starButton.addTarget(self, action: #selector(didTapStarButton), for: .touchUpInside)
        starButton.snp.makeConstraints {
            $0.top.equalTo(remoteVideoViewContainter.snp.bottom).offset(10)
            $0.right.equalTo(heartButton.snp.left).offset(-13)
            $0.width.height.equalTo(32)
        }
    }
    
    private func setupReceivedEmoticonImageView() {
        view.addSubview(receivedEmoticonImageView)
        
        receivedEmoticonImageView.snp.makeConstraints {
            $0.width.height.equalTo(64)
            $0.bottom.equalTo(remoteVideoViewContainter).offset(13)
            $0.right.equalTo(remoteVideoViewContainter).offset(-13)
        }
    }
    
    @objc func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapLikeButton() {
        if let data = likeDataString.data(using: String.Encoding.utf8) {
            webRTCClient.sendData(data)
        }
    }
    
    @objc func didTapHeartButton() {
        if let data = heartDataString.data(using: String.Encoding.utf8) {
            webRTCClient.sendData(data)
        }
    }
    
    @objc func didTapStarButton() {
        if let data = starDataString.data(using: String.Encoding.utf8) {
            webRTCClient.sendData(data)
        }
    }
}

extension VideoCallViewController: CameraSessionDelegate {
    func didOutput(_ sampleBuffer: CMSampleBuffer) {
    }
}
