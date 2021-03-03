//
//  NativeWebSocket.swift
//  WebRTCTutorial
//
//  Created by 정김기보 on 2021/02/26.
//

import Foundation

class NativeWebSocket: NSObject, WebSocketProvider {
    var webSocketProviderDelegate: WebSocketProviderDelegate?
    private let url: URL
    private var socket: URLSessionWebSocketTask?
    private lazy var urlSession: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    
    init(url: URL) {
        self.url = url
        super.init()
    }
    
    func connect() {
        let socket = urlSession.webSocketTask(with: url)
        socket.resume()
        self.socket = socket
        self.readMessage()
    }
    
    func send(data: Data) {
        self.socket?.send(.data(data)) { _ in }
    }
    
    private func readMessage() {
        self.socket?.receive { [weak self] message in
            guard let self = self else { return }
            
            switch message {
            case .success(.data(let data)):
                self.webSocketProviderDelegate?.webSocket(self, didReceiveData: data)
                self.readMessage()
            case .success:
                self.readMessage()
            case .failure:
                self.disconnect()
            }
        }
    }
    
    private func disconnect() {
        self.socket?.cancel()
        self.socket = nil
        self.webSocketProviderDelegate?.webSocketDidDisconnect(self)
    }
}

extension NativeWebSocket: URLSessionWebSocketDelegate, URLSessionDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.webSocketProviderDelegate?.webSocketDidConnect(self)
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.disconnect()
    }
}
