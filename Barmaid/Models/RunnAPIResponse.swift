//
//  RunnAPIResponse.swift
//  Leavve
//

import Foundation

struct RunnAPIResponse<T: Codable>: Codable {
    let values: [T]
    let nextCursor: String?
}
