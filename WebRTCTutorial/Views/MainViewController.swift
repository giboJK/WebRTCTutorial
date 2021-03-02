//
//  MainViewController.swift
//  WebRTCTutorial
//
//  Created by 정김기보 on 2021/02/26.
//

import UIKit
import AVFoundation
import WebRTC

class MainViewController: UIViewController {
    
    //MARK: - Properties
    var webRTCClient: WebRTCClient!
    var tryToConnectWebSocket: Timer!
    var cameraSession: CameraSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
