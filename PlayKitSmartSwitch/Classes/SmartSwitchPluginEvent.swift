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
//  SmartSwitchPluginEvent.swift
//  PlayKitSmartSwitch
//
//  Created by Sergey Chausov on 30.06.2021.
//

import Foundation
import PlayKit

@objc public class SmartSwitchEvent: PKEvent {
    
    struct SmartSwitchEventDataKeys {
        static let codeKey = "code"
        static let messageKey = "message"
        static let error = "error"
    }
    
    @objc public static let allEventTypes: [SmartSwitchEvent.Type] = [error]
    
    @objc public static let error: SmartSwitchEvent.Type = SmartSwitchEvent.Error.self
    
    class Error: SmartSwitchEvent {
        convenience init(nsError: NSError) {
            self.init([SmartSwitchEventDataKeys.error: nsError])
        }
        
        convenience init(error: SmartSwitchPluginError) {
            self.init([SmartSwitchEventDataKeys.error: error.asNSError,
                       SmartSwitchEventDataKeys.codeKey: error.code,
                       SmartSwitchEventDataKeys.messageKey: error.errorDescription])
        }
    }
}

extension PKEvent {
    /// SmartSwitch Event message value, PKEvent Data Accessor
    @objc public var smartSwitchEventMessage: String? {
        return self.data?[SmartSwitchEvent.SmartSwitchEventDataKeys.messageKey] as? String
    }
}
