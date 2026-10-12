import SwiftUI

struct AnalysisView: View {
    let capture: HandwritingCapture

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

            NavigationLink(destination: ResultView(capture: capture)) {
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
        AnalysisView(capture: .preview)
    }
}
