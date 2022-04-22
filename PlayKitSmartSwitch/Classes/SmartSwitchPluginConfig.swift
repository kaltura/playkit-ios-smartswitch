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
    
    /*
    // Set any of these additional parameters:
     ip,
     originCode,
     userAgent,
     live,
     protocol,
     extended,
     nva (as a String),
     nvb (as a String),
     token
     */
    @objc public var optionalParams: [String: String]?
    
    @objc public var timeout: TimeInterval = 10
    
    @objc public var reportSelectedCDNCode: Bool = false
    
    // SmartSwitch domain url default: https://api.gbnpaw.com
    @objc public var domainUrl: String = "https://api.gbnpaw.com"
    
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
    @nonobjc public func set(domainUrl: String) -> Self {
        self.domainUrl = domainUrl
        return self
    }
    
}
