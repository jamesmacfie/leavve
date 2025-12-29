//
//  TimeOff.swift
//  Leavve
//

import Foundation

enum TimeOffType: String, Codable, CaseIterable {
    case leave = "leave"
    case holiday = "holiday"
    case rosteredOff = "rostered-off"

    var displayName: String {
        switch self {
        case .leave: return "Leave"
        case .holiday: return "Holiday"
        case .rosteredOff: return "Rostered Off"
        }
    }

    var icon: String {
        switch self {
        case .leave: return "calendar.badge.exclamationmark"
        case .holiday: return "calendar.badge.clock"
        case .rosteredOff: return "calendar"
        }
    }
}

struct TimeOff: Codable, Identifiable, Hashable {
    let id: Int
    let personId: Int
    let startDate: Date
    let endDate: Date
    let note: String?
    let type: TimeOffType
    let minutesPerDay: Int?
    let holidayId: Int?  // Only present for holiday type

    var isToday: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        return today >= start && today <= end
    }

    var isUpcoming: Bool {
        startDate > Date()
    }

    var durationDays: Int {
        (Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0) + 1
    }

    var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        if Calendar.current.isDate(startDate, inSameDayAs: endDate) {
            return formatter.string(from: startDate)
        } else {
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        }
    }

    // Get holiday name from holiday groups
    func holidayName(from groups: [HolidayGroup], personHolidayGroupId: Int?) -> String? {
        guard type == .holiday,
              let holidayId = holidayId,
              let groupId = personHolidayGroupId,
              let group = groups.first(where: { $0.id == groupId && $0.holidayIds.contains(holidayId) })
        else { return nil }
        return group.displayName
    }
}
