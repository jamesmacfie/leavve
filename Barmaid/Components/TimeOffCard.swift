//
//  TimeOffCard.swift
//  Leavve
//

import SwiftUI

struct TimeOffCard: View {
    let timeOff: TimeOff
    let holidayGroups: [HolidayGroup]
    let personHolidayGroupId: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(timeOff.type.displayName, systemImage: timeOff.type.icon)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(timeOff.durationDays) day\(timeOff.durationDays > 1 ? "s" : "")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(timeOff.dateRangeText)
                .font(.body)

            // Show holiday name if it's a public holiday
            if let holidayName = timeOff.holidayName(from: holidayGroups, personHolidayGroupId: personHolidayGroupId) {
                Text(holidayName)
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }

            if let note = timeOff.note, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}
