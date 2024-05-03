//
//  LampiApp.swift
//  Lampi
//

import SwiftUI

@main
struct LampiApp: App {
    @StateObject var manager = HealthKitManager()
    let DEVICE_NAME = "LAMPI-b827eb9a43ca"
    let USE_BROWSER = false

    var body: some Scene {
        WindowGroup {
            if USE_BROWSER {
                LampiBrowserView()
            } else {
                LampiView(lamp: Lampi(name: DEVICE_NAME))
            }
        }
    }
}
