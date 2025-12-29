//
//  RunnAPIService.swift
//  Leavve
//

import Foundation

enum RunnAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(Int)
    case decodingError(Error)
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL"
        case .invalidResponse: return "Invalid response from server"
        case .unauthorized: return "Unauthorized - check API key"
        case .serverError(let code): return "Server error: \(code)"
        case .decodingError(let error): return "Failed to parse response: \(error.localizedDescription)"
        case .noData: return "No data received"
        }
    }
}

@MainActor
class RunnAPIService {
    private weak var appState: AppState?

    init(appState: AppState) {
        self.appState = appState
    }

    private var baseURL: String {
        appState?.settings.apiServer.rawValue ?? AppSettings.APIServer.us.rawValue
    }

    private var apiKey: String {
        appState?.settings.apiKey ?? ""
    }

    // MARK: - Generic Request

    private func request<T: Codable>(
        endpoint: String,
        cursor: String? = nil
    ) async throws -> RunnAPIResponse<T> {
        var components = URLComponents(string: "\(baseURL)\(endpoint)")
        if let cursor = cursor {
            components?.queryItems = [URLQueryItem(name: "cursor", value: cursor)]
        }

        guard let url = components?.url else {
            throw RunnAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("1.0.0", forHTTPHeaderField: "accept-version")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw RunnAPIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                return try decoder.decode(RunnAPIResponse<T>.self, from: data)
            } catch {
                throw RunnAPIError.decodingError(error)
            }
        case 401:
            throw RunnAPIError.unauthorized
        default:
            throw RunnAPIError.serverError(httpResponse.statusCode)
        }
    }

    // MARK: - Paginated Fetch

    private func fetchAll<T: Codable>(endpoint: String) async throws -> [T] {
        var allItems: [T] = []
        var cursor: String? = nil

        repeat {
            let response: RunnAPIResponse<T> = try await request(
                endpoint: endpoint,
                cursor: cursor
            )
            allItems.append(contentsOf: response.values)
            cursor = response.nextCursor
        } while cursor != nil

        return allItems
    }

    // MARK: - DTO Types (for API response mapping)

    private struct PersonDTO: Codable {
        let id: Int
        let firstName: String
        let lastName: String
        let email: String?
        let isArchived: Bool
        let teamId: Int?
        let holidaysGroupId: Int?
        let createdAt: String
        let updatedAt: String
    }

    private struct TimeOffDTO: Codable {
        let id: Int
        let personId: Int
        let startDate: String  // YYYY-MM-DD format
        let endDate: String    // YYYY-MM-DD format
        let note: String?
        let minutesPerDay: Int?
        let holidayId: Int?  // Only present for holidays
    }

    // MARK: - Date Parsing Helper

    private func parseDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString) ?? Date()
    }

    private func parseISO8601(_ dateString: String) -> Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString) ?? Date()
    }

    // MARK: - Public API

    func fetchPeople() async throws -> [Person] {
        let dtos: [PersonDTO] = try await fetchAll(endpoint: "/people/")
        return dtos.map { dto in
            Person(
                id: dto.id,
                firstName: dto.firstName,
                lastName: dto.lastName,
                email: dto.email,
                isArchived: dto.isArchived,
                teamId: dto.teamId,
                holidaysGroupId: dto.holidaysGroupId,
                createdAt: parseISO8601(dto.createdAt),
                updatedAt: parseISO8601(dto.updatedAt)
            )
        }
    }

    func fetchLeave() async throws -> [TimeOff] {
        let dtos: [TimeOffDTO] = try await fetchAll(endpoint: "/time-offs/leave/")
        return dtos.map { dto in
            TimeOff(
                id: dto.id,
                personId: dto.personId,
                startDate: parseDate(dto.startDate),
                endDate: parseDate(dto.endDate),
                note: dto.note,
                type: .leave,
                minutesPerDay: dto.minutesPerDay,
                holidayId: nil
            )
        }
    }

    func fetchHolidays() async throws -> [TimeOff] {
        let dtos: [TimeOffDTO] = try await fetchAll(endpoint: "/time-offs/holidays/")
        return dtos.map { dto in
            TimeOff(
                id: dto.id,
                personId: dto.personId,
                startDate: parseDate(dto.startDate),
                endDate: parseDate(dto.endDate),
                note: dto.note,
                type: .holiday,
                minutesPerDay: dto.minutesPerDay,
                holidayId: dto.holidayId
            )
        }
    }

    func fetchRosteredOff() async throws -> [TimeOff] {
        let dtos: [TimeOffDTO] = try await fetchAll(endpoint: "/time-offs/rostered-off/")
        return dtos.map { dto in
            TimeOff(
                id: dto.id,
                personId: dto.personId,
                startDate: parseDate(dto.startDate),
                endDate: parseDate(dto.endDate),
                note: dto.note,
                type: .rosteredOff,
                minutesPerDay: dto.minutesPerDay,
                holidayId: nil
            )
        }
    }

    func fetchHolidayGroups() async throws -> [HolidayGroup] {
        try await fetchAll(endpoint: "/holiday-groups/")
    }

    func syncAll() async throws {
        // Fetch all data in parallel
        async let peopleTask = fetchPeople()
        async let leaveTask = fetchLeave()
        async let holidaysTask = fetchHolidays()
        async let rosteredOffTask = fetchRosteredOff()
        async let holidayGroupsTask = fetchHolidayGroups()

        let (people, leave, holidays, rosteredOff, holidayGroups) = try await (
            peopleTask, leaveTask, holidaysTask, rosteredOffTask, holidayGroupsTask
        )

        // Update app state
        appState?.people = people
        appState?.timeOffs = leave + holidays + rosteredOff
        appState?.holidayGroups = holidayGroups
    }
}
