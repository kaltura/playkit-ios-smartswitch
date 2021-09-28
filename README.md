# PlayKitSmartSwitch

[![Version](https://img.shields.io/cocoapods/v/PlayKitSmartSwitch.svg?style=flat)](https://cocoapods.org/pods/PlayKitSmartSwitch)
[![License](https://img.shields.io/cocoapods/l/PlayKitSmartSwitch.svg?style=flat)](https://cocoapods.org/pods/PlayKitSmartSwitch)
[![Platform](https://img.shields.io/cocoapods/p/PlayKitSmartSwitch.svg?style=flat)](https://cocoapods.org/pods/PlayKitSmartSwitch)
[![CI Status](https://travis-ci.com/kaltura/playkit-ios-smartswitch.svg?branch=develop)](https://travis-ci.com/github/kaltura/playkit-ios-smartswitch)
https://github.com/kaltura/
Kaltura Player iOS plugin for NPAW Smart Switch

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory.
Then run iOS and tvOS samples

## Installation

**PlayKitSmartSwitch** is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following lines to your Podfile:

```ruby
pod 'PlayKitSmartSwitch'
```
Once you setup everything run command in the Terminal.
```ruby
pod install
```

## Usage
### In the AppDelegate:

This step required only for basic PlayKit users.

```swift
import PlayKit
import PlayKitSmartSwitch
```
in the ```application(_:didFinishLaunchingWithOptions:)``` needs to add registration plugin to PlayKit manager:
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
// Override point for customization after application launch.
PlayKitManager.shared.registerPlugin(SmartSwitchMediaEntryInterceptor.self)
return true
}
```
### Create plugin config and add it to player:
Create plugin config parameters may be different than shown on example.
```swift
import PlayKit
import KalturaPlayer
import PlayKitSmartSwitch
```

```swift
var kalturaOTTPlayer: KalturaOTTPlayer

let smartSwitchConfig = SmartSwitchConfig()
smartSwitchConfig.accountCode = "kalturatest" // Youbora account code.
smartSwitchConfig.originCode = "vod"
smartSwitchConfig.optionalParams = ["live": "false"]
smartSwitchConfig.timeout = 5 // Timeout time period for Youbora CDN balancer calls.
smartSwitchConfig.reportSelectedCDNCode = true // if true plugin will report chosen CDN code to Youbora analytics.
// smartSwitchUrl this is optional parameter. Set it if you have different Youbora CDN balancer host.
smartSwitchConfig.smartSwitchUrl = "http://cdnbalancer.youbora.com/orderedcdn"

// Add PluginConfig to KalturaPlayer
let playerOptions = PlayerOptions()
playerOptions.pluginConfig = PluginConfig(config: [SmartSwitchMediaEntryInterceptor.pluginName: smartSwitchConfig])

kalturaOTTPlayer = KalturaOTTPlayer(options: playerOptions)

```
You may need to update player with new options if needed.
```swift
kalturaOTTPlayer.updatePlayerOptions(playerOptions)
```

## Errors handling

On the ```kalturaOTTPlayer``` object you have to subscribe to an event ```SmartSwitchEvent.error``` to recieve errors rised by plugin.

```swift
kalturaOTTPlayer.addObserver(self, events: [SmartSwitchEvent.error]) { event in
            // Handle Smart Switch error here.
            if let error = event.error {
                // error here is NSError
                print(error.localizedDescription)
            }
        }
```

## License and Copyright Information

All code in this project is released under the [AGPLv3 license](http://www.gnu.org/licenses/agpl-3.0.html) unless a different license for a particular library is specified in the applicable library path.   

Copyright © Kaltura Inc. All rights reserved.   
Authors and contributors: See [GitHub contributors list](https://github.com/kaltura/playkit-ios-smartswitch/graphs/contributors).
