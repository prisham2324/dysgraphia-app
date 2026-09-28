//
//  HomeView.swift
//  Dysgraphia App
//
//  Created by Prisha Mishra on 9/27/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "pencil.and.scribble")
                    .font(.system(size: 70))

                Text("Handwriting Screening")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Complete a short handwriting screening to assess writing patterns.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Text("Estimated time: 5–10 minutes")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                NavigationLink(destination: UserDetailsView()) {
                    Text("Start")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("New Record")
        }
    }
}

#Preview {
    HomeView()
}

