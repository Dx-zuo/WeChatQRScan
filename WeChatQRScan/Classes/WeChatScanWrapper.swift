//
//  WeChatScanWrapper.swift
//  WeChatQRScan
//
//  Created by 乐 y on 2021/2/5.
//

import Foundation
import AVFoundation
import opencv2
import CoreGraphics

public struct WeChatQRScanResult {
    var rect: CGRect
    var text: String
    // 原始数据
    var mat: opencv2.Mat?
}

protocol WeChatScanWrapperDelegate {
    // Required
    func WeChatScanWrapper(_ wrapper: WeChatScanWrapper, didFailure error: Error)
    func WeChatScanWrapper(_ wrapper: WeChatScanWrapper, didSuccess code: String)
    // Optional
    func WeChatScanWrapper(_ wrapper: WeChatScanWrapper, didChangeTorchActive isOn: Bool)
}

public class WeChatScanWrapper: NSObject {
    
    let delegate: WeChatScanWrapperDelegate?
    
    var input: AVCaptureDeviceInput?
    
    lazy var output: AVCaptureVideoDataOutput = {
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
        return output
    }()
    
    lazy var metadataOutput: AVCaptureMetadataOutput = {
        return AVCaptureMetadataOutput()
    }()
    
    lazy let device: AVCaptureDevice = {
        return AVCaptureDevice.default(for: AVMediaType.video)
    }()

    let session: AVCaptureSession = {
        return AVCaptureSession()
    }()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var stillImageOutput: AVCaptureStillImageOutput
    
    lazy var detector: WeChatQRCodeDetector? = {
        guard let mainBundle = Bundle.main.path(forResource: "WeChatQRScan", ofType: "bundle"),
              let bundle = Bundle(path: mainBundle + "/opencv_3rdparty"),
              let detector_prototxt_path = bundle.path(forResource: "detect", ofType: "prototxt"),
            let detector_caffe_model_path = bundle.path(forResource: "detect", ofType: "caffemodel"),
            let super_resolution_prototxt_path = bundle.path(forResource: "sr", ofType: "prototxt"),
            let super_resolution_caffe_model_path = bundle.path(forResource: "sr", ofType: "caffemodel") else {
            assert(false, "本地模型文件丢失")
            return nil
        }
        return WeChatQRCodeDetector(detector_prototxt_path: detector_prototxt_path,
                                 detector_caffe_model_path: detector_caffe_model_path,
                                 super_resolution_prototxt_path: super_resolution_prototxt_path,
                                 super_resolution_caffe_model_path: super_resolution_caffe_model_path)
    }()
    // 是否需要拍照
    var isNeedCaptureImage: Bool

    // 当前扫码结果是否处理
    var isNeedScanResult = true
    
//    var isNeedScanResult = false
    
    //连续扫码
    var supportContinuous = false
    
    // 存储返回结果
    var arrayResult = [WeChatQRScanResult]()
    
