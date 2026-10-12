import SwiftUI

struct ResultView: View {
    let capture: HandwritingCapture

    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 70))
                .foregroundStyle(.green)

            Text("Screening Complete")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Your handwriting sample has been collected.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Text("Recorded strokes: \(capture.strokes.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Save Record") {
                // SwiftData saving will be added later.
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundStyle(.white)
            .cornerRadius(12)

            Button("Download Test Data") {
                // Data export will be added later.
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
        ResultView(capture: .preview)
    }
}
