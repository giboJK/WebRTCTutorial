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
        Log.i(event)
        switch event {
        case .connected(_):
            self.webSocketProviderDelegate?.webSocketDidConnect(self)
        case .disconnected(_, _):
            self.webSocketProviderDelegate?.webSocketDidDisconnect(self)
        case .cancelled:
            break
        case .error(_):
            break
        case .text(_):
            break
        case .binary(let data):
            self.webSocketProviderDelegate?.webSocket(self, didReceiveData: data)
        default:
            break
        }
    }
}
