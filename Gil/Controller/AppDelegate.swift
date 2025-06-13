//
//  AppDelegate.swift
//  Gil
//
//  Created by Antonio Banda  on 26/03/25.
//

import UIKit
import MaterialComponents
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //UILabel.appearance().font = UIFont(name: "Parkinsans-Medium")
        // Aplicar la fuente globalmente a las etiquetas (UILabel)
        
        //UI global Buttont TextFields
        uiGlobalInit()
        
        //Start network monitoring
        NetworkMonitor.shared.startMonitoring()
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        //End network monitor
        NetworkMonitor.shared.stopMonitoring()
    }
    
    func uiGlobalInit(){
        
        // Font (UIButton)
        UIButton.appearance().titleLabel?.font = Constants.Fonts.font
        
        // Font (MDCOutlinedTextField)
        MDCOutlinedTextField.appearance().font = Constants.Fonts.font

        
    }

}

