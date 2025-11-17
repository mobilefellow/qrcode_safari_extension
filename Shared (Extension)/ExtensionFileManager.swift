//
//  ExtensionFileManager.swift
//  qrcode
//
//  Created by 雨谨 on 2023/8/16.
//

import Foundation

extension UserDefaults {
    static var crossApp: UserDefaults = UserDefaults(suiteName: ExtensionFileManager.appGroupID)!
}

/// Extension 的文件管理，支持与主 App 共享
open class ExtensionFileManager: NSObject {

    let directoryUrl: URL?

    static let shared: ExtensionFileManager = ExtensionFileManager(directoryName: nil)

    static var appGroupID: String = "group.com.swang.qrcode.safari"

    init(directoryName: String?) {
        let sharedUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: ExtensionFileManager.appGroupID)?.appendingPathComponent("Library/Caches")
        if let aDirectoryName = directoryName,
           let directoryUrl = sharedUrl?.appendingPathComponent(aDirectoryName, isDirectory: true) {
            if FileManager.default.fileExists(atPath: directoryUrl.path) {
                self.directoryUrl = directoryUrl
            } else if let _ = try? FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil) {
                self.directoryUrl = directoryUrl
            } else {
                qrLog(.error, "ExtensionFileManager: file directoryUrl is empty")
                self.directoryUrl = nil
            }
        } else {
            self.directoryUrl = sharedUrl
        }

        super.init()
    }


    func fileUrl(_ fileName: String) -> URL? {
        return directoryUrl?.appendingPathComponent(fileName)
    }

    func write(data: Data, toFile fileName: String) -> URL? {
        guard let fileUrl = self.fileUrl(fileName) else {
            assert(false, "fileUrl 不存在")
            return nil
        }

        if (!FileManager.default.fileExists(atPath: fileUrl.path)) {
            FileManager.default.createFile(atPath: fileUrl.path, contents: nil, attributes: nil)
        }

        do {
            try data.write(to: fileUrl, options: .atomic)
        } catch {
            qrLog(.error, "ExtensionFileManager: failed to write data to \(fileUrl). error = \(error)")
            return nil
        }
        return fileUrl
    }

    func readData(_ fileName: String) -> Data? {
        guard let fileUrl = self.fileUrl(fileName) else {
            assert(false, "fileUrl 不存在")
            return nil
        }

        return try? Data(contentsOf: fileUrl)
    }

    /// 删除文件夹
    func removeDirectory() {
        if let url = directoryUrl {
            do {
                qrLog(.info, "ExtensionFileManager: removeDirectory \(url)")
                try FileManager.default.removeItem(at: url)
            } catch {
                qrLog(.error, "ExtensionFileManager: removeDirectory \(url), error = \(error)")
            }
        }
    }

    /// 删除文件夹下面的所有文件和子文件夹，保留文件夹本身
    func removeAllContents() {
        if let url = directoryUrl,
            let contentPathComponents = try? FileManager.default.contentsOfDirectory(atPath: url.path) {
            for contentPathComponent in contentPathComponents {
                try? FileManager.default.removeItem(atPath: url.appendingPathComponent(contentPathComponent).path)
            }
            qrLog(.info, "ExtensionFileManager: removeAllContents \(url)")
        }
    }

}
