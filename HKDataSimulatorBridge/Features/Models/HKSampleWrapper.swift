//
//  HKSampleWrapper.swift
//  HKDataSimulatorBridge
//
//  Created by Henry on 2024/11/21.
//


import HealthKit

struct HKSampleWrapper: Codable {
    let uuid: UUID
    let sampleType: String
    let startDate: Date
    let endDate: Date
    let metadata: [String: String]?
    
    // For quantity type data
    let quantity: Double?
    let unit: String?
    
    // For category type data
    let categoryValue: Int?
    
    init(from sample: HKSample) {
        self.uuid = sample.uuid
        self.sampleType = sample.sampleType.identifier
        self.startDate = sample.startDate
        self.endDate = sample.endDate
        
        // Convert metadata to string dictionary
        if let metadata = sample.metadata {
            self.metadata = metadata.mapValues { "\($0)" }
        } else {
            self.metadata = nil
        }
        
        // Handle different types of samples
        if let quantitySample = sample as? HKQuantitySample {
            let unit = HKSampleWrapper.getDefaultUnit(for: quantitySample.quantityType)
            self.quantity = quantitySample.quantity.doubleValue(for: unit)
            self.unit = unit.unitString
            self.categoryValue = nil
        } else if let categorySample = sample as? HKCategorySample {
            self.quantity = nil
            self.unit = nil
            self.categoryValue = categorySample.value
        } else {
            self.quantity = nil
            self.unit = nil
            self.categoryValue = nil
        }
    }
    
    func toHKSample() throws -> HKSample {
        let identifier = HKQuantityTypeIdentifier(rawValue: sampleType)
        let categoryIdentifier = HKCategoryTypeIdentifier(rawValue: sampleType)
        
        if let quantityType = HKQuantityType.quantityType(forIdentifier: identifier),
           let quantity = self.quantity,
           let unitString = self.unit {
            guard let unit = try? HKUnit(from: unitString) else {
                throw HealthKitError.invalidData
            }
            let quantityValue = HKQuantity(unit: unit, doubleValue: quantity)
            return HKQuantitySample(type: quantityType,
                                  quantity: quantityValue,
                                  start: startDate,
                                  end: endDate,
                                  metadata: metadata as? [String: Any])
        } else if let categoryType = HKCategoryType.categoryType(forIdentifier: categoryIdentifier),
                  let value = self.categoryValue {
            return HKCategorySample(type: categoryType,
                                  value: value,
                                  start: startDate,
                                  end: endDate,
                                  metadata: metadata as? [String: Any])
        }
        
        throw HealthKitError.invalidData
    }
    
    private static func getDefaultUnit(for quantityType: HKQuantityType) -> HKUnit {
        switch quantityType.identifier {
        case HKQuantityTypeIdentifier.stepCount.rawValue:
            return .count()
        case HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue:
            return .meter()
        case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue:
            return .kilocalorie()
        case HKQuantityTypeIdentifier.heartRate.rawValue:
            return .count().unitDivided(by: .minute())
        default:
            return .count()
        }
    }
}