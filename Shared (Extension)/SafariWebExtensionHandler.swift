//
//  SafariWebExtensionHandler.swift
//  Shared (Extension)
//
//  Created by 雨谨 on 2023/8/15.
//

import SafariServices

let SFExtensionMessageKey = "message"
let SFExtensionActionKey = "action"
let SFExtensionTextKey = "text"
let SFExtensionQRCodeKey = "qrCode"
let SFExtensionQRCodeAliasKey = "alias"
let SFExtensionIndexKey = "index"

let SFExtensionSuccessKey = "success"
let SFExtensionReasonKey = "reason"

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        qrLog(.info, "Received message from browser.runtime.sendNativeMessage: %@", context)

        guard let item = context.inputItems[0] as? NSExtensionItem,
              let userInfo = item.userInfo else {
            context.completeRequest(returningItems: [errorResponse(reason: "invalid request: unable to get userInfo")],
                                    completionHandler: nil)
            return;
        }
        guard let messageDic = userInfo[SFExtensionMessageKey] as? [AnyHashable: Any] else {
            context.completeRequest(returningItems: [errorResponse(reason: "invalid request: unable to get messageDic, \(userInfo[SFExtensionMessageKey].stringValue)")],
                                    completionHandler: nil)
            return;
        }
        guard let action = messageDic[SFExtensionActionKey] as? String else {
            context.completeRequest(returningItems: [errorResponse(reason: "invalid request: unable to get action, action = \(messageDic[SFExtensionActionKey].stringValue), messageDic = \(messageDic)")],
                                    completionHandler: nil)
            return;
        }

        let response: NSExtensionItem
        switch action {
        case "addFavorite":
            response = onAddFavorite(item: item, requestMessageDic: messageDic)
        case "deleteFavorite":
            response = onDeleteFavorite(item: item, requestMessageDic: messageDic)
        case "fetchAllFavorites":
            response = onFetchAllFavorites(item: item, requestMessageDic: messageDic)
        case "updateFavoriteAlias":
            response = onUpdateFavoriteAlias(item: item, requestMessageDic: messageDic)
        default:
            response = errorResponse(reason: "invalid request: unrecognized action: \(action), messageDic = \(messageDic)")
        }
        context.completeRequest(returningItems: [response], completionHandler: nil)
    }

    func errorResponse(reason: String) -> NSExtensionItem {
        qrLog(.error, reason)
        let response: NSExtensionItem = NSExtensionItem()
        response.userInfo = [SFExtensionMessageKey: [
            SFExtensionSuccessKey : false.description,
            SFExtensionReasonKey : reason
        ]]
        return response
    }

    func successResponse(value: [AnyHashable : Any]) -> NSExtensionItem{
        qrLog(.info, value)
        let response = NSExtensionItem()
        var messageDic = value
        messageDic[SFExtensionSuccessKey] = true.description
        response.userInfo = [SFExtensionMessageKey: messageDic]
        return response
    }
}

// MARK: - Actions

extension SafariWebExtensionHandler {
    func onAddFavorite(item: NSExtensionItem, requestMessageDic: [AnyHashable : Any]) -> NSExtensionItem {
        guard let text = requestMessageDic[SFExtensionTextKey] as? String else {
            return errorResponse(reason: "invalid \(SFExtensionTextKey) or \(SFExtensionQRCodeKey), text = \(requestMessageDic[SFExtensionTextKey].stringValue), qrCode = \(requestMessageDic[SFExtensionQRCodeKey].stringValue), requestMessageDic = \(requestMessageDic)")
        }

        let alias = requestMessageDic[SFExtensionQRCodeAliasKey] as? String ?? ""
        FavoriteQRCodeManager.shared.addItem(text: text, alias: alias)
        return onFetchAllFavorites(item: item, requestMessageDic: requestMessageDic)
    }

    func onDeleteFavorite(item: NSExtensionItem, requestMessageDic: [AnyHashable : Any]) -> NSExtensionItem {
        guard let text = requestMessageDic[SFExtensionTextKey] as? String else {
            return errorResponse(reason: "invalid \(SFExtensionTextKey) or \(SFExtensionQRCodeKey), text = \(requestMessageDic[SFExtensionTextKey].stringValue), qrCode = \(requestMessageDic[SFExtensionQRCodeKey].stringValue), requestMessageDic = \(requestMessageDic)")
        }

        FavoriteQRCodeManager.shared.deleteItem(text: text, index: requestMessageDic[SFExtensionIndexKey] as? Int)
        return onFetchAllFavorites(item: item, requestMessageDic: requestMessageDic)
    }

    func onUpdateFavoriteAlias(item: NSExtensionItem, requestMessageDic: [AnyHashable : Any]) -> NSExtensionItem {
        guard let alias = requestMessageDic[SFExtensionQRCodeAliasKey] as? String,
                let index = requestMessageDic[SFExtensionIndexKey] as? Int else {
            return errorResponse(reason: "invalid \(SFExtensionQRCodeAliasKey) or \(SFExtensionIndexKey), alias = \(requestMessageDic[SFExtensionQRCodeAliasKey].stringValue), index = \(requestMessageDic[SFExtensionIndexKey].stringValue), requestMessageDic = \(requestMessageDic)")
        }

        FavoriteQRCodeManager.shared.updateAlias(alias, index: index)
        return successResponse(value: [:])
    }

    func onFetchAllFavorites(item: NSExtensionItem, requestMessageDic: [AnyHashable : Any]) -> NSExtensionItem {
        let allItems = FavoriteQRCodeManager.shared.allItems()
        return successResponse(value: ["allItems": allItems])
    }
}

