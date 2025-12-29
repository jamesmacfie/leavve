//
//  Main.swift
//  Leavve
//
//  Created by Steven J. Selcuk on 2.05.2022.
//

import SwiftUI

struct Main: View {
    @StateObject private var appState = AppState()
    @State private var currentPage = 0

    var body: some View {
        PagerView(pageCount: 3, currentIndex: $currentPage) {
            HomeView(currentPage: $currentPage)
            EmployeeDetailView(currentPage: $currentPage)
            SettingsView(currentPage: $currentPage)
        }
        .environmentObject(appState)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .task {
            await appState.sync()
        }
    }
}
