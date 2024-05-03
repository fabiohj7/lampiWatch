//
//  ContentView.swift
//  lampiWatch Watch App
//
//  Created by Fabio Hinojosa on 4/16/24.

import SwiftUI
import CoreMotion

struct ContentView: View {
    @State private var isFallDetected = false
    @State private var showingAlert = false
    @StateObject var watchConnector = WatchToiOSConnector()
    @State var isOn = false
    @State var hue = 0.0
    @State private var color = Color.red
    
    let motionManager = CMMotionManager()
    
    var body: some View {
        VStack {
            Rectangle().fill(color)
                .cornerRadius(30)
            Spacer()
            Button(action: {
                // Toggle the values isOn
                self.isOn.toggle()
                sendToiOS()
            }) {
                // Display the button text based on isOn value
                Text(isOn ? "OFF" : "ON")
                                    .padding()
                                    .foregroundColor(Color.white)
                                    .font(.headline)
            }
            .background(isOn ? Color.red : Color.green)
            .cornerRadius(25)
            .padding(40)
            .onAppear {
                startAccelerometerUpdates()
            }.alert(isPresented: $showingAlert){
                Alert(
                    title: Text("Fall Detected"),
                    message: Text("A fall has been detected, Are you Okay?"),
                    dismissButton: .default(Text("I'm Fine!")){
                        isFallDetected = false
                        sendToiOS()
                    }
                )
            }
        }.ignoresSafeArea()
            .onReceive(watchConnector.$receivedMessage) { message in
                guard let message = message else {return}
                if let hueS = message["hue"] as? Color {
                    //let hueColor = Color(hue: hueS / 360.0, saturation: 1.0, brightness: 1.0)
                        self.color = hueS
                    }
                if let isOn = message["isOn"] as? Bool {
                    self.isOn = isOn
                }
                
            }
    }
    
    func sendToiOS(){
        watchConnector.sendInfoToIOs(info: ["isFallDetected": isFallDetected, "isOn": isOn])
    }
    
    func startAccelerometerUpdates() {
            if motionManager.isAccelerometerAvailable {
                motionManager.accelerometerUpdateInterval = 0.1  // Set update interval as needed
                motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
                    if let error = error {
                        print("Error receiving accelerometer data: \(error.localizedDescription)")
                    } else if let acceleration = data?.acceleration {
                        // Simple fall detection based on vertical acceleration
                        let verticalAcceleration = acceleration.z
                        if verticalAcceleration < -2.5 && !self.isFallDetected { // Threshold, adjust as needed
                            self.isFallDetected = true
                            self.showingAlert = true
                            sendToiOS()
                        }
                    }
                }
            } else {
                print("Accelerometer is not available")
            }
        }
}

#Preview {
    ContentView()
}
