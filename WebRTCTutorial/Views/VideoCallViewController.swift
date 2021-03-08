//
//  VideoCallViewController.swift
//  WebRTCTutorial
//
//  Created by 정김기보 on 2021/03/04.
//

import UIKit
import WebRTC
import SnapKit

class VideoCallViewController: UIViewController, UITextViewDelegate {
    
    //MARK: Properties
    var cameraSession: CameraSession?
    var cameraFilter: CameraFilter?
    
    var viewModel: WebRTCViewModel!
    
    var useCustomCapturer: Bool = false
    let remoteViewRatio = 0.45
    let localViewRation = 0.2
    
    
    // MARK: UI
    let backButton = UIButton(type: .system)
    let remoteVideoViewContainter = UIView()
    let localVideoViewContainter = UIView()
    let likeButton = UIButton(type: .custom)
    let heartButton = UIButton(type: .custom)
    let starButton = UIButton(type: .custom)
    let receivedEmoticonImageView = UIImageView()
    let receivedMessageLabel = UILabel()
    let sendMessageTextView = UITextView()
    let sendButton = UIButton(type: .system)
    
    
    // MARK: Data
    let likeDataString: String = "like"
    let heartDataString: String = "heart"
    let starDataString: String = "star"
    
    
    func binding() {
        viewModel.receivedData.bind { [weak self] data in
            if let data = data {
                self?.handleReceivedData(data)
            }
        }
        
        viewModel.receivedMessage.bind { [weak self] message in
            if let message = message {
                self?.handleReceivedMessage(message)
            }
        }
    }
    
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if targetEnvironment(simulator)
        self.useCustomCapturer = false
        #endif
        
        setupCamera()
        
        setupUI()
        
        viewModel.startVideo()
        
        binding()
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
    
    
    // MARK: DataChannel
    private func handleReceivedData(_ data: Data) {
        if let animationType = String(data: data, encoding: .utf8) {
            startAnimation(animationType)
        }
    }
    
    private func handleReceivedMessage(_ message: String) {
        debugPrint(message)
        receivedMessageLabel.text = message
    }
    
