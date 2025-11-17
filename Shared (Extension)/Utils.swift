//
//  Utils.swift
//  qrcode
//
//  Created by 雨谨 on 2023/8/16.
//

import Foundation
import os.log

public func qrLog(_ logType: OSLogType, _ log: CVarArg) {
    return qrLog(logType, "%@", log)
}

public func qrLog(_ logType: OSLogType, _ format: String, _ args: CVarArg...) {
    let string = NSString(format: format as NSString, args)
    let type: String
    switch logType {
    case .error, .fault:
        type = "[❌]"
    default:
        type = ""
    }

    // review the log through macOS Console.app, and filter with "qrcode Extension"
    NSLog("%@[QRCode Extension] %@", type, string)
}
