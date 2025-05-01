//
//  ViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 01/05/25.
//

import Foundation

import UIKit

extension UIViewController {
    
    //Create computed properties
    var isConnected: Bool {
        return NetworkMonitor.shared.isConnected
    }
    
    var connectionType: String {
        return NetworkMonitor.shared.currentConnectionType
    }
    
    var isExpensive : Bool {
        return NetworkMonitor.shared.isExpensive
    }
    
    //Suscribes to network change notification
    
    func observeConnectionChanges() {
        NotificationCenter.default.addObserver(forName: .networkStatusChanged, object: nil, queue: .main, using: { _ in
            /*DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                Utils.Snackbar.snackbarNoAction(message: self.isConnected ? "Connected" : "Not Connected", bgColor: self.isConnected ? .green : .red, duration: 6.0)
            }*/
        } )
    }
    
    
    func removeNetworkObserver() {
        NotificationCenter.default.removeObserver(self, name: .networkStatusChanged, object: nil)
    }
}
