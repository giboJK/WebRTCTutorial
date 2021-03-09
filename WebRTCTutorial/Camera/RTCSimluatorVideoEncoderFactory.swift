//
//  RTCSimluatorVideoEncoderFactory.swift
//  WebRTCTutorial
//
//  Created by 정김기보 on 2021/03/09.
//

import Foundation
import WebRTC

class RTCSimluatorVideoEncoderFactory: RTCDefaultVideoEncoderFactory {
    
    override init() {
        super.init()
    }
    
    override class func supportedCodecs() -> [RTCVideoCodecInfo] {
        var codecs = super.supportedCodecs()
        codecs = codecs.filter{$0.name != "H264"}
        return codecs
    }
}

