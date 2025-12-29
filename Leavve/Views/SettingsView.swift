//
//  SettingsView.swift
//  Leavve
//

import SwiftUI
import Cocoa

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Binding var currentPage: Int

    @State private var apiKey: String = ""
    @State private var selectedServer: AppSettings.APIServer = .us
    @State private var autoRefreshEnabled: Bool = true
    @State private var refreshHour: Int = 7
    @State private var refreshMinute: Int = 0

    var delegate: AppDelegate {
        NSApp.delegate as! AppDelegate
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "arrowshape.turn.up.left")
                        .font(.caption)
                    Text("Back")
                        .font(.caption)
                }
                .contentShape(Rectangle())
                .help(Text("Return to Home"))
                .accessibility(hint: Text("On click navigates to home section"))
                .onTapGesture {
                    withAnimation {
                        currentPage = 0
                    }
                }

                Spacer()

                HStack(spacing: 6) {
                    Image("menubar-icon")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 14, height: 14)
                        .foregroundColor(.primary)

                    Text("Settings")
                        .font(.system(size: 16, design: .monospaced))
                        .fontWeight(.medium)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // API Configuration
                    VStack(alignment: .leading, spacing: 8) {
                        Text("API Configuration")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        SecureField("API Key", text: $apiKey)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: apiKey) { newValue in
                                var newSettings = appState.settings
                                newSettings.apiKey = newValue
                                appState.updateSettings(newSettings)
                            }

                        Picker("Server", selection: $selectedServer) {
                            ForEach(AppSettings.APIServer.allCases, id: \.self) { server in
                                Text(server.displayName).tag(server)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: selectedServer) { newValue in
                            var newSettings = appState.settings
                            newSettings.apiServer = newValue
                            appState.updateSettings(newSettings)
                        }
                    }
                    .padding(.horizontal, 16)

                    // Auto Refresh
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Auto Refresh", isOn: $autoRefreshEnabled)
                            .onChange(of: autoRefreshEnabled) { newValue in
                                if newValue {
                                    let refreshTime = AppSettings.RefreshTime(hour: refreshHour, minute: refreshMinute)
                                    appState.updateAutoRefreshTime(refreshTime)
                                } else {
                                    appState.updateAutoRefreshTime(nil)
                                }
                            }

                        if autoRefreshEnabled {
                            HStack(spacing: 8) {
                                Text("Time:")
                                    .font(.body)

                                Picker("Hour", selection: $refreshHour) {
                                    ForEach(0..<24, id: \.self) { hour in
                                        Text(String(format: "%02d", hour)).tag(hour)
                                    }
                                }
                                .frame(width: 120)
                                .onChange(of: refreshHour) { newValue in
                                    let refreshTime = AppSettings.RefreshTime(hour: newValue, minute: refreshMinute)
                                    appState.updateAutoRefreshTime(refreshTime)
                                }

                                Text(":")
                                    .font(.body)

                                Picker("Minute", selection: $refreshMinute) {
                                    ForEach([0, 15, 30, 45], id: \.self) { minute in
                                        Text(String(format: "%02d", minute)).tag(minute)
                                    }
                                }
                                .frame(width: 120)
                                .onChange(of: refreshMinute) { newValue in
                                    let refreshTime = AppSettings.RefreshTime(hour: refreshHour, minute: newValue)
                                    appState.updateAutoRefreshTime(refreshTime)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    // Last sync
                    if let lastSync = appState.settings.lastSyncDate {
                        Text("Last sync: \(lastSync.formatted(.relative(presentation: .named)))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                    }

                    // Quit button
                    Button(action: {
                        delegate.quit()
                    }) {
                        HStack {
                            Image(systemName: "power")
                            Text("Quit App")
                        }
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .padding(.top, 8)
            }
        }
        .onAppear {
            // Load current settings
            apiKey = appState.settings.apiKey
            selectedServer = appState.settings.apiServer
            if let refreshTime = appState.settings.autoRefreshTime {
                autoRefreshEnabled = true
                refreshHour = refreshTime.hour
                refreshMinute = refreshTime.minute
            } else {
                autoRefreshEnabled = false
            }
        }
    }
}
