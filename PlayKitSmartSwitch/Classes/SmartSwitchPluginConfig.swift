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
//  SmartSwitchPluginConfig.swift
//  PlayKitSmartSwitch
//
//  Created by Sergey Chausov on 30.06.2021.
//

import Foundation

@objc public class SmartSwitchConfig: NSObject {
    
    // Your YOUBORA account code.
    @objc public var accountCode: String = ""
    
    // The application code configured in the UI
    @objc public var application: String?
    
    // CDN group configured to select a subset of configured CDNs.
    // If not set, the API will use the first configuration as the default
    // vod, live1, live2
    @objc public var originCode: String = ""
    
    @objc public var optionalParams: [String: String]?
    
    @objc public var timeout: TimeInterval = 10
    
    @objc public var reportSelectedCDNCode: Bool = false
    
    //SmartSwitch server url
    @objc public var smartSwitchUrl: String = "https://api.gbnpaw.com/{accountCode}/{application}/decision"
    
    @discardableResult
    @nonobjc public func set(accountCode: String) -> Self {
        self.accountCode = accountCode
        return self
    }
    
    @discardableResult
    @nonobjc public func set(application: String) -> Self {
        self.application = application
        return self
    }
    
    @discardableResult
    @nonobjc public func set(originCode: String) -> Self {
        self.originCode = originCode
        return self
    }
    
    @discardableResult
    @nonobjc public func set(optionalParams: [String: String]) -> Self {
        self.optionalParams = optionalParams
        return self
    }
    
    @discardableResult
    @nonobjc public func set(timeout: TimeInterval) -> Self {
        self.timeout = timeout
        return self
    }
    
    @discardableResult
    @nonobjc public func set(smartSwitchUrl: String) -> Self {
        self.smartSwitchUrl = smartSwitchUrl
        return self
    }
    
}