    private func startAnimation(_ animationType: String) {
        receivedEmoticonImageView.image = UIImage(named: animationType)
        receivedEmoticonImageView.backgroundColor = UIColor.clear
        receivedEmoticonImageView.contentMode = .scaleAspectFit
        receivedEmoticonImageView.alpha = 1.0
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.receivedEmoticonImageView.alpha = 0.0
        }) { (reuslt) in
        }
    }
    
    
    // MARK: UI
    private func setupUI() {
        view.backgroundColor = .white
        setupRemoteVideoContainer()
        setupRemoteVideoView()
        setupLocalVideoContainer()
        setupLocalVideoView()
        
        setupLikeButton()
        setupHeartButton()
        setupStarButton()
        setupReceivedEmoticonImageView()
        
        setupReceivedMessageLabel()
        setupSendTextView()
        setupSendButton()
        
        setupBackButton()
    }
    
    private func setupRemoteVideoContainer() {
        view.addSubview(remoteVideoViewContainter)
        
        remoteVideoViewContainter.backgroundColor = .lightGray
        remoteVideoViewContainter.snp.makeConstraints {
            $0.left.equalTo(view)
            $0.right.equalTo(view)
            $0.top.equalTo(view)
            $0.height.equalTo(view).multipliedBy(remoteViewRatio)
        }
    }
    
    private func setupLocalVideoContainer() {
        view.addSubview(localVideoViewContainter)
        
        localVideoViewContainter.backgroundColor = .darkGray
        localVideoViewContainter.snp.makeConstraints {
            $0.left.equalTo(view)
            $0.bottom.equalTo(remoteVideoViewContainter)
            $0.height.equalTo(view).multipliedBy(localViewRation)
            $0.width.equalTo(view.snp.height).multipliedBy(localViewRation * 9 / 16)
        }
    }
    
    private func setupRemoteVideoView() {
        let remoteVideoView = viewModel.remoteVideoView()
        remoteVideoViewContainter.addSubview(remoteVideoView)

        remoteVideoView.snp.makeConstraints {
            $0.top.equalTo(view)
            $0.left.equalTo(view)
            $0.right.equalTo(view)
            $0.height.equalTo(view).multipliedBy(remoteViewRatio)
        }
    }
    
    private func setupLocalVideoView() {
        let localVideoView = viewModel.localVideoView()
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
        
        likeButton.setImage(UIImage(named: likeDataString), for: .normal)
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        likeButton.snp.makeConstraints {
            $0.top.equalTo(remoteVideoViewContainter.snp.bottom).offset(8)
            $0.right.equalTo(view).offset(-13)
            $0.width.height.equalTo(30)
        }
    }
    
    private func setupHeartButton() {
        view.addSubview(heartButton)
        
        heartButton.setImage(UIImage(named: heartDataString), for: .normal)
        heartButton.addTarget(self, action: #selector(didTapHeartButton), for: .touchUpInside)
        heartButton.snp.makeConstraints {
            $0.top.equalTo(remoteVideoViewContainter.snp.bottom).offset(8)
            $0.right.equalTo(likeButton.snp.left).offset(-13)
            $0.width.height.equalTo(30)
        }
    }
    
    private func setupStarButton() {
        view.addSubview(starButton)
        
        starButton.setImage(UIImage(named: starDataString), for: .normal)
        starButton.addTarget(self, action: #selector(didTapStarButton), for: .touchUpInside)
        starButton.snp.makeConstraints {
            $0.top.equalTo(remoteVideoViewContainter.snp.bottom).offset(8)
            $0.right.equalTo(heartButton.snp.left).offset(-13)
            $0.width.height.equalTo(30)
        }
    }
    
    private func setupReceivedEmoticonImageView() {
        view.addSubview(receivedEmoticonImageView)
        
        receivedEmoticonImageView.snp.makeConstraints {
            $0.width.height.equalTo(30)
            $0.bottom.equalTo(remoteVideoViewContainter).offset(-13)
            $0.right.equalTo(remoteVideoViewContainter).offset(-13)
        }
    }
    
    private func setupReceivedMessageLabel() {
        view.addSubview(receivedMessageLabel)
        
        receivedMessageLabel.text = "Received message: "
        receivedMessageLabel.textColor = .black
        receivedMessageLabel.layer.borderColor = UIColor.darkGray.cgColor
        receivedMessageLabel.layer.borderWidth = 1.0
        receivedMessageLabel.snp.makeConstraints {
            $0.top.equalTo(remoteVideoViewContainter.snp.bottom).offset(45)
            $0.left.equalTo(view).offset(13)
            $0.height.equalTo(32)
            $0.right.equalTo(view).offset(-13)
        }
    }
    
    private func setupSendTextView() {
        view.addSubview(sendMessageTextView)
        
        sendMessageTextView.delegate = self
        sendMessageTextView.text = "Type messages."
        sendMessageTextView.layer.borderColor = UIColor.darkGray.cgColor
        sendMessageTextView.layer.borderWidth = 1.0
        sendMessageTextView.snp.makeConstraints {
            $0.top.equalTo(receivedMessageLabel.snp.bottom).offset(8)
            $0.left.equalTo(view).offset(13)
            $0.height.equalTo(32)
            $0.right.equalTo(view).offset(-13)
        }
    }
    
    private func setupSendButton() {
        view.addSubview(sendButton)
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(self.didTapSendButton), for: .touchUpInside)
        sendButton.snp.makeConstraints {
            $0.top.equalTo(sendMessageTextView.snp.bottom).offset(13)
            $0.width.equalTo(80)
            $0.height.equalTo(32)
            $0.centerX.equalTo(view)
        }
    }
    
    
    // MARK: User Interaction
    @objc func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapLikeButton() {
        if let data = likeDataString.data(using: String.Encoding.utf8) {
            viewModel.sendData(data)
        }
    }
    
    @objc func didTapHeartButton() {
        if let data = heartDataString.data(using: String.Encoding.utf8) {
            viewModel.sendData(data)
        }
    }
    
    @objc func didTapStarButton() {
        if let data = starDataString.data(using: String.Encoding.utf8) {
            viewModel.sendData(data)
        }
    }
    
    @objc func didTapSendButton() {
        viewModel.sendMessage(sendMessageTextView.text)
    }
}


// MARK: UITextViewDelegate
extension VideoCallViewController {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            sendMessageTextView.resignFirstResponder()
            return false
        }
        return true
    }
}


extension VideoCallViewController: CameraSessionDelegate {
    func didOutput(_ sampleBuffer: CMSampleBuffer) {
    }
}
