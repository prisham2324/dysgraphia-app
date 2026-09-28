//
//  ResultView.swift
//  Dysgraphia App
//
//  Created by Prisha Mishra on 9/27/26.
//

import SwiftUI

struct ResultView: View {
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 70))
                .foregroundStyle(.green)

            Text("Screening Complete")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("No significant concerns detected in this screening.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Save Record") {
                // add SwiftData saving later
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundStyle(.white)
            .cornerRadius(12)

            Button("Download Test Data") {
                // add downloading later
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.15))
            .foregroundStyle(.primary)
            .cornerRadius(12)

            NavigationLink(destination: HomeView()) {
                Text("Take Another Test")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .foregroundStyle(.primary)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Results")
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        ResultView()
    }
}
