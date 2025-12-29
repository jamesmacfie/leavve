//
//  AppSettings.swift
//  Leavve
//

import Foundation

struct AppSettings: Codable {
    var apiKey: String
    var apiServer: APIServer
    var visibleEmployeeIds: Set<Int>
    var autoRefreshTime: RefreshTime?
    var lastSyncDate: Date?

    enum APIServer: String, Codable, CaseIterable {
        case us = "https://api.us.runn.io"
        case eu = "https://api.runn.io"

        var displayName: String {
            switch self {
            case .us: return "US Server"
            case .eu: return "EU Server"
            }
        }
    }

    struct RefreshTime: Codable, Equatable, Hashable {
        let hour: Int    // 0-23
        let minute: Int  // 0-59

        var displayText: String {
            String(format: "%02d:%02d", hour, minute)
        }
    }

    static var `default`: AppSettings {
        AppSettings(
            apiKey: "",
            apiServer: .us,
            visibleEmployeeIds: [],
            autoRefreshTime: RefreshTime(hour: 7, minute: 0),
            lastSyncDate: nil
        )
    }
}
