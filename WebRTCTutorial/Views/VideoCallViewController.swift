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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if targetEnvironment(simulator)
        // simulator does not have camera
        self.useCustomCapturer = false
        #endif
        
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
        
        setupBackButton()
    }
    
    private func setupRemoteVideoContainer() {
        view.addSubview(remoteVideoViewContainter)
        
        remoteVideoViewContainter.backgroundColor = .lightGray
        remoteVideoViewContainter.snp.makeConstraints {
            $0.left.equalTo(view)
            $0.right.equalTo(view)
            $0.top.equalTo(view)
            $0.height.equalTo(view).multipliedBy(0.7)
        }
    }
    
    private func setupLocalVideoContainer() {
        view.addSubview(localVideoViewContainter)
        
        localVideoViewContainter.backgroundColor = .darkGray
        localVideoViewContainter.snp.makeConstraints {
            $0.left.equalTo(view)
            $0.bottom.equalTo(remoteVideoViewContainter)
            $0.height.equalTo(view).multipliedBy(0.3)
            $0.width.equalTo(view).multipliedBy(0.3)
        }
        
    }
    
    private func setupRemoteVideoView() {
        let remoteRenderer = RTCMTLVideoView(frame: self.remoteVideoViewContainter.frame)
        remoteRenderer.videoContentMode = .scaleAspectFill
        webRTCClient.renderRemoteVideo(to: remoteRenderer)
    }
    
    private func setupLocalVideoView() {
        let localRenderer = RTCMTLVideoView(frame: self.localVideoViewContainter.frame)
        localRenderer.videoContentMode = .scaleAspectFill
        self.webRTCClient.startCaptureLocalVideo(renderer: localRenderer)
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
    
    @objc func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
}

extension VideoCallViewController: CameraSessionDelegate {
    func didOutput(_ sampleBuffer: CMSampleBuffer) {
    }
}
