//
//  LoadingOverlay.swift
//  Leavve
//

import SwiftUI

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                Text("Syncing...")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding(20)
            .background(Color.black.opacity(0.7))
            .cornerRadius(12)
        }
    }
}
