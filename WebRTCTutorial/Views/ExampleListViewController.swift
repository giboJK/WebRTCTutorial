//
//  ExampleListViewController.swift
//  WebRTCTutorial
//
//  Created by 정김기보 on 2021/03/09.
//

import UIKit
import SnapKit

class ExampleListViewController: UIViewController {

    let moveButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    @objc private func moveToMainVC() {
        let mainVC = MainViewController()
        mainVC.modalPresentationStyle = .fullScreen
        
        present(mainVC, animated: true, completion: nil)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        setupMoveButton()
    }
    
    private func setupMoveButton() {
        view.addSubview(moveButton)
        
        moveButton.backgroundColor = .blue
        moveButton.tintColor = .white
        moveButton.setTitle("Go", for: .normal)
        moveButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        moveButton.addTarget(self, action: #selector(moveToMainVC), for: .touchUpInside)
        moveButton.snp.makeConstraints {
            $0.center.equalTo(view)
            $0.width.equalTo(130)
            $0.height.equalTo(50)
        }
    }
}
