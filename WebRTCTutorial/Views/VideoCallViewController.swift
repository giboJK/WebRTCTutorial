//
//  VideoCallViewController.swift
//  WebRTCTutorial
//
//  Created by 정김기보 on 2021/03/04.
//

import UIKit
import SnapKit

class VideoCallViewController: UIViewController {
    
    //MARK: Properties
    var webRTCClient: WebRTCClient!
    var signalingClient: SignalingClient!
    var cameraSession: CameraSession?
    
    
    // MARK: UI
    let backButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    deinit {
        print("Deint", self)
    }
    
    func setupUI() {
        view.backgroundColor = .white
        setupBackButton()
    }
    
    func setupBackButton() {
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
