//
//  WebRTCClient.swift
//  WebRTCTutorial
//
//  Created by 정김기보 on 2021/02/25.
//

import Foundation
import WebRTC


protocol WebRTCClientDelegate: class {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate)
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState)
    func didReceiveData(data: Data)
    func didReceiveMessage(message: String)
    func didConnectWebRTC()
    func didDisconnectWebRTC()
}

final class WebRTCClient: NSObject {
    weak var delegate: WebRTCClientDelegate?
    
    // MARK: Status
    public private(set) var isConnected: Bool = false
    
    
    // MARK: PeerConnect
    private static let factory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
    }()
    private var peerConnection: RTCPeerConnection?
    private let mediaConstrains = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
                                   kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]
    
    
    // MARK: Audio
    private let rtcAudioSession = RTCAudioSession.sharedInstance()
    private var localAudioTrack: RTCAudioTrack?
    private let audioQueue = DispatchQueue(label: "audio")
    
    
    // MARK: Video
    private var videoCapturer: RTCVideoCapturer?
    private var localVideoTrack: RTCVideoTrack?
    
    private var remoteVideoTrack: RTCVideoTrack?
    private var cameraDevicePosition: AVCaptureDevice.Position = .front
    
    
    private var localView: UIView!
    private var localRenderView: RTCEAGLVideoView?
    private var remoteStream: RTCMediaStream?
    private var remoteView: UIView!
    private var remoteRenderView: RTCEAGLVideoView?
    
    // MARK: Data
    private var localDataChannel: RTCDataChannel?
    private var remoteDataChannel: RTCDataChannel?
    
    
    override init() {
        super.init()
        self.setupViews()
        self.configureAudioSession()
        self.createMediaSenders()
    }
    
    
    // MARK: - Setup
    private func setupPeerConnection() -> RTCPeerConnection{
        let rtcConf = RTCConfiguration()
        rtcConf.iceServers = [RTCIceServer(urlStrings: Config.default.webRTCIceServers)]
        
        // Unified plan is more superior than planB
        rtcConf.sdpSemantics = .unifiedPlan
        
        // gatherContinually will let WebRTC to listen to any network changes and send any new candidates to the other client
        rtcConf.continualGatheringPolicy = .gatherContinually
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil,
                                              optionalConstraints: ["DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue])
        
        let pc = WebRTCClient.factory.peerConnection(with: rtcConf,
                                                     constraints: constraints,
                                                     delegate: nil)
        pc.delegate = self
        
        pc.add(localVideoTrack!, streamIds: ["stream0"])
        pc.add(localAudioTrack!, streamIds: ["stream0"])
        self.localDataChannel?.delegate = self
        
        return pc
    }
    
    
    // MARK: Connect
    func connect(onSuccess: @escaping (RTCSessionDescription) -> Void){
        self.peerConnection = setupPeerConnection()
        
        if let dataChannel = createDataChannel() {
            dataChannel.delegate = self
            self.localDataChannel = dataChannel
        }
        offer(completion: onSuccess)
    }
    
    
    // MARK: Signaling
    private func offer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        let constrains = RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains,
                                             optionalConstraints: nil)
        self.peerConnection?.offer(for: constrains) { (sdp, error) in
            guard let sdp = sdp else {
                return
            }
            if let error = error {
                print("error with offer")
                print(error)
                return
            }
            
            self.peerConnection?.setLocalDescription(sdp) { (error) in
                completion(sdp)
            }
        }
    }
    
    func answer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        let constrains = RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains,
                                             optionalConstraints: nil)
        self.peerConnection?.answer(for: constrains) { (sdp, error) in
            guard let sdp = sdp else {
                return
            }
            if let error = error {
                print("error with answer")
                print(error)
                return
            }
            
            self.peerConnection?.setLocalDescription(sdp, completionHandler: { (error) in
                completion(sdp)
            })
        }
    }
    
    func receiveOffer(offerSDP: RTCSessionDescription, completion: @escaping (RTCSessionDescription) -> Void){
        if peerConnection == nil {
            print("offer received, create peerconnection")
            self.peerConnection = setupPeerConnection()
            self.peerConnection!.delegate = self
        }
        
        print("set remote description")
        self.peerConnection!.setRemoteDescription(offerSDP) { (err) in
            if let error = err {
                print("failed to set remote offer SDP")
                print(error)
                return
            }
            
            print("succeed to set remote offer SDP")
            self.answer(completion: completion)
        }
    }
    
    func receiveAnswer(answerSDP: RTCSessionDescription){
        self.peerConnection!.setRemoteDescription(answerSDP) { (err) in
            if let error = err {
                print("failed to set remote answer SDP")
                print(error)
                return
            } else {
                print("RemoteDescription is sucessfully set.")
            }
        }
    }
    
    func receiveCandidate(remoteCandidate: RTCIceCandidate) {
        self.peerConnection?.add(remoteCandidate)
    }
    
    
    // MARK: Media
    func startCaptureLocalVideo(renderer: RTCVideoRenderer) {
        guard let capturer = self.videoCapturer as? RTCCameraVideoCapturer else {
            return
        }
        
        guard let frontCamera = (RTCCameraVideoCapturer.captureDevices().first { $0.position == .back }),
              // choose highest res
              let format = (RTCCameraVideoCapturer.supportedFormats(for: frontCamera).sorted {
                let width1 = CMVideoFormatDescriptionGetDimensions($0.formatDescription).width
                let width2 = CMVideoFormatDescriptionGetDimensions($1.formatDescription).width
                return width1 < width2
              }).last,
              // choose highest fps
              let fps = (format.videoSupportedFrameRateRanges
                            .sorted { $0.maxFrameRate < $1.maxFrameRate }.last) else {
            return
        }
        
        capturer.startCapture(with: frontCamera,
                              format: format,
                              fps: Int(fps.maxFrameRate))
        
        self.localVideoTrack?.add(renderer)
    }
    
    func renderRemoteVideo(to renderer: RTCVideoRenderer) {
        self.remoteVideoTrack?.add(renderer)
    }
    
    private func configureAudioSession() {
        self.rtcAudioSession.lockForConfiguration()
        do {
            try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
            try self.rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
        } catch let error {
            debugPrint("Error changing AVAudioSession category: \(error)")
        }
        self.rtcAudioSession.unlockForConfiguration()
    }
    
    private func createMediaSenders() {
        self.localAudioTrack = createAudioTrack()
        self.localVideoTrack = createVideoTrack()
    }
    
    private func createAudioTrack() -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = WebRTCClient.factory.audioSource(with: audioConstrains)
        let audioTrack = WebRTCClient.factory.audioTrack(with: audioSource, trackId: "audio0")
        return audioTrack
    }
    
    private func createVideoTrack() -> RTCVideoTrack {
        let videoSource = WebRTCClient.factory.videoSource()
        
        #if TARGET_OS_SIMULATOR
        self.videoCapturer = RTCFileVideoCapturer(webSocketProviderDelegate: videoSource)
        #else
        self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        #endif
        
        let videoTrack = WebRTCClient.factory.videoTrack(with: videoSource, trackId: "video0")
        return videoTrack
    }
    
    // MARK: Data Channels
    private func createDataChannel() -> RTCDataChannel? {
        let config = RTCDataChannelConfiguration()
        config.channelId = 0
        guard let dataChannel = self.peerConnection?.dataChannel(forLabel: "dataChannel",
                                                                 configuration: config) else {
            debugPrint("Warning: Couldn't create data channel.")
            return nil
        }
        
        return dataChannel
    }
    
    func sendData(_ data: Data) {
        let buffer = RTCDataBuffer(data: data, isBinary: true)
        self.remoteDataChannel?.sendData(buffer)
    }
    
    // MARK: - Connection Events
    private func onConnected() {
        self.isConnected = true
        
        DispatchQueue.main.async {
            self.delegate?.didConnectWebRTC()
        }
    }
    
    private func onDisConnected() {
        self.isConnected = false
        
        DispatchQueue.main.async {
            print("--- on dis connected ---")
            self.peerConnection!.close()
            self.peerConnection = nil
            self.localDataChannel = nil
            self.delegate?.didDisconnectWebRTC()
        }
    }
}

