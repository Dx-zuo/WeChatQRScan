//
//  UseAVFoundationPhotoController.swift
//  WeChatQRScan
//
//  Created by 乐 y on 2021/2/5.
//


import UIKit
import AVFoundation
import Photos

@available(iOS 10.0, *)
open class UseAVFoundationPhotoController: UIViewController,UIGestureRecognizerDelegate,AVCapturePhotoCaptureDelegate {
    
    var captureSession: AVCaptureSession?
    
    var captureDevice: AVCaptureDevice?
    
    var captureInput: AVCaptureDeviceInput?
    
    var captureStillImageOutput: AVCaptureStillImageOutput?
    
    var capturePhotoOutput: AVCapturePhotoOutput?
    
    var preview: UIView?
    
    var progressView: UIProgressView?
    
    var tapButton: UIButton?
    
    var flashButton: UIButton?
    
    var focusImage: UIImageView?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    lazy var sessionQueue: DispatchQueue = {
        
        let queue = DispatchQueue(label: "com.xiaovv.iOSUseCamera")
        
        return queue
        
    }()
    
    // 使用AVCapturePhotoOutput 之后 FlashMode 需要从 AVCapturePhotoSettings 设置，之前的 AVCaptureDevice 设置会被忽略
    var currentFlashMode: AVCaptureDevice.FlashMode = {
        
        return AVCaptureDevice.FlashMode.auto
    }()
    
    //
    var photoSampleBuffer: CMSampleBuffer?
    
    var previewPhotoSampleBuffer: CMSampleBuffer?
    
    var livePhotoMovieURL: URL?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
        self.title = "UseAVFoundationController"
        
        initUI()
        
