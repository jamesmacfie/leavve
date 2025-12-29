//
//  HomeView.swift
//  Leavve
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @Binding var currentPage: Int

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Leavve")
                        .font(.system(size: 20, design: .monospaced))
                        .fontWeight(.medium)

                    Spacer()

                    Button(action: {
                        Task {
                            await appState.sync()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .disabled(appState.isLoading)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)

                // Error message
                if let error = appState.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // On Leave Today section
                        if !appState.peopleOnLeaveToday.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("On Leave Today")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 16)

                                ForEach(appState.peopleOnLeaveToday, id: \.person.id) { item in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.person.fullName)
                                            .font(.body)
                                        HStack(spacing: 4) {
                                            Image(systemName: item.timeOff.type.icon)
                                                .font(.caption2)
                                            Text(item.timeOff.type.displayName)
                                                .font(.caption)
                                            Text("•")
                                                .font(.caption)
                                            Text("\(item.timeOff.durationDays) day\(item.timeOff.durationDays > 1 ? "s" : "")")
                                                .font(.caption)
                                        }
                                        .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(NSColor.controlBackgroundColor))
                                }
                            }
                        } else if appState.settings.apiKey.isEmpty {
                            Text("Configure API key in Settings to sync data")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                        } else if !appState.isLoading {
                            Text("Nobody on leave today")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                        }

                        // All Employees section
                        if !appState.visiblePeople.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("All Employees")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 16)

                                ForEach(appState.visiblePeople) { person in
                                    let isOnLeave = appState.peopleOnLeaveToday.contains(where: { $0.person.id == person.id })

                                    EmployeeRow(person: person, isOnLeave: isOnLeave)
                                        .onTapGesture {
                                            withAnimation {
                                                appState.selectedPersonId = person.id
                                                currentPage = 1
                                            }
                                        }
                                }
                            }
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.top, 8)
                }

                // Settings button
                HStack {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .font(.caption)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .help(Text("App Settings"))
                .accessibility(hint: Text("On click navigates to settings section"))
                .onTapGesture {
                    withAnimation {
                        currentPage = 2
                    }
                }
            }

            // Loading overlay
            if appState.isLoading {
                LoadingOverlay()
            }
        }
    }
}
