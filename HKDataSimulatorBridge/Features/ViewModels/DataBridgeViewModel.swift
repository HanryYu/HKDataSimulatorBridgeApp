//
//  DataBridgeViewModel.swift
//  HKDataSimulatorBridge
//
//  Created by Henry on 2024/11/21.
//

import SwiftUI
import HealthKit

class DataBridgeViewModel: ObservableObject {
    @Published var samples: [HKSample] = []
    @Published var selectedSamples: Set<UUID> = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var importText = ""
    @Published var resetToCurrentTime = false
    
    private let healthStore = HKHealthStore()
    
    func loadData(type: HKSampleType, startDate: Date, endDate: Date) async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let queriedSamples = try await HealthkitManager.shared.querySamples(
                of: type,
                from: startDate,
                to: endDate
            )
            
            await MainActor.run {
                samples = queriedSamples
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                isLoading = false
            }
        }
    }
    
    func exportSelectedData() -> String? {
        let selectedData = samples
            .filter { selectedSamples.contains($0.uuid) }
            .map { HKSampleWrapper(from: $0) }
        return try? JSONEncoder().encode(selectedData).base64EncodedString()
    }
    
    func importData(_ data: String, type: HKSampleType) async throws {
        guard let decodedData = Data(base64Encoded: data),
              let wrappers = try? JSONDecoder().decode([HKSampleWrapper].self, from: decodedData) else {
            throw HealthKitError.invalidData
        }
        
        let samples = try wrappers.map { try $0.toHKSample() }
        try await HealthkitManager.shared.save(samples)
    }
}
