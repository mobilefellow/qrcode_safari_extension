//
//  FavoriteQRCodeManager.swift
//  qrcode
//
//  Created by 雨谨 on 2023/8/16.
//

import Foundation

class FavoriteQRCodeManager {
    static let shared: FavoriteQRCodeManager = FavoriteQRCodeManager()

    lazy var userDefaults = UserDefaults.crossApp
    let qrCodeItemKey: String = "qrCodeItemKey"

    func addItem(text: String, alias: String) {
        let dic: [String: String] = [
            "text" : text,
            "alias" : alias
        ]

        var array = allItems()
        qrLog(.info, "pre addItem userDefaults = %@", array)
        array.append(dic)
        userDefaults.set(array, forKey: qrCodeItemKey)
    }

    func deleteItem(text: String, index: Int?) {
        var array = allItems()
        qrLog(.info, "pre deleteItem userDefaults = %@", array)
        if let index = index, index < array.count {
            array.remove(at: index)
        } else {
            array.removeAll(where: { $0["text"] == text })
        }
        userDefaults.set(array, forKey: qrCodeItemKey)
    }

    func updateAlias(_ alias: String, index: Int) {
        var array = allItems()
        qrLog(.info, "pre updateAlias userDefaults = %@", array)
        guard index < array.count else {
            qrLog(.error, "updateAlias invalid index: \(index)")
            return
        }
        var dic = array[index]
        dic["alias"] = alias
        array[index] = dic
        userDefaults.set(array, forKey: qrCodeItemKey)
    }

    func allItems() -> [[String: String]] {
        guard let array = userDefaults.object(forKey: qrCodeItemKey) as? [[String: String]] else {
            return []
        }

        return array
    }
}
