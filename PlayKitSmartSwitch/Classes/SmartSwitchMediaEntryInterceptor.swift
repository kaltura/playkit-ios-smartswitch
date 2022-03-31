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
    
    private struct Provider {
        let url: String
        let cdnCode: String
        
        init(url: String, cdnCode: String) {
            self.url = url
            self.cdnCode = cdnCode
        }
    }
    
    private func getOrderedCDN(originalURL: URL,
                               completion: @escaping (_ cdn: Provider?, _ error: Error?) -> Void) {
        
        var serverURL = self.config.domainUrl
        
        serverURL = serverURL.replacingOccurrences(of: "{accountCode}", with: self.config.accountCode)
        
        if let application = self.config.application, !application.isEmpty {
            serverURL = serverURL.replacingOccurrences(of: "{application}",
                                                       with: application.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowedCharacterSet) ?? application)
        } else {
            serverURL = serverURL.replacingOccurrences(of: "{application}/", with: "")
        }
        
        guard let request: KalturaRequestBuilder = KalturaRequestBuilder(url: serverURL,
                                                                         service: nil,
                                                                         action: nil) else {
            PKLog.error("Can not create get ordered CDN request.")
            completion(nil, nil)
            return
        }
        
        request.set(method: .get)
        request.set(responseSerializer: JSONSerializer())
        request.set(timeout: self.config.timeout)
        
        request.setParam(key: "resource", value: originalURL.absoluteString)
        
        if let originCode = self.config.originCode {
            request.setParam(key: "origincode", value: originCode)
        }
        
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
               let list = response["providers"] as? [[String: AnyObject]],
               let firstItem = list.first,
               let url = firstItem["url"] as? String,
               let cdnCode = firstItem["provider"] as? String {
                completion(Provider(url: url, cdnCode: cdnCode), nil)
            } else {
                completion(nil, nil)
            }
        }
        
        PKLog.debug("Sending Youbora Ordered CDN")
        KNKRequestExecutor.shared.send(request: request.build())
    }
    
    @objc public func apply(on mediaEntry: PKMediaEntry, completion: @escaping () -> Void) {
        
        guard let sources = mediaEntry.sources,
              !sources.isEmpty,
              let source = sources.first,
              let contentURL = source.contentUrl else {
            PKLog.error("Missing sources in provided MediaEntry: \(mediaEntry.id)")
            self.messageBus?.post(SmartSwitchEvent.Error(error: SmartSwitchPluginError.invalidMediaEntry))
            completion()
            return
        }
        
        completionHandler = completion
        
        DispatchQueue.global(qos: .default).async { [weak self] in
            
            self?.getOrderedCDN(originalURL: contentURL, completion: { smartSwitcCDNItem, error in
                
                DispatchQueue.main.async {
                    
                    if let preferredURL = smartSwitcCDNItem?.url,
                       !preferredURL.isEmpty,
                       let url = URL(string: preferredURL),
                       let cdnCode = smartSwitcCDNItem?.cdnCode {
                        
                        source.contentUrl = url
                        
                        if let reportCDN = self?.config.reportSelectedCDNCode, reportCDN == true {
                            self?.messageBus?.post(InterceptorEvent.CDNSwitched(cdnCode: cdnCode))
                        }
                    } else {
                        if let error = error as NSError? {
                            PKLog.error("Smart Switch request error: " + error.localizedDescription)
                            self?.messageBus?.post(SmartSwitchEvent.Error(error: SmartSwitchPluginError.smartSwitchError(error.code,
                                                                                                                         error.localizedDescription)))
                        } else {
                            PKLog.error("Smart Switch cdnbalancer: missing content URL or CDN code")
                            self?.messageBus?.post(SmartSwitchEvent.Error(error: SmartSwitchPluginError.smartSwitchBadUrl))
                        }
                    }
                    
                    self?.completionHandler?()
                }
            })
        }
    }
    
}
