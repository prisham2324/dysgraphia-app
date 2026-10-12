import PencilKit
import SwiftUI
import Observation

/// Allows finger writing for now. Change to false for Pencil-only input.
let allowsFingerWriting = true

/// Controls the writing area.
@Observable
final class HandwritingCanvasController {
    fileprivate let canvasView = PKCanvasView()
    fileprivate let recorder = TouchRecorder()

    /// True once something has been written.
    private(set) var hasWriting = false

    /// Wipes the writing and recorded data.
    func clear() {
        canvasView.drawing = PKDrawing()
        recorder.clear()
        hasWriting = false
    }

    /// Packages the writing for the next screens.
    func capture() -> HandwritingCapture {
        HandwritingCapture(
            drawing: canvasView.drawing,
            strokes: recorder.strokes.filter { !$0.points.isEmpty },
            canvasSize: canvasView.bounds.size,
            startedAt: recorder.startedAt
        )
    }

    fileprivate func drawingDidChange() {
        hasWriting = !canvasView.drawing.strokes.isEmpty
    }
}

/// Wraps PencilKit's drawing view for use in SwiftUI.
struct HandwritingCanvas: UIViewRepresentable {
    let controller: HandwritingCanvasController

    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = controller.canvasView

        canvasView.drawingPolicy =
            allowsFingerWriting ? .anyInput : .pencilOnly

        canvasView.tool = PKInkingTool(
            .pen,
            color: .black,
            width: 4
        )

        canvasView.backgroundColor = .white
        canvasView.isOpaque = true
        canvasView.isScrollEnabled = false
        canvasView.delegate = context.coordinator
        canvasView.addGestureRecognizer(controller.recorder)

        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(controller: controller)
    }

    /// Notifies the controller when the drawing changes.
    final class Coordinator: NSObject, PKCanvasViewDelegate {
        let controller: HandwritingCanvasController

        init(controller: HandwritingCanvasController) {
            self.controller = controller
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            controller.drawingDidChange()
        }
    }
}
