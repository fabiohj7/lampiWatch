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
    @Published var lamp: Lampi
    private var cancellables = Set<AnyCancellable>()
    let isOnPublisher = PassthroughSubject<Bool, Never>()
    let isFallPublisher = PassthroughSubject<Bool, Never>()
    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        self.lamp = Lampi(name: "LAMPI-b827eb9a43ca")
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
    
    var inFallDetected: AnyPublisher<Bool, Never> {
        isFallPublisher.eraseToAnyPublisher()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    func sendDataToWatch(info: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if WCSession.default.isReachable {
                WCSession.default.sendMessage(info, replyHandler: nil, errorHandler: nil)
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async { [weak self] in // Ensure execution on the main thread
            guard let self = self else { return }
            if let isOn = message["isOn"] as? Bool {
                self.isOnPublisher.send(isOn)
                print("Received isOn value from AppleWatch: \(isOn)")
            } else {
                print("Nothing received")
            }
            
            if let isFallDetected = message["isFallDetected"] as? Bool {
                self.isFallPublisher.send(isFallDetected)
                print("Received isFall value from AppleWatch: \(isFallDetected)")
            } else {
                print("Nothing received from ")
            }
        }
    }

}
