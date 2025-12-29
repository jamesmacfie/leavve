//
//  Person.swift
//  Leavve
//

import Foundation

struct Person: Codable, Identifiable, Hashable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String?
    let isArchived: Bool
    let teamId: Int?
    let holidaysGroupId: Int?
    let createdAt: Date
    let updatedAt: Date

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var initials: String {
        "\(firstName.prefix(1))\(lastName.prefix(1))".uppercased()
    }
}
