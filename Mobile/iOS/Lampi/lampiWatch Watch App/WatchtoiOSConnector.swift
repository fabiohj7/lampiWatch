//
//  WatchToiOSConnector.swift
//  lampiWatch Watch App
//
//  Created by Fabio Hinojosa on 4/16/24.
//

import Foundation
import WatchConnectivity

class WatchToiOSConnector: NSObject, WCSessionDelegate, ObservableObject {
    
    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sendInfoToIOs(isOn: Bool) {
        if session.isReachable {
            let data: [String: Any] = ["isOn" : isOn]
            session.sendMessage(data, replyHandler: nil)
        } else {
            print("Session is not printable")
        }
    }
}
