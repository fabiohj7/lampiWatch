//
//  ContentView.swift
//  lampiWatch Watch App
//
//  Created by Fabio Hinojosa on 4/16/24.

import SwiftUI

struct ContentView: View {
    @StateObject var watchConnector = WatchToiOSConnector()
    @State var isOn = false
    
    var body: some View {
        VStack {
            Button(action: {
                // Toggle the values isOn
                self.isOn.toggle()
            }) {
                // Display the button text based on isOn value
                Text(isOn ? "Turn Off" : "Turn On")
                                    .padding()
                                    .foregroundColor(Color.white)
                                    .font(.headline)
            }
            .background(isOn ? Color.red : Color.green)
            .cornerRadius(25)
            .padding()
        }.ignoresSafeArea()
    }
    
    func sendToiOS(){
        watchConnector.sendInfoToIOs(isOn: isOn)
    }
}

#Preview {
    ContentView()
}
