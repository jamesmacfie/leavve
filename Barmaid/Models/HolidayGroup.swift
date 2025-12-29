//
//  HolidayGroup.swift
//  Leavve
//

import Foundation

struct HolidayGroup: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let countryCode: String
    let countryName: String?
    let regionName: String?
    let holidayIds: [Int]

    var displayName: String {
        if let region = regionName {
            return "\(name) (\(region))"
        }
        return name
    }
}
