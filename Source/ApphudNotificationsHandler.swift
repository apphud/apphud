//
//  ApphudNotificationsHandler.swift
//  apphudTestApp
//
//  Created by Renat on 22/08/2019.
//  Copyright © 2019 softeam. All rights reserved.
//

import Foundation
import UserNotifications

internal class ApphudNotificationsHandler {
    
    static let shared = ApphudNotificationsHandler()
    
    internal func handleNotification(_ apsInfo: [AnyHashable : Any]){
        
        print("handle APS: \(apsInfo as AnyObject)")
        
        let action = apsInfo["action"] as? String
        let rule_id = apsInfo["rule_id"] as? String
        let screen_id = apsInfo["screen_id"] as? String
        
        if action == "present_purchase_screen" && rule_id != nil{
            presentPurchaseScreen(rule_id!, apsInfo, screen_id)
        }
    }
    
    private func presentPurchaseScreen(_ ruleId: String, _ userInfo: [AnyHashable : Any], _ screenID: String?){
        
        let result = ApphudInternal.shared.delegate?.apphudShouldExecuteRule?(ruleID: ruleId, userInfo: userInfo)
        if result == nil || result! == true {
            if screenID != nil {                
                ApphudScreenController.show(ruleID: ruleId, screenID: screenID!)
            }
        }
    }
}
