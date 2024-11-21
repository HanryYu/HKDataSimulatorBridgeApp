//
//  DataBridgeView.swift
//  HKDataSimulatorBridge
//
//  Created by Henry on 2024/11/21.
//

import SwiftUI
import HealthKit

struct DataBridgeView: View {
    let typeWrapper: HKTypeWrapper
    @StateObject private var viewModel = DataBridgeViewModel()
    @State private var selectedTab = 0
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    @State private var endDate = Date()
    
    var body: some View {
        VStack {
            DateRangePickerView(startDate: $startDate, endDate: $endDate)
                .padding()
            
            Picker("Operation Type", selection: $selectedTab) {
                Text("Export").tag(0)
                Text("Import").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if let sampleType = typeWrapper.type {
                if selectedTab == 0 {
                    ExportView(
                        typeWrapper: typeWrapper,
                        sampleType: sampleType,
                        startDate: startDate,
                        endDate: endDate,
                        viewModel: viewModel
                    )
                } else {
                    ImportView(
                        typeWrapper: typeWrapper,
                        sampleType: sampleType,
                        viewModel: viewModel
                    )
                }
            } else {
                Text("Unsupported Data Type")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle(typeWrapper.name)
        .task {
            if let sampleType = typeWrapper.type {
                await viewModel.loadData(type: sampleType, startDate: startDate, endDate: endDate)
            }
        }
    }
}

struct SampleRowView: View {
    let sample: HKSample
    let typeWrapper: HKTypeWrapper
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(formattedValue)
                .font(.headline)
            Text("\(sample.startDate.formatted()) - \(sample.endDate.formatted())")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var formattedValue: String {
        switch typeWrapper {
        case .quantityType(let identifier):
            if let sample = sample as? HKQuantitySample {
                return formatQuantitySample(sample, for: identifier)
            }
        case .categoryType(let identifier):
            if let sample = sample as? HKCategorySample {
                return formatCategorySample(sample, for: identifier)
            }
        }
        return "Unknown Data"
    }
    
    private func formatQuantitySample(_ sample: HKQuantitySample, for identifier: HKQuantityTypeIdentifier) -> String {
        switch identifier {
        case .stepCount:
            return "\(sample.quantity.doubleValue(for: .count())) steps"
        case .distanceWalkingRunning:
            return String(format: "%.2f kilometers", sample.quantity.doubleValue(for: .meter()) / 1000)
        case .activeEnergyBurned:
            return String(format: "%.1f kilocalories", sample.quantity.doubleValue(for: .kilocalorie()))
        case .heartRate:
            return "\(Int(sample.quantity.doubleValue(for: .count().unitDivided(by: .minute())))) BPM"
        default:
            return sample.quantity.description
        }
    }
    
    private func formatCategorySample(_ sample: HKCategorySample, for identifier: HKCategoryTypeIdentifier) -> String {
        switch identifier {
        case .sleepAnalysis:
            return sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue ? "In Bed" : "Asleep"
        default:
            return "Value: \(sample.value)"
        }
    }
}

// Date Range Picker
struct DateRangePickerView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    var body: some View {
        VStack {
            DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
            DatePicker("End Date", selection: $endDate, displayedComponents: [.date])
        }
    }
}

// Export View
struct ExportView: View {
    let typeWrapper: HKTypeWrapper
    let sampleType: HKSampleType
    let startDate: Date
    let endDate: Date
    @ObservedObject var viewModel: DataBridgeViewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else {
                List(selection: $viewModel.selectedSamples) {
                    ForEach(viewModel.samples, id: \.uuid) { sample in
                        SampleRowView(sample: sample, typeWrapper: typeWrapper)
                    }
                }
                .environment(\.editMode, .constant(.active))
                
                HStack {
                    Button("Copy") {
                        if let data = viewModel.exportSelectedData() {
                            UIPasteboard.general.string = data
                        }
                    }
                    .disabled(viewModel.selectedSamples.isEmpty)
                    
                    Button("Export File") {
                        // TODO: Implement file export
                    }
                    .disabled(viewModel.selectedSamples.isEmpty)
                }
                .padding()
            }
        }
    }
}

// Import View
struct ImportView: View {
    let typeWrapper: HKTypeWrapper
    let sampleType: HKSampleType
    @ObservedObject var viewModel: DataBridgeViewModel
    @State private var showFileImporter = false
    
    var body: some View {
        VStack {
            TextEditor(text: $viewModel.importText)
                .frame(height: 200)
                .border(Color.gray, width: 1)
                .padding()
            
            if viewModel.samples.count == 1 {
                Toggle("Reset to Current Time", isOn: $viewModel.resetToCurrentTime)
                    .padding()
            }
            
            Button("Import from File") {
                showFileImporter = true
            }
            .padding()
            
            Button("Import to HealthKit") {
                Task {
                    try? await viewModel.importData(viewModel.importText, type: sampleType)
                }
            }
            .disabled(viewModel.importText.isEmpty)
            .padding()
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.json]
        ) { result in
            // TODO: Handle file import
        }
    }
}
