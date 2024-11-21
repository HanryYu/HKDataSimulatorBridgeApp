//
//  HealthkitManager.swift
//  HKDataSimulatorBridge
//
//  Created by Henry on 2024/11/21.
//

import SwiftUI
import Foundation
import HealthKit

class HealthkitManager: ObservableObject {
    static let shared = HealthkitManager()
    private let healthStore = HKHealthStore()
    
    private init() {}
    
    func requestAuthorization(for types: [HKTypeWrapper]) async throws {
        let typesToRead = Set(types.compactMap { $0.type })
        let typesToWrite = typesToRead
        
        try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
    }
    
    func querySamples(of type: HKSampleType, from startDate: Date, to endDate: Date) async throws -> [HKSample] {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: samples ?? [])
            }
            
            healthStore.execute(query)
        }
    }
    
    func save(_ samples: [HKSample]) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.save(samples) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                if !success {
                    continuation.resume(throwing: HealthKitError.saveFailed)
                    return
                }
                continuation.resume()
            }
        }
    }
}