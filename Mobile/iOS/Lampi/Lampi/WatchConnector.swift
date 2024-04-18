//
//  WatchConnector.swift
//  Lampi
//
//  Created by Fabio Hinojosa on 4/16/24.
//

import Foundation
import UIKit
import WatchConnectivity
import Combine

class WatchConnector: NSObject, WCSessionDelegate, ObservableObject, UIApplicationDelegate {
    private var cancellables = Set<AnyCancellable>()
    let isOnPublisher = PassthroughSubject<Bool, Never>()
    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        if WCSession.isSupported(){
            session.delegate = self
            session.activate()
        } else {
            print("Watch connectivity is not supported.")
        }
        
    }
    
    var inOnPublisher: AnyPublisher<Bool, Never> {
        isOnPublisher.eraseToAnyPublisher()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let isOn = message["isOn"] as? Bool {
            isOnPublisher.send(isOn)
            print("Received isOn value from AppleWatch: \(isOn)")
        } else {
            print("Nothing received")
        }
    }
}