extension WebRTCClient: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        debugPrint("peerConnection new signaling state: \(stateChanged)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        debugPrint("peerConnection did add stream")
        self.remoteStream = stream
        
        if let track = stream.videoTracks.first {
            print("video track faund")
            track.add(remoteRenderView!)
        }
        
        if let audioTrack = stream.audioTracks.first{
            print("audio track faund")
            audioTrack.source.volume = 8
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        debugPrint("peerConnection did remove stream")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        debugPrint("peerConnection should negotiate")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        debugPrint("peerConnection new connection state: \(newState)")
        switch newState {
        case .connected, .completed:
            if !self.isConnected {
                self.onConnected()
            }
        default:
            if self.isConnected{
                self.onDisConnected()
            }
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        debugPrint("peerConnection new gathering state: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        self.delegate?.webRTCClient(self, didDiscoverLocalCandidate: candidate)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        debugPrint("peerConnection did remove candidate(s)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        // 이 부분을 어디서 할 지 고민해보자
        if localDataChannel == nil {
            localDataChannel = createDataChannel()
            localDataChannel?.delegate = self
        }
        remoteDataChannel = dataChannel
        remoteDataChannel?.delegate = self
    }
}

extension WebRTCClient {
    private func setTrackEnabled<T: RTCMediaStreamTrack>(_ type: T.Type, isEnabled: Bool) {
        peerConnection?.transceivers
            .compactMap { return $0.sender.track as? T }
            .forEach { $0.isEnabled = isEnabled }
    }
}

// MARK: - Video control
extension WebRTCClient {
    func hideVideo() {
        self.setVideoEnabled(false)
    }
    func showVideo() {
        self.setVideoEnabled(true)
    }
    private func setVideoEnabled(_ isEnabled: Bool) {
        setTrackEnabled(RTCVideoTrack.self, isEnabled: isEnabled)
    }
}

// MARK: - Audio control
extension WebRTCClient {
    func muteAudio() {
        self.setAudioEnabled(false)
    }
    
    func unmuteAudio() {
        self.setAudioEnabled(true)
    }
    
    // Fallback to the default playing device: headphones/bluetooth/ear speaker
    func speakerOff() {
        self.audioQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
                try self.rtcAudioSession.overrideOutputAudioPort(.none)
            } catch let error {
                debugPrint("Error setting AVAudioSession category: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
    
    // Force speaker
    func speakerOn() {
        self.audioQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
                try self.rtcAudioSession.overrideOutputAudioPort(.speaker)
                try self.rtcAudioSession.setActive(true)
            } catch let error {
                debugPrint("Couldn't force audio to speaker: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
    
    private func setAudioEnabled(_ isEnabled: Bool) {
        setTrackEnabled(RTCAudioTrack.self, isEnabled: isEnabled)
    }
}

extension WebRTCClient: RTCDataChannelDelegate {
    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        debugPrint("dataChannel did change state: \(dataChannel.readyState)")
        switch dataChannel.readyState {
        case .closed:
            break
        case .closing:
            break
        case .connecting:
            break
        case .open:
            break
        }
    }
    
    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        DispatchQueue.main.async {
            if buffer.isBinary {
                self.delegate?.didReceiveData(data: buffer.data)
            }else {
                self.delegate?.didReceiveMessage(message: String(data: buffer.data, encoding: String.Encoding.utf8)!)
            }
        }
    }
}

extension WebRTCClient: RTCVideoViewDelegate {
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        let isLandScape = size.width < size.height
        var renderView: RTCEAGLVideoView?
        var parentView: UIView?
        if videoView.isEqual(localRenderView){
            print("local video size changed")
            renderView = localRenderView
            parentView = localView
        }
        
        if videoView.isEqual(remoteRenderView!){
            print("remote video size changed to: ", size)
            renderView = remoteRenderView
            parentView = remoteView
        }
        
        guard let _renderView = renderView, let _parentView = parentView else {
            return
        }
        
        if(isLandScape){
            let ratio = size.width / size.height
            _renderView.frame = CGRect(x: 0, y: 0, width: _parentView.frame.height * ratio, height: _parentView.frame.height)
            _renderView.center.x = _parentView.frame.width/2
        }else{
            let ratio = size.height / size.width
            _renderView.frame = CGRect(x: 0, y: 0, width: _parentView.frame.width, height: _parentView.frame.width * ratio)
            _renderView.center.y = _parentView.frame.height/2
        }
    }
    
    private func setupViews() {
        // local
        localRenderView = RTCEAGLVideoView()
        localRenderView!.delegate = self
        localView = UIView()
        localView.addSubview(localRenderView!)
        // remote
        remoteRenderView = RTCEAGLVideoView()
        remoteRenderView?.delegate = self
        remoteView = UIView()
        remoteView.addSubview(remoteRenderView!)
    }
    
    func localVideoView() -> UIView {
        return localView
    }
    
    func remoteVideoView() -> UIView {
        return remoteView
    }
    
    func startLocalVideo() {
        startCaptureLocalVideo(cameraPositon: self.cameraDevicePosition, videoWidth: 640, videoHeight: 640*16/9, videoFps: 60)
        self.localVideoTrack?.add(self.localRenderView!)
    }
    
    private func startCaptureLocalVideo(cameraPositon: AVCaptureDevice.Position, videoWidth: Int, videoHeight: Int?, videoFps: Int) {
        if let capturer = self.videoCapturer as? RTCCameraVideoCapturer {
            var targetDevice: AVCaptureDevice?
            var targetFormat: AVCaptureDevice.Format?
            
            // find target device
            let devicies = RTCCameraVideoCapturer.captureDevices()
            devicies.forEach { (device) in
                if device.position ==  cameraPositon{
                    targetDevice = device
                }
            }
            
            // find target format
            let formats = RTCCameraVideoCapturer.supportedFormats(for: targetDevice!)
            formats.forEach { (format) in
                for _ in format.videoSupportedFrameRateRanges {
                    let description = format.formatDescription as CMFormatDescription
                    let dimensions = CMVideoFormatDescriptionGetDimensions(description)
                    
                    if dimensions.width == videoWidth && dimensions.height == videoHeight ?? 0{
                        targetFormat = format
                    } else if dimensions.width == videoWidth {
                        targetFormat = format
                    }
                }
            }
            
            capturer.startCapture(with: targetDevice!,
                                  format: targetFormat!,
                                  fps: videoFps)
        } else if let capturer = self.videoCapturer as? RTCFileVideoCapturer{
            print("setup file video capturer")
            if let _ = Bundle.main.path( forResource: "sample.mp4", ofType: nil ) {
                capturer.startCapturing(fromFileNamed: "sample.mp4") { (err) in
                    print(err)
                }
            } else {
                print("file did not faund")
            }
        }
    }
}
