//
//  TypeListView.swift
//  HKDataSimulatorBridge
//
//  Created by Henry on 2024/11/21.
//

import SwiftUI
import HealthKit

struct TypeListView: View {
    let category: HKCategory
    
    var body: some View {
        List(category.types) { typeWrapper in
            NavigationLink(destination: DataBridgeView(typeWrapper: typeWrapper)) {
                VStack(alignment: .leading) {
                    Text(typeWrapper.name)
                        .font(.headline)
                    Text(typeWrapper.id)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle(category.name)
    }
}
