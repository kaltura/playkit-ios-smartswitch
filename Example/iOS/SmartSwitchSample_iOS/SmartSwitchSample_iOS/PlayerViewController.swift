//
//  PlayerViewController.swift
//  SmartSwitchSample_iOS
//
//  Created by Sergey Chausov on 09.07.2021.
//

import UIKit
import PlayKit
import KalturaPlayer
import PlayKitYoubora
import PlayKitSmartSwitch

class PlayerViewController: UIViewController {
    
    let autoPlay: Bool = true
    let preload: Bool = false
    
    @IBOutlet weak var kalturaPlayerView: KalturaPlayerView!
    
    var kalturaOTTPlayer: KalturaOTTPlayer!
    
    deinit {
        kalturaOTTPlayer.destroy()
        kalturaOTTPlayer = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let playerOptions = self.playerOptions()
        
        kalturaOTTPlayer = KalturaOTTPlayer(options: playerOptions)
        kalturaOTTPlayer.view = kalturaPlayerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerPlayerEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        kalturaOTTPlayer.loadMedia(options: mediaOptions()) { [weak self] (error) in
            guard let self = self else { return }
            if error != nil {
                let alert = UIAlertController(title: "Media not loaded", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (alert) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                // If the autoPlay and preload was set to false, prepare will not be called automatically
                if self.autoPlay == false && self.preload == false {
                    self.kalturaOTTPlayer.prepare()
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if kalturaOTTPlayer.isPlaying {
            kalturaOTTPlayer.pause()
        }
        
        kalturaOTTPlayer.removeObserver(self, events: KPPlayerEvent.allEventTypes)
        kalturaOTTPlayer.removeObserver(self, events: SmartSwitchEvent.allEventTypes)
    }
    
    private func mediaOptions() -> OTTMediaOptions {
        let mediaOptions = OTTMediaOptions()
        mediaOptions.assetId = "548575"
        mediaOptions.assetType = .media
        mediaOptions.assetReferenceType = .media
        mediaOptions.playbackContextType = .playback
        mediaOptions.networkProtocol = "http"

        return mediaOptions
    }
    
    private func playerOptions() -> PlayerOptions {
        let playerOptions = PlayerOptions()
        
        playerOptions.autoPlay = autoPlay
        playerOptions.preload = preload
        
        let youboraPluginParams: [String: Any] = [
            "accountCode": "kalturatest",
        ]
        
        let analyticsConfig = AnalyticsConfig(params: youboraPluginParams)
        
        let smartSwitchConfig = SmartSwitchConfig()
        smartSwitchConfig.accountCode = "kalturatest"
        smartSwitchConfig.originCode = "vod"
        smartSwitchConfig.optionalParams = ["live": "false"]
        smartSwitchConfig.timeout = 5
        smartSwitchConfig.reportSelectedCDNCode = true
        
        playerOptions.pluginConfig = PluginConfig(config: [YouboraPlugin.pluginName: analyticsConfig,
                                                           SmartSwitchMediaEntryInterceptor.pluginName: smartSwitchConfig,])
        
        return playerOptions
    }
    
    private func registerPlayerEvents() {
        handleError()
    }
    
    private func handleError() {
        kalturaOTTPlayer.addObserver(self, events: [KPPlayerEvent.error]) { [weak self] event in
            guard let self = self else { return }
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: event.error?.description, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (alert) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        kalturaOTTPlayer.addObserver(self, events: [SmartSwitchEvent.error]) { [weak self] event in
            // Handle SmartSwitch error here.
            if let error = event.error {
                // error here is NSError
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "SmartSwitch Error", message: error.description, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (alert) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

}
