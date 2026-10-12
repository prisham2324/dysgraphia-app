import SwiftUI

struct HandwritingTestView: View {
    @State private var canvas = HandwritingCanvasController()
    @State private var capture: HandwritingCapture?
    @State private var showAnalysis = false

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

            // Writing area
            HandwritingCanvas(controller: canvas)
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray, lineWidth: 2)
                }
                .overlay {
                    if !canvas.hasWriting {
                        Text(
                            allowsFingerWriting
                                ? "Write here using Apple Pencil or your finger"
                                : "Write here using Apple Pencil"
                        )
                        .foregroundStyle(.secondary)
                        .allowsHitTesting(false)
                        .padding()
                    }
                }

            HStack {
                Button("Clear") {
                    canvas.clear()
                }

                Spacer()

                Button("Done") {
                    capture = canvas.capture()
                    showAnalysis = true
                }
                .fontWeight(.semibold)
                .disabled(!canvas.hasWriting)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Handwriting Test")
        .navigationDestination(isPresented: $showAnalysis) {
            if let capture {
                AnalysisView(capture: capture)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HandwritingTestView()
    }
}
