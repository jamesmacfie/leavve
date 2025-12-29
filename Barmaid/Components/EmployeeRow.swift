//
//  EmployeeRow.swift
//  Leavve
//

import SwiftUI

struct EmployeeRow: View {
    let person: Person
    let isOnLeave: Bool

    var body: some View {
        HStack {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay(Text(person.initials).font(.caption.bold()))

            VStack(alignment: .leading, spacing: 2) {
                Text(person.fullName)
                    .font(.body)
                if isOnLeave {
                    Text("On Leave")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .contentShape(Rectangle())
    }
}