    lazy var sessionQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "com.WeChatQRScan.ios.queue")
        return queue
    }()
    
    
    
    private let metadataQueue = DispatchQueue(label: "metadata.session.WeChatScanQR.queue")
    private let videoDataQueue = DispatchQueue(label: "videoData.session.WeChatScanQR.queue")
    
    
    init(videoPreView: UIView,
         objType: [AVMetadataObject.ObjectType] = [(AVMetadataObject.ObjectType.qr as NSString) as AVMetadataObject.ObjectType],
         isCaptureImg: Bool,
         cropRect: CGRect = .zero) {
        
        isNeedCaptureImage = isCaptureImg
        stillImageOutput = AVCaptureStillImageOutput()

        super.init()
        
        guard let device = device else {
            return
        }
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch let error as NSError {
            print("AVCaptureDeviceInput(): \(error)")
        }
        guard let input = input else {
            return
        }
        session.beginConfiguration()
        
        session.sessionPreset = .photo
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        [output, metadataOutput, stillImageOutput].forEach { [weak session] (output) in
            if session?.canAddOutput(output) ?? false {
                session?.addOutput(output)
            }
        }
        
        stillImageOutput.outputSettings = [AVVideoCodecJPEG: AVVideoCodecKey]

        session.sessionPreset = AVCaptureSession.Preset.high

        // 参数设置
        output.setSampleBufferDelegate(self, queue: videoDataQueue)
//        output.metadataObjectTypes = objType
        metadataOutput.setMetadataObjectsDelegate(self, queue: metadataQueue)
        metadataOutput.metadataObjectTypes = [.qr]
        //        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]

        if !cropRect.equalTo(CGRect.zero) {
            // 启动相机后，直接修改该参数无效
//            output.rectOfInterest = cropRect
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill

        var frame: CGRect = videoPreView.frame
        frame.origin = CGPoint.zero
        previewLayer?.frame = frame
        
        videoPreView.layer.insertSublayer(previewLayer!, at: 0)
        
        session.commitConfiguration()
        if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.continuousAutoFocus) {
            do {
                try input.device.lockForConfiguration()
                input.device.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
                input.device.unlockForConfiguration()
            } catch let error as NSError {
                print("device.lockForConfiguration(): \(error)")
            }
        }
    }
    
    func start() {
        if !session.isRunning {
            isNeedScanResult = true
            sessionQueue.async { [weak self] in
                self?.session.startRunning()
            }
        }
    }
    
    func stop() {
        if session.isRunning {
            isNeedScanResult = false
            session.stopRunning()
        }
    }

    
    open func captureImage() {
        guard let stillImageConnection = connectionWithMediaType(mediaType: AVMediaType.video as AVMediaType,
                                                                 connections: stillImageOutput.connections as [AnyObject]) else {
                                                                    return
        }
        stillImageOutput.captureStillImageAsynchronously(from: stillImageConnection, completionHandler: { (imageDataSampleBuffer, _) -> Void in
            self.stop()
            if let imageDataSampleBuffer = imageDataSampleBuffer,
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer) {
                
                let scanImg = UIImage(data: imageData)
                for idx in 0 ... self.arrayResult.count - 1 {
//                    self.arrayResult[idx].imgScanned = scanImg
                }
            }
//            self.successBlock(self.arrayResult)
        })
    }
    
    open func connectionWithMediaType(mediaType: AVMediaType, connections: [AnyObject]) -> AVCaptureConnection? {
        for connection in connections {
            guard let connectionTmp = connection as? AVCaptureConnection else {
                continue
            }
            for port in connectionTmp.inputPorts where port.mediaType == mediaType {
                return connectionTmp
            }
        }
        return nil
    }
    
    
    //MARK: 切换识别区域

    open func changeScanRect(cropRect: CGRect) {
        // 待测试，不知道是否有效
        stop()
//        output.rectOfInterest = cropRect
        start()
    }
    
    //MARK: 切换识别码的类型
    open func changeScanType(objType: [AVMetadataObject.ObjectType]) {
        // 待测试中途修改是否有效
//        output.metadataObjectTypes = objType
    }
    
    open func isGetFlash() -> Bool {
        return device != nil && device!.hasFlash && device!.hasTorch
    }
    
    //MARK: ------获取系统默认支持的码的类型
    static func defaultMetaDataObjectTypes() -> [AVMetadataObject.ObjectType] {
        var types =
            [
                AVMetadataObject.ObjectType.qr,
                AVMetadataObject.ObjectType.upce,
                AVMetadataObject.ObjectType.code39,
                AVMetadataObject.ObjectType.code39Mod43,
                AVMetadataObject.ObjectType.ean13,
                AVMetadataObject.ObjectType.ean8,
                AVMetadataObject.ObjectType.code93,
                AVMetadataObject.ObjectType.code128,
                AVMetadataObject.ObjectType.pdf417,
                AVMetadataObject.ObjectType.aztec,
            ]
        // if #available(iOS 8.0, *)

        types.append(AVMetadataObject.ObjectType.interleaved2of5)
        types.append(AVMetadataObject.ObjectType.itf14)
        types.append(AVMetadataObject.ObjectType.dataMatrix)
        return types
    }
    
    /**
     识别二维码码图像
     
     - parameter image: 二维码图像
     
     - returns: 返回识别结果
     */
    public static func recognizeQRImage(image: UIImage) -> [WeChatQRScanResult] {
        guard let cgImage = image.cgImage else {
            return []
        }
        let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                  context: nil,
                                  options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
        let img = CIImage(cgImage: cgImage)
        let features = detector.features(in: img, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
//        return features.filter {
//            $0.isKind(of: CIQRCodeFeature.self)
//        }.map {
//            $0 as! CIQRCodeFeature
//        }.map {
//            LBXScanResult(str: $0.messageString,
//                          img: image,
//                          barCodeType: AVMetadataObject.ObjectType.qr.rawValue,
//                          corner: nil)
//        }
        return []
    }
    public func setTorchActive(isOn: Bool) {
        assert(Thread.isMainThread)
        
        guard let videoDevice = AVCaptureDevice.default(for: .video),
            videoDevice.hasTorch, videoDevice.isTorchAvailable,
            (metadataOutputEnable || videoDataOutputEnable) else {
                return
        }
        try? videoDevice.lockForConfiguration()
        videoDevice.torchMode = isOn ? .on : .off
        videoDevice.unlockForConfiguration()
    }
    
    deinit {
        setTorchActive(isOn: false)
        session.inputs.forEach({ session.removeInput($0) })
        session.outputs.forEach({ session.removeOutput($0) })
    }
}


extension WeChatScanWrapper : AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput,
                               didOutput metadataObjects: [AVMetadataObject],
                               from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first else { return }
        guard let readableObject = previewLayer?.transformedMetadataObject(for: metadataObject) as? AVMetadataMachineReadableCodeObject, metadataObject.type == .qr else { return }
        isNeedScanResult = true
        guard let stringValue = readableObject.stringValue else { return }
        DispatchQueue.main.async { [weak self] in
            strongSelf.setTorchActive(isOn: false)
//            strongSelf.moveImageViews(qrCode: stringValue, corners: readableObject.corners)
        }
    }
}

extension WeChatScanWrapper: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isNeedScanResult else {
            // 上一帧处理中
            return
        }
        guard let res = self.detector?.detectAndDecode(img: sampleBuffer) else {
            isNeedScanResult = true
            return
        }
        res.forEach({ [weak self] in
            guard let self = self else { return }
            self.delegate?.WeChatScanWrapper(self, didSuccess: $0)
        })
        isNeedScanResult = false
    }
}
