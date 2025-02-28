//
//  RTCSimulatorVideoDecorFactory.swift
//  WebRTCTutorial
//
//  Created by 정김기보 on 2021/03/09.
//

import Foundation
import WebRTC

class RTCSimulatorVideoDecoderFactory: RTCDefaultVideoDecoderFactory {
    
    override init() {
        super.init()
    }
    
    override func supportedCodecs() -> [RTCVideoCodecInfo] {
        var codecs = super.supportedCodecs()
        codecs = codecs.filter{$0.name != "H264"}
        return codecs
    }
}
