//
//  LOPCManager.swift
//  Pods
//
//  Created by Rafael Costa on 6/22/16.
//
//

import UIKit

let IS_IPAD = UIDevice.currentDevice().userInterfaceIdiom == .Pad
let IS_IPHONE = UIDevice.currentDevice().userInterfaceIdiom == .Phone
let IS_RETINA = UIScreen.mainScreen().scale >= 2.0

let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height
let SCREEN_MAX_LENGTH = max(SCREEN_WIDTH, SCREEN_HEIGHT)
let SCREEN_MIN_LENGTH = min(SCREEN_WIDTH, SCREEN_HEIGHT)

let IS_IPHONE_4_OR_LESS = (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
let IS_IPHONE_5 = (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
let IS_IPHONE_6 = (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
let IS_IPHONE_6P = (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

let __shared__Manager = LOPCManager()

public class LOPCManager {
    
    private var deviceToken = ""
    private var hasSetDeviceToken = false
    
    public var instanceURL = ""
    public var appId = ""
    public var appClientToken = ""
    
    public var devicePayload = Dictionary<String, String>()
    
    public class func shared() -> LOPCManager {
        return __shared__Manager
    }
    
    public func setDeviceToken(_ deviceToken: String) {
        if self.hasSetDeviceToken == true {
            print("Warning: trying to set deviceToken of LOPC after it has already been set.")
            return
        }
        
        self.deviceToken = deviceToken
        self.hasSetDeviceToken = true
    }
    
    public func updateServerData(withCallback callback: ((NSError?) -> Void)?) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://\(self.instanceURL)/device?appId=\(self.appId)")!)
        request.HTTPMethod = "POST"
        request.setValue("device", forHTTPHeaderField: "x-authorizzation-type")
        request.setValue(self.appClientToken, forHTTPHeaderField: "x-app-client-token")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var deviceType = "UNKNOWN_IPHONEOS"
        
        if IS_IPHONE_4_OR_LESS {
            deviceType = "iPhone3,5"
        } else if IS_IPHONE_5 {
            deviceType = "iPhone4,0"
        } else if IS_IPHONE_6 {
            deviceType = "iPhone4,7"
        } else if IS_IPHONE_6P {
            deviceType = "iPhone5,5"
        }
        
        if IS_IPAD {
            deviceType = "iPad0,0"
            if !IS_RETINA {
                deviceType = deviceType + "-nonRetina"
            }
        }
        
        let dictionary = [
            "deviceType"        : deviceType,
            "deviceOS"          : UIDevice.currentDevice().systemName,
            "deviceOSVersion"   : "" + UIDevice.currentDevice().systemVersion,
            "deviceToken"       : self.deviceToken,
            "devicePayload"     : self.devicePayload
        ]
        
        
        let json = try! NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions.PrettyPrinted)
        
        request.HTTPBody = json
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if error != nil {
                callback?(error!)
            } else {
                callback?(nil)
            }
        }.resume()
    }
}
