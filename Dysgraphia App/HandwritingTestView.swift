//
//  HandwritingTestView.swift
//  Dysgraphia App
//
//  Created by Prisha Mishra on 9/27/26.
//

import SwiftUI

struct HandwritingTestView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Handwriting Test")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Write the following sentence:")
                .foregroundStyle(.secondary)

            Text("The quick brown fox jumps over the lazy dog.")
                .font(.headline)
                .multilineTextAlignment(.center)

            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 2)
                .frame(height: 300)
                .overlay {
                    Text("Writing Area")
                        .foregroundStyle(.secondary)
                }

            HStack {
                Button("Clear") {
                    //
                }

                Spacer()

                NavigationLink(destination: AnalysisView()) {
                    Text("Done")
                        .fontWeight(.semibold)
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Handwriting Test")
    }
}

#Preview {
    NavigationStack {
        HandwritingTestView()
    }
}
