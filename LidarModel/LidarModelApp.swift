//
//  LidarModelApp.swift
//  LidarModel
//
//  Created by smlab_drone on 05/05/24.
//

import SwiftUI
import ARKit

@main
struct LidarModelApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) ->Bool{
        
        if !ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth){
            print("does not support AR")
        }
        return true
    }
}
