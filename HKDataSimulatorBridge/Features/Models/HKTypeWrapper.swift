//
//  HKTypeWrapper.swift
//  HKDataSimulatorBridge
//
//  Created by Henry on 2024/11/21.
//

import HealthKit

enum HKTypeWrapper: Identifiable {
    case quantityType(HKQuantityTypeIdentifier)
    case categoryType(HKCategoryTypeIdentifier)
    
    var id: String {
        switch self {
        case .quantityType(let identifier):
            return identifier.rawValue
        case .categoryType(let identifier):
            return identifier.rawValue
        }
    }
    
    var name: String {
        switch self {
        case .quantityType(let identifier):
            return identifier.localizedName
        case .categoryType(let identifier):
            return identifier.localizedName
        }
    }
    
    var type: HKSampleType? {
        switch self {
        case .quantityType(let identifier):
            return HKQuantityType(identifier)
        case .categoryType(let identifier):
            return HKCategoryType(identifier)
        }
    }
}

extension HKQuantityTypeIdentifier {
    var localizedName: String {
        switch self {
        case .stepCount: return "Step Count"
        case .distanceWalkingRunning: return "Walking and Running Distance"
        case .activeEnergyBurned: return "Active Energy"
        case .height: return "Height"
        case .bodyMass: return "Body Mass"
        case .bodyFatPercentage: return "Body Fat Percentage"
        case .heartRate: return "Heart Rate"
        case .bloodPressureSystolic: return "Systolic Blood Pressure"
        case .bloodPressureDiastolic: return "Diastolic Blood Pressure"
        case .bodyTemperature: return "Body Temperature"
        case .flightsClimbed: return "Flights Climbed"
        case .distanceCycling: return "Cycling Distance"
        case .pushCount: return "Wheelchair Push Count"
        case .swimmingStrokeCount: return "Swimming Stroke Count"
        case .heartRateVariabilitySDNN: return "Heart Rate Variability"
        case .restingHeartRate: return "Resting Heart Rate"
        case .walkingHeartRateAverage: return "Walking Average Heart Rate"
        case .oxygenSaturation: return "Oxygen Saturation"
        case .respiratoryRate: return "Respiratory Rate"
        default: return self.rawValue
        }
    }
}

extension HKCategoryTypeIdentifier {
    var localizedName: String {
        switch self {
        case .sleepAnalysis: return "Sleep Analysis"
        default: return self.rawValue
        }
    }
}