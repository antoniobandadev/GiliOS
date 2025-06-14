//
//  ViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 01/05/25.
//

import Foundation

import UIKit

private var networkObserver: NSObjectProtocol?

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
    
    /*func observeConnectionChanges(onChange: ((Bool) -> Void)? = nil) {
        NotificationCenter.default.addObserver(forName: .networkStatusChanged, object: nil, queue: .main, using: { _ in
            let connected = self.isConnected
            /*DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                Utils.Snackbar.snackbarNoAction(message: self.isConnected ? "Connected" : "Not Connected", bgColor: self.isConnected ? .green : .red, duration: 6.0)
            }*/
            onChange?(connected)
        })
    }
    func observeConnectionChanges(onChange: @escaping (Bool) -> Void) {
            NotificationCenter.default.addObserver(forName: .networkStatusChanged, object: nil, queue: .main) { _ in
                let connected = NetworkMonitor.shared.isConnected
                onChange(connected)
            }
        }*/
    
    
    
    func observeConnectionChanges(onChange: ((Bool) -> Void)? = nil) {
        networkObserver = NotificationCenter.default.addObserver(
            forName: .networkStatusChanged,
            object: nil,
            queue: .main) { [weak self] _ in
                let isConnected = self?.isConnected ?? false
                onChange?(isConnected)
            }
    }

    
    
    func removeNetworkObserver() {
        NotificationCenter.default.removeObserver(self, name: .networkStatusChanged, object: nil)
    }
}
