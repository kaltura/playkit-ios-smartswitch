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
    
    // CDN group configured to select a subset of configured CDNs.
    // vod, live1, live2
    @objc public var originCode: String = ""
    
    @objc public var optionalParams: [String: String]?
    
    @objc public var timeout: TimeInterval = 10
    
    //SmartSwitch server url
    var smartSwitchUrl: String = "http://cdnbalancer.youbora.com/orderedcdn"
    
    @discardableResult
    @nonobjc public func set(accountCode: String) -> Self {
        self.accountCode = accountCode
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
}
