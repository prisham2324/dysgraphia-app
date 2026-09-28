//
//  AnalysisView.swift
//  Dysgraphia App
//
//  Created by Prisha Mishra on 9/27/26.
//

import SwiftUI

struct AnalysisView: View {
    var body: some View {
        VStack(spacing: 25) {
            Spacer()

            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 80))

            Text("Analyzing Handwriting")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("We're analyzing your handwriting sample...")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            ProgressView()
                .padding()

            NavigationLink(destination: ResultView()) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Analysis")
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        AnalysisView()
    }
}
