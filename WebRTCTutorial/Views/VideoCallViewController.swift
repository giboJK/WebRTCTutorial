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
    var viewModel: WebRTCViewModel!
    
    var useCustomCapturer: Bool = false
    let remoteViewRatio = 0.45
    let localViewRatio = 0.15
    
    private let imagePickerController = UIImagePickerController()
    
    
    // MARK: UI
    let backButton = UIButton(type: .system)
    let remoteVideoViewContainter = UIView()
    let localVideoViewContainter = UIView()
    let switchCameraButton = UIButton(type: .custom)
    let imagePickerOpenButton = UIButton(type: .custom)
    let likeButton = UIButton(type: .custom)
    let heartButton = UIButton(type: .custom)
    let starButton = UIButton(type: .custom)
    let receivedEmoticonImageView = UIImageView()
    let receivedMessageLabel = UILabel()
    let sendMessageTextView = UITextView()
    let sendButton = UIButton(type: .system)
    let hangupButton = UIButton(type: .custom)
    
    
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
        
        viewModel.isCalling.bind { [weak self] isCalling in
            if !isCalling {
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        imagePickerController.delegate = self
        
        viewModel.startVideo()
        
        binding()
    }
    
    deinit {
        print("Deint", self)
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
    
    
    // MARK: User Interaction
    @objc func didTapBackButton() {
        viewModel.disconnect()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapSwitchCameraButton() {
        viewModel.switchCamera()
    }
    
    @objc func didTapImagePickerOpenButton() {
        let type = UIImagePickerController.SourceType.photoLibrary
        guard UIImagePickerController.isSourceTypeAvailable(type) else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.imagePickerController.sourceType = type
            self.present(self.imagePickerController, animated: true)
        }
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
    
    @objc func didTapHangupButton() {
        viewModel.disconnect()
    }
    
    
    // MARK: UI
    private func setupUI() {
        view.backgroundColor = .white
        setupRemoteVideoContainer()
        setupRemoteVideoView()
        setupLocalVideoContainer()
        setupLocalVideoView()
        
        setupSwitchCameraButton()
        setupImagePickerButton()
        setupLikeButton()
        setupHeartButton()
        setupStarButton()
        setupReceivedEmoticonImageView()
        
        setupReceivedMessageLabel()
        setupSendTextView()
        setupSendButton()
        
        setupHangupButton()
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
            $0.width.equalTo(view.snp.height).multipliedBy(localViewRatio)
            $0.height.equalTo(view).multipliedBy(localViewRatio)
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
            $0.width.equalTo(view.snp.height).multipliedBy(localViewRatio)
            $0.height.equalTo(view).multipliedBy(localViewRatio)
        }
    }
    
    private func setupBackButton() {
        view.addSubview(backButton)
        
        backButton.setTitle("Back", for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        backButton.snp.makeConstraints {
            $0.left.equalTo(view).offset(20)
            $0.top.equalTo(view).offset(50)
        }
    }
    
    private func setupSwitchCameraButton() {
        view.addSubview(switchCameraButton)
        
        switchCameraButton.setImage(UIImage(named: "switch"), for: .normal)
        switchCameraButton.addTarget(self, action: #selector(didTapSwitchCameraButton), for: .touchUpInside)
        switchCameraButton.snp.makeConstraints {
            $0.top.equalTo(remoteVideoViewContainter.snp.bottom).offset(8)
            $0.left.equalTo(view).offset(13)
            $0.width.height.equalTo(30)
        }
    }
    
    private func setupImagePickerButton() {
        view.addSubview(imagePickerOpenButton)
        
        imagePickerOpenButton.setImage(UIImage(named: "image_select"), for: .normal)
        imagePickerOpenButton.addTarget(self, action: #selector(didTapImagePickerOpenButton), for: .touchUpInside)
        imagePickerOpenButton.snp.makeConstraints {
            $0.top.equalTo(remoteVideoViewContainter.snp.bottom).offset(8)
            $0.left.equalTo(switchCameraButton.snp.right).offset(13)
            $0.width.height.equalTo(30)
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
            $0.width.height.equalTo(60)
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
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.backgroundColor = .gray
        sendButton.addTarget(self, action: #selector(self.didTapSendButton), for: .touchUpInside)
        sendButton.snp.makeConstraints {
            $0.top.equalTo(sendMessageTextView.snp.bottom).offset(13)
            $0.width.equalTo(80)
            $0.height.equalTo(32)
            $0.centerX.equalTo(view).offset(-60)
        }
    }
    
    private func setupHangupButton() {
        view.addSubview(hangupButton)
        
        hangupButton.setTitle("Hang up", for: .normal)
        hangupButton.backgroundColor = .red
        hangupButton.tintColor = .white
        hangupButton.addTarget(self, action: #selector(self.didTapHangupButton), for: .touchUpInside)
        hangupButton.snp.makeConstraints {
            $0.top.equalTo(sendMessageTextView.snp.bottom).offset(13)
            $0.width.equalTo(80)
            $0.height.equalTo(32)
            $0.centerX.equalTo(view).offset(60)
        }
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

// MARK: UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension VideoCallViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let originImage = info[.originalImage] as? UIImage else { return }
        let fileName = (info[UIImagePickerController.InfoKey.imageURL] as? URL)?.lastPathComponent ?? ""
        if let imageData = originImage.jpegData(compressionQuality: 0.1) {
            viewModel.sendFileImage(to: imageData, name: fileName)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
