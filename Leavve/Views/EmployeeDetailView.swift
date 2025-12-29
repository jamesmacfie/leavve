//
//  EmployeeDetailView.swift
//  Leavve
//

import SwiftUI

struct EmployeeDetailView: View {
    @EnvironmentObject var appState: AppState
    @Binding var currentPage: Int

    var selectedPerson: Person? {
        guard let personId = appState.selectedPersonId else { return nil }
        return appState.people.first(where: { $0.id == personId })
    }

    var upcomingTimeOffs: [TimeOff] {
        guard let personId = appState.selectedPersonId else { return [] }
        return appState.upcomingTimeOffs(for: personId)
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

                if let person = selectedPerson {
                    HStack(spacing: 6) {
                        Image("menubar-icon")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 14, height: 14)
                            .foregroundColor(.primary)

                        Text(person.fullName)
                            .font(.system(size: 16, design: .monospaced))
                            .fontWeight(.medium)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            if let person = selectedPerson {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Employee info
                        HStack(alignment: .top, spacing: 12) {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 48, height: 48)
                                .overlay(Text(person.initials).font(.title3.bold()))

                            VStack(alignment: .leading, spacing: 8) {
                                if let email = person.email {
                                    Text(email)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Button(action: {
                                    let baseURL = appState.settings.apiServer == .us ? "https://us.runn.io" : "https://app.runn.io"
                                    if let url = URL(string: "\(baseURL)/people/\(person.id)") {
                                        NSWorkspace.shared.open(url)
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.up.right.square")
                                            .font(.caption2)
                                        Text("View in Runn")
                                            .font(.caption)
                                    }
                                }
                                .buttonStyle(.link)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                        // Upcoming time offs
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Upcoming Time Off")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)

                            if upcomingTimeOffs.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "calendar")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("No upcoming time off")
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(Color(NSColor.controlBackgroundColor))
                                .cornerRadius(8)
                                .padding(.horizontal, 16)
                            } else {
                                ForEach(upcomingTimeOffs) { timeOff in
                                    TimeOffCard(
                                        timeOff: timeOff,
                                        holidayGroups: appState.holidayGroups,
                                        personHolidayGroupId: person.holidaysGroupId
                                    )
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer(minLength: 20)
                    }
                    .padding(.top, 8)
                }
            } else {
                Spacer()
                Text("No employee selected")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
    }
}
