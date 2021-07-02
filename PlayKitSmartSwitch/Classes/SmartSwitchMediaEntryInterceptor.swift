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
//  Created by Sergey Chausov on 30.06.2021.
//

import PlayKit
import KalturaPlayer
import KalturaNetKit

@objc public class SmartSwitchMediaEntryInterceptor: BasePlugin {
    
    public override class var pluginName: String {
        return "SmartSwitchMediaEntryInterceptor/Plugin"
    }
    
    var config: SmartSwitchConfig
    
    var completionHandler: (() -> Void)?
    
    public required init(player: Player, pluginConfig: Any?, messageBus: MessageBus) throws {
        guard let config = pluginConfig as? SmartSwitchConfig else {
            PKLog.error("Missing plugin config")
            throw PKPluginError.missingPluginConfig(pluginName: SmartSwitchMediaEntryInterceptor.pluginName)
        }
        
        self.config = config
        
        try super.init(player: player, pluginConfig: pluginConfig, messageBus: messageBus)
    }
    
    @objc open override func onUpdateMedia(mediaConfig: MediaConfig) {
        super.onUpdateMedia(mediaConfig: mediaConfig)
    }
    
    @objc open override func onUpdateConfig(pluginConfig: Any) {
        super.onUpdateConfig(pluginConfig: pluginConfig)
        
        guard let config = pluginConfig as? SmartSwitchConfig else {
            PKLog.error("Wrong plugin config, it is not possible to update Smart Switch plugin")
            let error = PKPluginError.missingPluginConfig(pluginName: SmartSwitchMediaEntryInterceptor.pluginName)
            self.messageBus?.post(PluginEvent.Error(nsError: error.asNSError))
            return
        }
        
        self.config = config
    }
    
    @objc open override func destroy() {
        self.messageBus?.removeObserver(self, events: [PlayerEvent.error])
        completionHandler = nil
        super.destroy()
    }
}

extension SmartSwitchMediaEntryInterceptor: PKMediaEntryInterceptor {
    
    private func getOrderedCDN(originalURL: URL, completion: @escaping (_ url: String?, _ error: Error?) -> Void) {
        guard let request: KalturaRequestBuilder = KalturaRequestBuilder(url: self.config.smartSwitchUrl,
                                                                         service: nil,
                                                                         action: nil) else {
            completion(nil, nil)
            return
        }
        
        request.set(method: .get)
        request.set(responseSerializer: JSONSerializer())
        
        request.setParam(key: "accountCode", value: self.config.accountCode)
        request.setParam(key: "resource", value: originalURL.absoluteString)
        request.setParam(key: "origincode", value: self.config.originCode)
        
        if let parameters = self.config.optionalParams {
            parameters.forEach { (key: String, value: String) in
                request.setParam(key: key, value: value)
            }
        }
        
        request.set { (response: Response) in
            PKLog.debug("Response:\nStatus Code: \(response.statusCode)\nError: \(response.error?.localizedDescription ?? "")\nData: \(response.data ?? "")")
            
            if let error = response.error {
                completion(nil, error)
                return
            }
            
            if let response = response.data as? [String: AnyObject],
               let list = response["smartSwitch"]?["CDNList"] as? [[String: AnyObject]] {
                
                let sortedListByCDNRank: [Int] = list.compactMap {
                    if let key = $0.keys.first { return Int(key) }
                    return nil
                }.sorted()
                
                if let firstItem = sortedListByCDNRank.first,
                   let item = list.first(where: { return $0["\(firstItem)"] != nil }),
                   let url = item["\(firstItem)"]?["URL"] as? String {
                    completion(url, nil)
                } else {
                    completion(nil, nil)
                }
            } else {
                completion(nil, nil)
            }
        }
        
        PKLog.debug("Sending Youbora Ordered CDN")
        KNKRequestExecutor.shared.send(request: request.build())
    }
    
    @objc public func apply(on mediaEntry: PKMediaEntry, completion: @escaping () -> Void) {
        
        guard let sources = mediaEntry.sources, !sources.isEmpty else {
            PKLog.error("Missing sources in provided MediaEntry: \(mediaEntry.id)")
            self.messageBus?.post(SmartSwitchEvent.Error(error: SmartSwitchPluginError.invalidMediaEntry))
            completion()
            return
        }
        
        completionHandler = completion
        
        DispatchQueue.global(qos: .default).async { [weak self] in
            
            if let source = sources.first,
               let contentURL = source.contentUrl {
                
                self?.getOrderedCDN(originalURL: contentURL, completion: { preferredURL, error in
                    
                    DispatchQueue.main.async {
                        if let preferredURL = preferredURL, !preferredURL.isEmpty, let url = URL(string: preferredURL)  {
                            source.contentUrl = url
                        } else {
                            if let error = error as NSError? {
                                PKLog.error("Smart Switch Error: " + error.localizedDescription)
                                self?.messageBus?.post(SmartSwitchEvent.Error(error: SmartSwitchPluginError.smartSwitchError(error.code,
                                                                                                                             error.localizedDescription)))
                            } else {
                                PKLog.error("Smart Switch cdnbalancer returned incorrect URL")
                                self?.messageBus?.post(SmartSwitchEvent.Error(error: SmartSwitchPluginError.smartSwitchBadUrl))
                            }
                        }
                        
                        self?.completionHandler?()
                    }
                })
            } else {
                DispatchQueue.main.async {
                    PKLog.error("Missed MediaEntry source.contentUrl or SmartLib stream URL is incorrect")
                    self?.messageBus?.post(SmartSwitchEvent.Error(error: SmartSwitchPluginError.unknown))
                    self?.completionHandler?()
                }
            }
        }
    }
    
}
