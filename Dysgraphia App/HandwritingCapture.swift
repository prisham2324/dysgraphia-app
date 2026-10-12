import Foundation
import PencilKit
import UIKit

/// Everything collected from one handwriting test.
struct HandwritingCapture {
    /// The writing as it looks on screen.
    var drawing: PKDrawing

    /// The raw movement data used for analysis.
    var strokes: [RecordedStroke]

    /// Size of the writing area.
    var canvasSize: CGSize

    /// When writing started.
    var startedAt: Date?

    /// True if nothing was written.
    var isEmpty: Bool { strokes.isEmpty }

    /// Empty sample for SwiftUI previews.
    static let preview = HandwritingCapture(
        drawing: PKDrawing(),
        strokes: [],
        canvasSize: .zero,
        startedAt: nil
    )
}

/// One stroke, from putting the pen down to lifting it.
struct RecordedStroke: Codable {
    enum InputType: String, Codable {
        case pencil
        case finger
    }

    /// Finger strokes can be excluded from analysis later.
    var inputType: InputType
    var points: [RecordedPoint]
}

/// One reading from the Pencil or finger.
struct RecordedPoint: Codable {
    /// Position on the writing area.
    var x: Double
    var y: Double

    /// Seconds since the first touch.
    var time: Double

    /// Pressure and maximum possible pressure.
    var force: Double
    var maximumForce: Double

    /// Pencil tilt and direction. Empty for a finger.
    var altitude: Double?
    var azimuth: Double?
}

/// Records touches without preventing PencilKit from drawing.
final class TouchRecorder: UIGestureRecognizer,
                           UIGestureRecognizerDelegate {
    private(set) var strokes: [RecordedStroke] = []
    private(set) var startedAt: Date?

    private var startUptime: TimeInterval?
    private var activeStrokes: [ObjectIdentifier: Int] = [:]

    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        configure()
    }

    convenience init() {
        self.init(target: nil, action: nil)
    }

    required init?(coder: NSCoder) {
        super.init(target: nil, action: nil)
        configure()
    }

    private func configure() {
        cancelsTouchesInView = false
        delaysTouchesBegan = false
        delaysTouchesEnded = false
        delegate = self
    }

    /// Wipes everything recorded so far.
    func clear() {
        strokes = []
        startedAt = nil
        startUptime = nil
        activeStrokes = [:]
    }

    /// Pen or finger goes down: start a new stroke.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        for touch in touches {
            if startUptime == nil {
                startUptime = touch.timestamp
                startedAt = Date()
            }

            let inputType: RecordedStroke.InputType =
                touch.type == .pencil ? .pencil : .finger

            activeStrokes[ObjectIdentifier(touch)] = strokes.count
            strokes.append(
                RecordedStroke(inputType: inputType, points: [])
            )
            record(touch, with: event)
        }
    }

    /// Pen or finger moves: add points to its stroke.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        touches.forEach { record($0, with: event) }
    }

    /// Pen or finger lifts: close its stroke.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        finish(touches, with: event)
    }

    /// The system interrupted the touch: close its stroke.
    override func touchesCancelled(
        _ touches: Set<UITouch>,
        with event: UIEvent
    ) {
        finish(touches, with: event)
    }

    private func finish(_ touches: Set<UITouch>, with event: UIEvent) {
        for touch in touches {
            record(touch, with: event)
            activeStrokes[ObjectIdentifier(touch)] = nil
        }

        if activeStrokes.isEmpty {
            state = .failed
        }
    }

    /// Saves all available readings for this touch.
    private func record(_ touch: UITouch, with event: UIEvent) {
        guard let index = activeStrokes[ObjectIdentifier(touch)],
              let startUptime,
              let view else {
            return
        }

        let samples = event.coalescedTouches(for: touch) ?? [touch]

        for sample in samples {
            let location = sample.preciseLocation(in: view)
            let isPencil = sample.type == .pencil

            strokes[index].points.append(
                RecordedPoint(
                    x: location.x,
                    y: location.y,
                    time: sample.timestamp - startUptime,
                    force: sample.force,
                    maximumForce: sample.maximumPossibleForce,
                    altitude: isPencil ? sample.altitudeAngle : nil,
                    azimuth: isPencil
                        ? sample.azimuthAngle(in: view)
                        : nil
                )
            )
        }
    }

    override func reset() {
        super.reset()
        activeStrokes = [:]
    }

    // Never block other gestures, including PencilKit's drawing.

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
    ) -> Bool {
        true
    }

    override func canPrevent(
        _ preventedGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        false
    }

    override func canBePrevented(
        by preventingGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        false
    }
}
