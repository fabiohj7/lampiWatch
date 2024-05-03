import Foundation
import HealthKit
import SwiftUI

class HealthKitManager: NSObject, ObservableObject {
    let healthStore = HKHealthStore()
    
    @Published var sleepHours: Double = 0.0
    @Published var sleepDataInfo: String = ""
    
    override init() {
           super.init()
           requestAuthorization()
    }
    
    func requestAuthorization() {
        let typesToRead: Set<HKObjectType> = [HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            if success {
                print("Authorization granted for sleep data.")
                self.querySleepData()
            } else {
                print("Authorization denied for sleep data. Error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func querySleepData() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            print("Sleep analysis data type not available.")
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            if let samples = samples as? [HKCategorySample] {
                for sample in samples {
                    let startDate = sample.startDate
                    let endDate = sample.endDate
                    let value = sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue ? "In Bed" : "Asleep"
                    let hours = (endDate.timeIntervalSince(startDate) / 3600).rounded(toPlaces: 2)
                    print("Sleep data: \(startDate) - \(endDate) - \(value)")
                    print("Sleep hours: \(hours)")
                    DispatchQueue.main.async {
                        self.sleepHours = hours
                        self.sleepDataInfo = "Sleep data: \(startDate) - \(endDate) - \(value)\nSleep hours: \(hours)"
                    }
                }
            } else {
                print("Failed to query sleep data: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        
        healthStore.execute(query)
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