        checkAuthorization()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        
        if (captureSession?.isRunning)! {
            
            captureSession?.stopRunning()
        }
    }
    
    // 初始化自定义相机UI
    fileprivate func initUI() {
        
        let preview = UIView(frame: CGRect(x: 0, y: 40, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height * 0.7))
        preview.backgroundColor = UIColor.black
        
        let focusTapGesture = UITapGestureRecognizer(target: self, action: #selector(focusTap))
        preview.addGestureRecognizer(focusTapGesture)
        
        self.view.addSubview(preview)
        self.preview = preview
        
        let closeButton = UIButton(type: .custom)
//        closeButton.frame = CGRect(x: 20, y: 20, width: 44, height: 44)
        closeButton.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
        closeButton.setTitle("关闭", for: .normal)
        closeButton.setTitleColor(UIColor.white, for: .normal)
        closeButton.addTarget(self, action: #selector(closeClick), for: .touchUpInside)
        self.preview?.addSubview(closeButton)
        
        let toggleButton = UIButton(type: .custom)
        closeButton.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        toggleButton.setTitle("切换", for: .normal)
        toggleButton.setTitleColor(UIColor.white, for: .normal)
        toggleButton.addTarget(self, action: #selector(toggleCamera), for: .touchUpInside)
        self.preview?.addSubview(toggleButton)
        
        let flashButton = UIButton(type: .custom)
        flashButton.frame = CGRect(x: (UIScreen.main.bounds.size.width - 120) * 0.5, y: 20, width: 120, height: 44)
        flashButton.setTitle("闪光灯：自动", for: .normal)
        flashButton.setTitleColor(UIColor.white, for: .normal)
        flashButton.addTarget(self, action: #selector(changeflash), for: .touchUpInside)
        self.preview?.addSubview(flashButton)
        
        let progressView = UIProgressView(frame: CGRect(x: 0, y: preview.frame.maxY - 3, width: UIScreen.main.bounds.size.width, height: 3))
        progressView.progress = 0.0
        progressView.isHidden = true
        self.view.addSubview(progressView)
        self.progressView = progressView
        
        let tapButton = UIButton(type: .custom)
        tapButton.bounds = CGRect(x: 0, y: 0, width: 80, height: 80)
        tapButton.center = CGPoint(x: UIScreen.main.bounds.size.width * 0.5, y: UIScreen.main.bounds.size.height * 0.85)
        tapButton.setImage(UIImage(named: "tap"), for: .normal)
        
        tapButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        
        self.view.addSubview(tapButton)
        self.tapButton = tapButton
        
        let focusImage = UIImageView(image: UIImage(named: "touch_focus_x"))
        focusImage.alpha = 0.0
        self.view.addSubview(focusImage)
        
        self.focusImage = focusImage
    }
    
    // 检查授权
    fileprivate func checkAuthorization()  {
        
        /**
         AVAuthorizationStatusNotDetermined // 未进行授权选择
         AVAuthorizationStatusRestricted // 未授权，且用户无法更新，如家长控制情况下
         AVAuthorizationStatusDenied // 用户拒绝App使用
         AVAuthorizationStatusAuthorized // 已授权，可使用
         */
        
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
            
        case .authorized: // 已授权，可使用
            
            self.configureCaptureSession()
            
        case .notDetermined://进行授权选择
            
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                
                if granted {
                    
                    self.configureCaptureSession()
                    
                }else {
                    
                    let alert = UIAlertController(title: "提示", message: "用户拒绝授权使用相机", preferredStyle: .alert)
                    
                    let alertAction = UIAlertAction(title: "确定", style: .default, handler: nil)
                    
                    alert.addAction(alertAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            })
            
            
        default: //用户拒绝和未授权
            
            let alert = UIAlertController(title: "提示", message: "用户拒绝授权使用相机", preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "确定", style: .default, handler: nil)
            
            alert.addAction(alertAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // 配置会话对象
    fileprivate func configureCaptureSession() {
        
        captureSession = AVCaptureSession()
        
        captureSession?.beginConfiguration()
        
        // CaptureSession 的会话预设,这个地方设置的模式/分辨率大小将影响你后面拍摄照片/视频的大小
        captureSession?.sessionPreset = AVCaptureSession.Preset.photo
        
        // 添加输入
        do {
            // 初始使用后置相机
            let cameraDeviceInput = try AVCaptureDeviceInput(device: self.cameraWithPosition(.back)!)
            
            if (captureSession?.canAddInput(cameraDeviceInput))! {
                
                captureSession?.addInput(cameraDeviceInput)
                
                self.captureInput = cameraDeviceInput
            }
            
        } catch let error as NSError {
            
            print(error.localizedDescription)
        }
        
        // 添加输出
        // 本文 iOS 10 以后 相机的照片输出使用 AVCapturePhotoOutput
        if #available(iOS 10.0, *) {
            
            // 添加 AVCapturePhotoOutput 用于输出照片
            let capturePhotoOutput = AVCapturePhotoOutput()
            
            if (captureSession?.canAddOutput(capturePhotoOutput))! {
                
                captureSession?.addOutput(capturePhotoOutput)
            }
            
            self.capturePhotoOutput = capturePhotoOutput
            
        } else { // iOS 10 之前 相机的照片输出使用 AVCaptureStillImageOutput
            
            captureStillImageOutput = AVCaptureStillImageOutput()
            captureStillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            
            if (captureSession?.canAddOutput(captureStillImageOutput!))! {
                
                captureSession?.addOutput(captureStillImageOutput!)
            }
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
        previewLayer?.frame = (self.preview?.bounds)!
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        //预览图层和视频方向保持一致
        if #available(iOS 10.0, *) {
            
            capturePhotoOutput?.connection(with: AVMediaType.video)?.videoOrientation = (previewLayer?.connection?.videoOrientation)!
            
        } else {
            
            captureStillImageOutput?.connection(with: AVMediaType.video)?.videoOrientation = (previewLayer?.connection?.videoOrientation)!
        }
        
        preview?.layer.insertSublayer(self.previewLayer!, at: 0)
        
        captureSession?.commitConfiguration()
        
        self.sessionQueue.async {
            
            self.captureSession?.startRunning()
        }
    }
    
    @objc func takePhoto() {
        
        if #available(iOS 10.0, *) {// 这里iOS 10 拍摄LivePhoto
            
            guard let capturePhotoOutput = self.capturePhotoOutput else { return }
            
            sessionQueue.async {
                
                let photoSettings = AVCapturePhotoSettings()
                
                photoSettings.isAutoStillImageStabilizationEnabled = true
                photoSettings.isHighResolutionPhotoEnabled = true
                photoSettings.flashMode = self.currentFlashMode
                
                if (capturePhotoOutput.isLivePhotoCaptureSupported) {
                    
                    // 设置 livePhotoMovieFileURL 必须保证 isLivePhotoCaptureEnabled 为 true
                    // 设置了 livePhotoMovieFileURL 必须实现 livePhoto 相关的协议方法
                    photoSettings.livePhotoMovieFileURL = URL(fileURLWithPath: NSTemporaryDirectory() + "tempLivePhoto.mov")
                    capturePhotoOutput.isLivePhotoCaptureEnabled = true
                    capturePhotoOutput.isLivePhotoCaptureSuspended = false
                    capturePhotoOutput.isHighResolutionCaptureEnabled = true
                }
                
                //设置代理方法
                capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
            }
            
        } else {
            
            let connection = captureStillImageOutput?.connection(with: AVMediaType.video)
            
            captureStillImageOutput?.captureStillImageAsynchronously(from: connection!, completionHandler: { (buffer, error) in
                
                guard error == nil else {
                    
                    print("Error captureStillImage: \(String(describing: error))")
                    return
                }
                
                if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer!),
                    let image = UIImage(data: imageData){
                    
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)),nil)
                    
                }
                
            })
        }
    }
    
    @objc func toggleCamera() {
        
        var newPostion: AVCaptureDevice.Position
        
        if self.captureInput?.device.position == AVCaptureDevice.Position.back {
            
            newPostion = .front
        }else {
            
            newPostion = .back
        }
        
        do {
            
            let newDeviceInput = try AVCaptureDeviceInput(device: self.cameraWithPosition(newPostion)!)
            
            self.sessionQueue.async {
                
                self.captureSession?.beginConfiguration()
                
                self.captureSession?.removeInput(self.captureInput!)
                
                if (self.captureSession?.canAddInput(newDeviceInput))! {
                    
                    self.captureSession?.addInput(newDeviceInput)
                    
                    self.captureInput = newDeviceInput
                }
                
                self.captureSession?.commitConfiguration()
            }
            
        } catch let error as NSError {
            
            print(error.localizedDescription)
        }
    }
    
    @objc func changeflash(button: UIButton) {
        
        if (self.captureInput?.device.hasFlash)! {// 判读是否有闪关灯
            
            if #available(iOS 10.0, *) {
                
                if currentFlashMode == AVCaptureDevice.FlashMode.off {
                    
                    currentFlashMode = .on
                    button.setTitle("闪光灯：开启", for: .normal)
                    
                }else if currentFlashMode == AVCaptureDevice.FlashMode.on {
                    
                    currentFlashMode = .auto
                    button.setTitle("闪光灯：自动", for: .normal)
                }else {
                    
                    currentFlashMode = .off
                    
                    button.setTitle("闪光灯：关闭", for: .normal)
                }
                
            } else {
                
                do {
                    
                    try self.captureInput?.device.lockForConfiguration()
                    
                    if let flashMode = self.captureInput?.device.flashMode {
                        
                        if flashMode == AVCaptureDevice.FlashMode.off {
                            
                            self.captureInput?.device.flashMode = .on
                            
                            button.setTitle("闪光灯：开启", for: .normal)
                            
                        }else if flashMode == AVCaptureDevice.FlashMode.on {
                            
                            self.captureInput?.device.flashMode = .auto
                            
                            button.setTitle("闪光灯：自动", for: .normal)
                        }else {
                            
                            self.captureInput?.device.flashMode = .off
                            
                            button.setTitle("闪光灯：关闭", for: .normal)
                        }
                    }
                    
                } catch let error as NSError {
                    
                    print(error.localizedDescription)
                }
                
                self.captureInput?.device.unlockForConfiguration()
            }
        }
        
    }
    
    @objc func focusTap(tapGesture: UITapGestureRecognizer) {
        
        let location = tapGesture.location(in: self.preview)
        
        focusImageAnimateWithCenterPoint(point: location)
        
        let devicePoint = previewLayer?.captureDevicePointConverted(fromLayerPoint: location)
        
        focusWithMode(AVCaptureDevice.FocusMode.autoFocus, exposeMode: AVCaptureDevice.ExposureMode.continuousAutoExposure, devicePoint: devicePoint)
    }
    
    @objc func closeClick() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func focusWithMode(_ focusMode:AVCaptureDevice.FocusMode, exposeMode:AVCaptureDevice.ExposureMode,devicePoint:CGPoint?) {
        
        if let cameraDevice = self.captureInput?.device {
            
            do {
                
                try cameraDevice.lockForConfiguration()
                
                if cameraDevice.isFocusPointOfInterestSupported && cameraDevice.isFocusModeSupported(focusMode) {
                    
                    cameraDevice.focusMode = focusMode
                    cameraDevice.focusPointOfInterest = devicePoint!
                }
                
                if cameraDevice.isExposurePointOfInterestSupported && cameraDevice.isExposureModeSupported(exposeMode) {
                    
                    cameraDevice.exposureMode = exposeMode
                    cameraDevice.exposurePointOfInterest = devicePoint!
                }
                
                cameraDevice.isSubjectAreaChangeMonitoringEnabled = true
                
            } catch let error as NSError {
                
                print(error.localizedDescription)
            }
            
            cameraDevice.unlockForConfiguration()
        }
    }
    
    fileprivate func cameraWithPosition(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        
        if #available(iOS 10.0, *) {
            
            let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: position).devices
            
            for device in devices {
                
                if device.position == position {
                    
                    return device
                }
            }
            
        } else {
            
            let devices = AVCaptureDevice.devices(for: AVMediaType.video)
            
            for device in devices {
                
                if device.position == position {
                    
                    print(device.formats)
                    
                    return device
                }
            }
        }
        
        return nil
        
    }
    
    //聚焦光圈动画
    fileprivate func focusImageAnimateWithCenterPoint(point: CGPoint) {
        
        self.focusImage?.center = point
        self.focusImage?.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.focusImage?.alpha = 1.0
            self.focusImage?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            
        }) { (finished) in
            
            UIView.animate(withDuration: 0.5, delay: 0.5, options: .allowUserInteraction, animations: {
                
                self.focusImage?.alpha = 0.0
            })
            
        }
    }
    
    // MARK: - AVCapturePhotoCaptureDelegate
    public func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        
        print(#function)
    }
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        print(#function)
        
        guard error == nil, let photoSampleBuffer = photoSampleBuffer else {
            
            print("Error capturing photo: \(String(describing: error))")
            return
        }
        
        self.photoSampleBuffer = photoSampleBuffer
        self.previewPhotoSampleBuffer = previewPhotoSampleBuffer
    }
    
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingLivePhotoToMovieFileAt outputFileURL: URL, duration: CMTime, photoDisplayTime: CMTime, resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        
        print(#function)
        
        guard error == nil else {
            
            print("Error capturing Live Photo: \(String(describing: error))")
            return
        }
        
        self.livePhotoMovieURL = outputFileURL
    }
    
    // UIImageWriteToSavedPhotosAlbum 保存照片之后的回调，判断视频是否保存成功，方法名必须这样写
    @objc func image(_ image: UIImage,
               didFinishSavingWithError error: NSError?,
               contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "警告", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "确定", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "提示", message: "照片成功保存到相册", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "确定", style: .default))
            present(ac, animated: true)
        }
    }
}
