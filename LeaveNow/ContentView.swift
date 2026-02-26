//
//  ContentView.swift
//  LeaveNow
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var configStore = ConfigStore.shared
    @StateObject private var monitor = MonitorService.shared
    @StateObject private var notification = NotificationService.shared

    @State private var originText: String = ""
    @State private var destinationText: String = ""
    @State private var intervalMinutes: Int = TripConfig.defaultCheckInterval
    @State private var targetMinutes: Int = TripConfig.defaultTargetMinutes
    @State private var showingAuthAlert = false
    @State private var mapPickerTarget: MapPickerTarget?
    @State private var showingRoutePreview = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Start location")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        AddressFieldWithSuggestions(
                            label: "Type to search or tap map icon",
                            text: $originText
                        ) {
                            mapPickerTarget = .origin
                        }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Destination")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        AddressFieldWithSuggestions(
                            label: "Type to search or tap map icon",
                            text: $destinationText
                        ) {
                            mapPickerTarget = .destination
                        }
                    }
                }

                Section {
                    HStack {
                        Text("Check every")
                        Spacer()
                        TextField("5", value: $intervalMinutes, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 56)
                            .padding(.vertical, 6)
                            .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 8))
                        Text("min")
                            .foregroundStyle(.secondary)
                        Stepper("", value: $intervalMinutes, in: TripConfig.minCheckInterval...TripConfig.maxCheckInterval)
                            .labelsHidden()
                    }
                    .onChange(of: intervalMinutes) { _, v in
                        intervalMinutes = min(max(v, TripConfig.minCheckInterval), TripConfig.maxCheckInterval)
                    }
                    HStack {
                        Text("Notify when ETA ≤")
                        Spacer()
                        TextField("30", value: $targetMinutes, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 56)
                            .padding(.vertical, 6)
                            .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 8))
                        Text("min")
                            .foregroundStyle(.secondary)
                        Stepper("", value: $targetMinutes, in: TripConfig.minTargetMinutes...TripConfig.maxTargetMinutes)
                            .labelsHidden()
                    }
                    .onChange(of: targetMinutes) { _, v in
                        targetMinutes = min(max(v, TripConfig.minTargetMinutes), TripConfig.maxTargetMinutes)
                    }
                } header: { Text("Reminder") }

                Section {
                    if let t = monitor.lastCheckTime {
                        Label("Last check: \(t.formatted(.dateTime.hour().minute()))", systemImage: "clock")
                    }
                    if let m = monitor.lastDurationMinutes {
                        Button {
                            showingRoutePreview = true
                        } label: {
                            HStack {
                                Label("Current ETA \(m) min", systemImage: "car")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    if let e = monitor.lastError {
                        Label(e, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                } header: { Text("Status") }

                Section {
                    Button {
                        saveAndToggleMonitoring()
                    } label: {
                        HStack {
                            Image(systemName: monitor.isMonitoring ? "stop.circle.fill" : "play.circle.fill")
                            Text(monitor.isMonitoring ? "Stop monitoring" : "Start monitoring")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(!configValid)
                }

                Section {
                    AdMobBannerView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowInsets(EdgeInsets())
                }
                }
            }
            .navigationTitle("Time to Leave")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
            .onAppear {
                syncFromStore()
            }
            .onChange(of: configStore.config) { _, _ in
                syncFromStore()
            }
            .sheet(item: $mapPickerTarget) { target in
                MapLocationPicker { address in
                    switch target {
                    case .origin: originText = address
                    case .destination: destinationText = address
                    }
                }
            }
            .alert("Notifications needed", isPresented: $showingAuthAlert) {
                Button("Open Settings", action: openSettings)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please allow notifications so we can remind you when it's time to leave.")
            }
            .sheet(isPresented: $showingRoutePreview) {
                if configValid {
                    RoutePreviewView(
                        origin: originText.trimmingCharacters(in: .whitespacesAndNewlines),
                        destination: destinationText.trimmingCharacters(in: .whitespacesAndNewlines),
                        etaMinutes: monitor.lastDurationMinutes
                    )
                }
            }
        }
    }

    private var configValid: Bool {
        !originText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !destinationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func syncFromStore() {
        let c = configStore.config
        originText = c.originAddress
        destinationText = c.destinationAddress
        intervalMinutes = c.checkIntervalMinutes
        targetMinutes = c.targetMinutes
    }

    private func saveAndToggleMonitoring() {
        configStore.update(TripConfig(
            originAddress: originText.trimmingCharacters(in: .whitespacesAndNewlines),
            destinationAddress: destinationText.trimmingCharacters(in: .whitespacesAndNewlines),
            checkIntervalMinutes: intervalMinutes,
            targetMinutes: targetMinutes
        ))

        if monitor.isMonitoring {
            monitor.stopMonitoring()
            return
        }

        Task {
            let granted = await notification.requestAuthorization()
            await notification.updateStatus()
            if granted {
                monitor.startMonitoring()
            } else {
                await MainActor.run { showingAuthAlert = true }
            }
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

private enum MapPickerTarget: String, Identifiable {
    case origin
    case destination
    var id: String { rawValue }
}

#Preview {
    ContentView()
}
