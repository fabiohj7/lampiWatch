//
//  WatchToiOSConnector.swift
//  lampiWatch Watch App
//
//  Created by Fabio Hinojosa on 4/16/24.

import Foundation
import WatchConnectivity

class WatchToiOSConnector: NSObject, WCSessionDelegate, ObservableObject {
    var session: WCSession
    @Published var receivedMessage: [String: Any]?
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received message from iPhone: \(message)")
        receivedMessage = message
    }
    
    
    func sendInfoToIOs(info: [String: Any]) {
        if session.isReachable {
            session.sendMessage(info, replyHandler: nil) { error in
                print(error.localizedDescription)
            }
        } else {
            print("Session is not printable")
        }
    }
}
