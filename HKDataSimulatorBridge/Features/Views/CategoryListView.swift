//
//  CategoryListView.swift
//  HKDataSimulatorBridge
//
//  Created by Henry on 2024/11/21.
//

import SwiftUI
import HealthKit

struct CategoryListView: View {
    @StateObject private var healthKitManager = HealthkitManager.shared
    @State private var showError = false
    @State private var error: Error?
    
    var body: some View {
        List(HKCategory.categories) { category in
            NavigationLink(destination: TypeListView(category: category)) {
                VStack(alignment: .leading) {
                    Text(category.name)
                        .font(.headline)
                    Text("\(category.types.count) data types")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("HealthKit Data")
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(error?.localizedDescription ?? "Unknown error")
        }
        .task {
            do {
                // Request authorization for all types
                let allTypes = HKCategory.categories.flatMap { $0.types }
                try await healthKitManager.requestAuthorization(for: allTypes)
            } catch {
                self.error = error
                self.showError = true
            }
        }
    }
}