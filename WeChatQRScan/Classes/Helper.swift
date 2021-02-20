//
//  Helper.swift
//  WeChatQRScan
//
//  Created by 乐 y on 2021/2/4.
//

import Foundation

struct Platform {
    static let isSimulator: Bool = {
        #if swift(>=4.1)
          #if targetEnvironment(simulator)
            return true
          #else
            return false
          #endif
        #else
        #if targetEnvironment(simulator)
            return true
          #else
            return false
          #endif
        #endif
    }()
}
