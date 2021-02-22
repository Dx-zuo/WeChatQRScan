//
//  ViewController.swift
//  WeChatQRScan
//
//  Created by 乐 y on 2021/2/22.
//

import UIKit
import WeChatQRScan
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "扫描", style: .plain, target: self, action: #selector(start))
        // Do any additional setup after loading the view.
    }

    @objc func start() {
        let controller = UseAVFoundationPhotoController()
        let controller1 = WeChatQRScanViewController()
        self.navigationController?.pushViewController(controller1, animated: true)
    }
}

