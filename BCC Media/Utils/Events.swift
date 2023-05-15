//
//  Events.swift
//  BCC Media
//
//  Created by Fredrik Vedvik on 15/05/2023.
//

import Foundation
import Rudder

struct Events {
    private init() {
        let config = RSConfig(writeKey: AppOptions.rudder.writeKey)
            .dataPlaneURL(AppOptions.rudder.dataPlaneUrl)
            .trackLifecycleEvents(true)
            .recordScreenViews(true)
        
        RSClient.sharedInstance().configure(with: config)
    }
    
    public static let standard = Events()
}
