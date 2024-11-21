//
//  HKCategory.swift
//  HKDataSimulatorBridge
//
//  Created by Henry on 2024/11/21.
//

import HealthKit

struct HKCategory: Identifiable {
    let id: String
    let name: String
    let types: [HKTypeWrapper]
    
    static let categories: [HKCategory] = [
        HKCategory(id: "activity", name: "Activity", types: [
            .quantityType(.stepCount),
            .quantityType(.distanceWalkingRunning),
            .quantityType(.activeEnergyBurned),
            .quantityType(.flightsClimbed),
            .quantityType(.distanceCycling),
            .quantityType(.swimmingStrokeCount)
        ]),
        HKCategory(id: "body", name: "Body Measurements", types: [
            .quantityType(.height),
            .quantityType(.bodyMass),
            .quantityType(.bodyFatPercentage)
        ]),
        HKCategory(id: "vitals", name: "Vital Signs", types: [
            .quantityType(.heartRate),
            .quantityType(.heartRateVariabilitySDNN),
            .quantityType(.bloodPressureSystolic),
            .quantityType(.bloodPressureDiastolic),
            .quantityType(.bodyTemperature),
            .quantityType(.oxygenSaturation),
            .quantityType(.respiratoryRate)
        ]),
        HKCategory(id: "sleep", name: "Sleep", types: [
            .categoryType(.sleepAnalysis)
        ])
    ]
}