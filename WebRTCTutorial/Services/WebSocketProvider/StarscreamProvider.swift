//
//  StarscreamProvider.swift
//  WebRTCTutorial
//
//  Created by 정김기보 on 2021/02/26.
//

import Foundation
import Starscream

class StarscreamWebSocket: WebSocketProvider {
    var webSocketProviderDelegate: WebSocketProviderDelegate?
    private let socket: WebSocket
    
    init(url: URL) {
        let request = URLRequest(url: url)
        self.socket = WebSocket(request: request)
        self.socket.delegate = self
    }
    
    func connect() {
        self.socket.connect()
    }
    
    func send(data: Data) {
        self.socket.write(data: data)
    }
}

extension StarscreamWebSocket: Starscream.WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        debugPrint("didReceive")
        switch event {
        case .connected(let strings):
            print(strings)
            self.webSocketProviderDelegate?.webSocketDidConnect(self)
        case .disconnected(let reason, let code):
            print(reason, code)
            self.webSocketProviderDelegate?.webSocketDidDisconnect(self)
        case .cancelled:
            print("cancelled")
        case .error(let error):
            print("error \(error.debugDescription)")
        case .text(let str):
            print("text?? \(str)")
        case .binary(let data):
            self.webSocketProviderDelegate?.webSocket(self, didReceiveData: data)
        default:
            print("Event default")
        }
    }
}
