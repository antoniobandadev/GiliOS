//
//  NetworkMonitor.swift
//  Gil
//
//  Created by Antonio Banda  on 01/05/25.
//

import Foundation
import Network

class NetworkMonitor {
    
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private var queue = DispatchQueue(label: "NetworkMonitor") //Alternative thread
    private(set) var isConnected = false
    private(set) var isExpensive = false
    private(set) var currentConnectionType = "Unknown"
    private var isMonitoringStarted = false
    
    private init() {}
    
    private var lastConnectionStatus: Bool?
    private var lastConnectionType: String?
    
    func startMonitoring() {
        guard !isMonitoringStarted else { return }

        monitor.pathUpdateHandler = { path in
            let isNowConnected = (path.status == .satisfied)
            let isNowExpensive = path.isExpensive
            let newConnectionType = self.connectionType(path: path)

            // Evita notificaciones duplicadas
            if self.lastConnectionStatus == isNowConnected && self.lastConnectionType == newConnectionType {
                return // No cambio real, no notificar
            }

            self.isConnected = isNowConnected
            self.isExpensive = isNowExpensive
            self.currentConnectionType = newConnectionType
            self.lastConnectionStatus = isNowConnected
            self.lastConnectionType = newConnectionType

            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .networkStatusChanged,
                    object: nil,
                    userInfo: [
                        "isConnected": self.isConnected,
                        "isExpensive": self.isExpensive,
                        "connectionType": self.currentConnectionType
                    ]
                )
            }
        }

        monitor.start(queue: queue)
        isMonitoringStarted = true
    }
    
    /*func startMonitoring() {
        //If monitoring already started, exit
        guard !isMonitoringStarted else {
            return
        }
        //Handler that manage connection updates
        monitor.pathUpdateHandler = { path in

            self.isConnected = (path.status == .satisfied) //Connected
            self.isExpensive = path.isExpensive
            self.currentConnectionType = self.connectionType(path: path)
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .networkStatusChanged,
                    object: nil,
                    userInfo: [
                        "isConnected" : self.isConnected,
                        "isExpensive" : self.isExpensive,
                        "connectionType" : self.currentConnectionType
                    ]
                )
            } //Dispath
        } //Handler
        monitor.start(queue: queue)
        isMonitoringStarted = true
    }*/
    
    func stopMonitoring() {
        guard isMonitoringStarted else {
            return
        }
        monitor.cancel()
        isMonitoringStarted = false
    }
    
    func connectionType(path: NWPath) -> String {
        if path.usesInterfaceType(.wifi) {
            return "WiFi"
        } else if path.usesInterfaceType(.cellular) {
            return "Cellular"
        }
        else {
            return "Unknown"
        }
    }
}
