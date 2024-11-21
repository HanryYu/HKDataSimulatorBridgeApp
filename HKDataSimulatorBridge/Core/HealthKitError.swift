//
//  HealthKitError.swift
//  HKDataSimulatorBridge
//
//  Created by Henry on 2024/11/21.
//

import Foundation

enum HealthKitError: LocalizedError {
    case authorizationDenied
    case dataNotAvailable
    case invalidType
    case invalidData
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "HealthKit permission not granted"
        case .dataNotAvailable:
            return "Data not available"
        case .invalidType:
            return "Invalid data type"
        case .invalidData:
            return "Invalid data"
        case .saveFailed:
            return "Failed to save data"
        }
    }
}