//  LampiView.swift
//  Lampi

import SwiftUI
import Combine

struct LampiView: View {
    @Bindable var lamp: Lampi
    @StateObject var watchConnector = WatchConnector()
    @StateObject var healthKitManager = HealthKitManager()
    @State private var isOn = false
    @State private var isFallDetected = false
    @State private var isFlashing = false
    private var cancellables = Set<AnyCancellable>()
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    init(lamp: Lampi) {
        self._lamp = Bindable(lamp)
    }
    
    @State private var sleepDataInfo: String = ""
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(lamp.state.color)
                    .edgesIgnoringSafeArea(.top)
                Text("\(lamp.state.isConnected ? "Connected" : "Disconnected")")
                    .foregroundColor(.white)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: .infinity)
                        .fill(Color(white: 0.25, opacity: 0.5)))
                    .padding()
                    .onAppear {
                        healthKitManager.requestAuthorization()
                    }
            }
            
            VStack(alignment: .center, spacing: 20) {
                Text("Sleep Data Information")
                                    .font(.title)
                                    .padding(.top)
                                
                Text(healthKitManager.sleepDataInfo)
                                    .multilineTextAlignment(.center)
                                    .padding()
                
                GradientSlider(value: $lamp.state.hue,
                               handleColor: lamp.state.baseHueColor,
                               trackColors: Color.rainbow()) { _ in
                    sendToWatchOS()
                }
                
                GradientSlider(value: $lamp.state.saturation,
                               handleColor: Color(hue: lamp.state.hue,
                                                  saturation: lamp.state.saturation,
                                                  brightness: 1.0),
                               trackColors: [.white, lamp.state.baseHueColor])
                
                GradientSlider(value: $lamp.state.brightness,
                               handleColor: Color(white: lamp.state.brightness),
                               handleImage: Image(systemName: "sun.max"),
                               trackColors: [.black, .white])
                .foregroundColor(Color(white: 1.0 - lamp.state.brightness))
            }.padding(.horizontal)
            
            Button(action: {
                // Change toggle locally
                isOn.toggle()
                
                // Update lamp's isOn property
                lamp.state.isOn = !lamp.state.isOn
                sendToWatchOS()
            }) {
                HStack {
                    Spacer()
                    Image(systemName: "power")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Spacer()
                }.padding()
            }
            .foregroundColor(lamp.state.isOn ? lamp.state.color : .gray)
            .background(Color.black.edgesIgnoringSafeArea(.bottom))
            .frame(height: 100)
            .onReceive(watchConnector.isOnPublisher.receive(on: DispatchQueue.main)) { isOnFromWatch in
                // Update isOn based on message received from Watch
                DispatchQueue.main.async{
                    isOn = isOnFromWatch
                }
                // Update lamp's isOn property
                lamp.state.isOn = isOn
            }
            .onReceive(watchConnector.isFallPublisher.receive(on: DispatchQueue.main)) { isFallDetectedFromWatch in
                isFallDetected = isFallDetectedFromWatch
                
                if isFallDetected {
                    isFallDetected = isFallDetectedFromWatch
                    startFlashing()
                    print("Fall detected!")
                } else {
                    stopFlashing()
                    print("Fall detected stopped!")
                }
            }
        }
        .disabled(!lamp.state.isConnected)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action : {
            self.mode.wrappedValue.dismiss()
        }){
            Image(systemName: "arrow.left")
                .foregroundColor(.white)
                .shadow(radius: 2.0)
        })
        .onReceive(healthKitManager.$sleepHours) { sleepHours in
                    // Update lamp color based on sleep hours
                    if sleepHours >= 8 {
                        lamp.state.hue = 0.3
                        lamp.state.isOn = true
                    } else if sleepHours <= 4 {
                        lamp.state.hue = 0
                        lamp.state.isOn = true

                    } else {
                        lamp.state.hue = 0.15
                        lamp.state.isOn = true

                    }
                }
    }
    
    func startFlashing() {
        isFlashing = true
        startColorSwitching()
        print("FLASHING")
    }
    func stopFlashing() {
        isFlashing = false
        print("STOP")
    }
    
    func colorSwitching() {
        lamp.state.hue = 1
        lamp.state.saturation = 1
        lamp.state.brightness = (lamp.state.brightness == 0) ? 1 : 0
        lamp.state.isOn = true
    }
    
    func startColorSwitching() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            
            if !isFallDetected {
                timer.invalidate()
                stopFlashing()
            } else {
                colorSwitching()
            }
        }
    }
    
    func sendToWatchOS() {
        watchConnector.sendDataToWatch(info: ["isOn": lamp.state.isOn])
    }
}

#Preview {
    LampiView(lamp: Lampi(name: "LAMPI_b827eb974fee"))
        .previewDevice("iPhone 15 Pro")
        .previewLayout(.device)
}
