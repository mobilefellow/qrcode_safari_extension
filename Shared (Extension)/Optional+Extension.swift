//
//  Optional+Extension.swift
//  qrcode
//
//  Created by 雨谨 on 2023/8/16.
//

import Foundation

extension Optional {
    var stringValue: String {
        if let aValue = self {
            return String(describing: aValue)
        } else {
            return ""
        }
    }
}
