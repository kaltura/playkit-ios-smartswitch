// ===================================================================================================
// Copyright (C) 2021 Kaltura Inc.
//
// Licensed under the AGPLv3 license, unless a different license for a
// particular library is specified in the applicable library path.
//
// You may obtain a copy of the License at
// https://www.gnu.org/licenses/agpl-3.0.html
// ===================================================================================================
//
//  SmartSwitchPluginError.swift
//  PlayKitSmartSwitch
//
//  Created by Sergey Chausov on 30.06.2021.
//

import Foundation
import PlayKit

enum SmartSwitchPluginError: PKError {
    
    case smartSwitchError(Int, String)
    case smartSwitchBadUrl
    case invalidMediaEntry
    case pluginInternalError
    case unknown
    
    static let domain = "com.kaltura.playkit.smartswitch"
    
    var code: Int {
        switch self {
        case .smartSwitchError: return PKErrorCode.smartSwitchPluginInvalidSmartLibEntry
        case .smartSwitchBadUrl: return PKErrorCode.smartSwitchPluginInvalidStreamURL
        case .invalidMediaEntry: return PKErrorCode.smartSwitchPluginInvalidMediaEntry
        case .pluginInternalError: return PKErrorCode.smartSwitchInternalError
        case .unknown: return PKErrorCode.smartSwitchUnknownError
        }
    }
    
    var errorDescription: String {
        switch self {
        case .smartSwitchError(_, let errorMessage): return errorMessage
        case .smartSwitchBadUrl: return "Smart Switch stream URL is empty."
        case .invalidMediaEntry: return "Provided MediaEntry can not be modified. Check MediaEntry Sources."
        case .pluginInternalError: return "Smart Switch Plugin internal error."
        case .unknown: return "Smart Switch Plugin unknown error."
        }
    }
    
    var userInfo: [String: Any] {
        
        switch self {
        case .smartSwitchError(let errorCode, let errorMessage): return ["ErrorCode": errorCode, "ErrorMessage": errorMessage]
        default: return [:]
        }
    }
    
}

extension PKErrorDomain {
    @objc(SmartSwitch) public static let smartSwitch = SmartSwitchPluginError.domain
}

extension PKErrorCode {
    @objc(SmartSwitchUnknownError) public static let smartSwitchUnknownError = 10000
    @objc(SmartSwitchPluginInvalidMediaEntry) public static let smartSwitchPluginInvalidMediaEntry = 10001
    @objc(SmartSwitchPluginInvalidSmartLibEntry) public static let smartSwitchPluginInvalidSmartLibEntry = 10002
    @objc(SmartSwitchPluginInvalidStreamURL) public static let smartSwitchPluginInvalidStreamURL = 10003
    @objc(SmartSwitchInternalError) public static let smartSwitchInternalError = 10004
}
