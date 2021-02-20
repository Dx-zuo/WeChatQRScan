//
//  WeChatQRScanViewController.swift
//  Pods-WeChatQRScan_Example
//
//  Created by 乐 y on 2021/2/4.
//

import Foundation
import AVFoundation
import UIKit

public class WeChatQRScanViewController: UIViewController {
    open var scanWrapper: WeChatScanWrapper?
    // 启动区域识别功能
    open var isOpenInterestRect = false
    
    //连续扫码
    open var isSupportContinuous = false;

    // 识别码的类型
    public var arrayCodeType: [AVMetadataObject.ObjectType]?

    // 是否需要识别后的当前图像
    public var isNeedCodeImage = false

    // 相机启动提示文字
    public var readyString: String! = "loading"
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        start()
    }
}

// UI 逻辑
extension WeChatQRScanViewController {
    
    func setupUI() {
        
    }
}

extension WeChatQRScanViewController {
    @objc open func start() {
        if Platform.isSimulator {
            return
        }
        
        if scanWrapper == nil {
            // 指定识别几种码
            if arrayCodeType == nil {
                arrayCodeType = [AVMetadataObject.ObjectType.qr as NSString,
                                 AVMetadataObject.ObjectType.ean13 as NSString,
                                 AVMetadataObject.ObjectType.code128 as NSString] as [AVMetadataObject.ObjectType]
            }
            
            scanWrapper = WeChatScanWrapper(videoPreView: view,
                                            objType: arrayCodeType!, isCaptureImg: isNeedCodeImage, cropRect: view.frame)
        }
        
        scanWrapper?.supportContinuous = isSupportContinuous
        
        scanWrapper?.start()
    }
}




