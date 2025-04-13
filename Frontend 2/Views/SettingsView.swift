//
//  SettingsView.swift
//  
//
//  Created by Dylan Geraci on 4/13/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("timeLimit") var timeLimit: Int = 600
    @State private var selectedApps: [String] = []
    private let availableApps = ["TikTok", "Instagram", "YouTube", "Reddit", "X"] // add more as needed

    var body: some View {
        Form {
            Section(header: Text("Time Limit")) {
                Stepper(value: $timeLimit, in: 60...3600, step: 60) {
                    Text("Limit: \(timeLimit / 60) minutes")
                }
            }

            Section(header: Text("Tracked Apps")) {
                List {
                    ForEach(availableApps, id: \.self) { app in
                        Toggle(app, isOn: Binding(
                            get: { selectedApps.contains(app) },
                            set: { isOn in
                                if isOn {
                                    if selectedApps.count < 50 {
                                        selectedApps.append(app)
                                    }
                                } else {
                                    selectedApps.removeAll { $0 == app }
                                }
                            }
                        ))
                    }
                }
            }

            if selectedApps.count >= 50 {
                Text("You can only track up to 50 apps.")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
