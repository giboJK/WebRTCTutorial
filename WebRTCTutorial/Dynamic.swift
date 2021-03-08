//
//  Dynamic.swift
//  WebRTCTutorial
//
//  Created by 정김기보 on 2021/03/08.
//

class Dynamic<T> {
    typealias Listener = (T) -> ()
    var listener = [Listener?]()
    
    func bind(_ listener: Listener?) {
        self.listener.append(listener)
    }
    
    func bindAndFire(_ listener: Listener?) {
        self.listener.append(listener)
        listener?(value)
    }
    
    func notify() {
        self.listener.forEach { (listener) in
            listener?(value)
        }
    }
    
    var value: T {
        didSet {
            self.listener.forEach { (listener) in
                listener?(value)
            }
        }
    }
    
    init(_ v: T) {
        value = v
    }
}

