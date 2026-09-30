# Guide: Add handwriting capture to the Handwriting Test screen

## What you'll build

At the moment the Handwriting Test screen shows an empty box. When you've finished this guide:

- the child can **write** in the box (with a finger for now, Apple Pencil later)
- **Clear** wipes the box
- **Done** only works once something has been written
- the app **records every point** of the writing (position, time, pressure and tilt) so we can analyse it later

You'll create **2 new files** and change **3 existing files**. It should take about 1 hour.

## Before you start

- Open `Dysgraphia App.xcodeproj` in Xcode.
- Make sure the app builds (press **Cmd + B**).
- Some key words you'll see:
  - **PencilKit** - Apple's ready-made drawing tool. It draws the ink for us.
  - **Stroke** - one line of writing, from putting the pen down to lifting it up.
  - **Point** - one tiny reading along a stroke. An Apple Pencil sends up to 240 of these a second.

> **Tip:** Copy the code in this guide exactly, including the comments. At the end you'll run a check that confirms your files match.

---

## Step 1 - Create `HandwritingCapture.swift` (the recorder)

This file holds the **data** we collect, plus a **recorder** that quietly notes every touch.

**Create the file:**

1. In the Project navigator (left panel), right-click the **Dysgraphia App** folder (the yellow one, with `HomeView.swift` inside it).
2. Choose **New File from Template... > Swift File**, then click **Next**.
3. Name it `HandwritingCapture`, make sure the **Dysgraphia App** target is ticked, then click **Create**.
4. Xcode adds a few lines of its own. **Select everything in the file (Cmd + A) and delete it**, then paste in this code:

```swift
//
//  HandwritingCapture.swift
//  Dysgraphia App
//
//  The data collected from a handwriting test, and the recorder that collects it.
//

import Foundation
import PencilKit
import UIKit

/// Everything collected from one handwriting test.
struct HandwritingCapture {
    /// The writing as it looks on screen. Used to show the writing back later.
    var drawing: PKDrawing
    /// The raw movement data. Used for analysis.
    var strokes: [RecordedStroke]
    /// Size of the writing area, so positions can be understood later.
    var canvasSize: CGSize
    /// When the child started writing.
    var startedAt: Date?

    /// True if nothing was written.
    var isEmpty: Bool { strokes.isEmpty }

    /// Empty sample for SwiftUI previews.
    static let preview = HandwritingCapture(drawing: PKDrawing(), strokes: [], canvasSize: .zero, startedAt: nil)
}

/// One stroke: from putting the pen (or finger) down to lifting it up.
struct RecordedStroke: Codable {
    enum InputType: String, Codable {
        case pencil
        case finger
    }

    /// What wrote this stroke. Finger strokes should be left out of analysis.
    var inputType: InputType
    var points: [RecordedPoint]
}

/// A single reading from the Pencil or finger.
struct RecordedPoint: Codable {
    /// Position on the writing area, in points. (0, 0) is the top-left corner.
    var x: Double
    var y: Double
    /// Seconds since the first touch of the test.
    var time: Double
    /// How hard the Pencil is pressing. Always 0 for a finger.
    var force: Double
    /// Highest possible force on this device. Divide `force` by this to get 0-1.
    var maximumForce: Double
    /// Pencil tilt in radians: 0 is flat, pi/2 is upright. Empty for a finger.
    var altitude: Double?
    /// Direction the Pencil points, in radians. Empty for a finger.
    var azimuth: Double?
}

/// Quietly records every touch on the writing area.
///
/// It watches touches but never takes them over, so PencilKit still draws the ink as normal.
final class TouchRecorder: UIGestureRecognizer, UIGestureRecognizerDelegate {
    private(set) var strokes: [RecordedStroke] = []
    private(set) var startedAt: Date?

    /// Device time of the first touch. Point times are measured from here.
    private var startUptime: TimeInterval?
    /// Touches still on the screen, and which stroke each one is adding to.
    private var activeStrokes: [ObjectIdentifier: Int] = [:]

    init() {
        super.init(target: nil, action: nil)
        // Let touches pass straight through to PencilKit, with no delay.
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
            let inputType: RecordedStroke.InputType = touch.type == .pencil ? .pencil : .finger
            activeStrokes[ObjectIdentifier(touch)] = strokes.count
            strokes.append(RecordedStroke(inputType: inputType, points: []))
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

    /// The system interrupted the touch (for example, a phone call): close its stroke.
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        finish(touches, with: event)
    }

    private func finish(_ touches: Set<UITouch>, with event: UIEvent) {
        for touch in touches {
            record(touch, with: event)
            activeStrokes[ObjectIdentifier(touch)] = nil
        }
        // Once all touches are up, step aside so the recorder is ready for the next stroke.
        // It never "recognises", so PencilKit keeps full control of drawing.
        if activeStrokes.isEmpty {
            state = .failed
        }
    }

    /// Saves every reading for this touch since the last update.
    private func record(_ touch: UITouch, with event: UIEvent) {
        guard let index = activeStrokes[ObjectIdentifier(touch)],
              let startUptime,
              let view else { return }

        // The screen refreshes slower than the Pencil reports (up to 240 times a second).
        // Coalesced touches give us all the in-between readings too.
        let samples = event.coalescedTouches(for: touch) ?? [touch]
        for sample in samples {
            let location = sample.preciseLocation(in: view)
            let isPencil = sample.type == .pencil
            strokes[index].points.append(RecordedPoint(
                x: location.x,
                y: location.y,
                time: sample.timestamp - startUptime,
                force: sample.force,
                maximumForce: sample.maximumPossibleForce,
                altitude: isPencil ? sample.altitudeAngle : nil,
                azimuth: isPencil ? sample.azimuthAngle(in: view) : nil
            ))
        }
    }

    /// Called by the system after each gesture. Keeps the strokes, forgets touches in progress.
    override func reset() {
        super.reset()
        activeStrokes = [:]
    }

    // MARK: Never block other gestures (including PencilKit's drawing)

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        true
    }

    override func canPrevent(_ preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
        false
    }

    override func canBePrevented(by preventingGestureRecognizer: UIGestureRecognizer) -> Bool {
        false
    }
}
```

**What this code does:**

| Part | What it does |
|---|---|
| `HandwritingCapture` | Everything from one test: the picture of the writing (`drawing`), the raw data (`strokes`), the size of the box and the start time. |
| `RecordedStroke` | One stroke. It remembers whether a Pencil or a finger made it, because finger strokes are less useful for screening. |
| `RecordedPoint` | One reading: `x`, `y`, `time`, `force` (pressure), `altitude` (tilt) and `azimuth` (direction). The last two are `nil` (empty) for a finger. |
| `TouchRecorder` | A `UIGestureRecognizer`. Normally these detect taps or swipes, but this one just **listens** to touches and writes them down. |
| `touchesBegan / Moved / Ended` | UIKit calls these when the finger goes down, moves and lifts. Down starts a new stroke, and moving adds points to it. |
| `coalescedTouches` | The screen refreshes more slowly than the Pencil reports. This gives us the readings between screen updates too, so no data is lost. |
| `cancelsTouchesInView = false` and the three methods at the bottom | These make sure the recorder **never blocks** PencilKit, so the ink still draws normally. |
| `state = .failed` | Tells UIKit "I'm not a real gesture", so the recorder resets and is ready for the next stroke. |

---

## Step 2 - Create `HandwritingCanvas.swift` (the writing box)

This file puts Apple's PencilKit drawing view on screen and connects it to the recorder from Step 1.

**Create the file** the same way as Step 1, but name it `HandwritingCanvas`. Delete everything Xcode added, then paste in:

```swift
//
//  HandwritingCanvas.swift
//  Dysgraphia App
//
//  The writing area on the Handwriting Test screen.
//

import PencilKit
import SwiftUI

/// Temporary: lets fingers write until we have an Apple Pencil.
/// Set to `false` to make the writing area Pencil-only (fingers and the palm are then ignored).
let allowsFingerWriting = true

/// Lets the screen control the writing area: clear it, and read back what was written.
@Observable
final class HandwritingCanvasController {
    /// Apple's drawing view. It draws the ink.
    fileprivate let canvasView = PKCanvasView()
    /// Records the raw movement data alongside the ink.
    fileprivate let recorder = TouchRecorder()

    /// True once something is written. The screen uses it to enable Done and hide the hint.
    private(set) var hasWriting = false

    /// Wipes the writing and the recorded data.
    func clear() {
        canvasView.drawing = PKDrawing()
        recorder.clear()
        hasWriting = false
    }

    /// Packs up everything written so far, ready for the next screens.
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

/// Wraps Apple's PencilKit drawing view so it can be used in SwiftUI.
struct HandwritingCanvas: UIViewRepresentable {
    let controller: HandwritingCanvasController

    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = controller.canvasView
        canvasView.drawingPolicy = allowsFingerWriting ? .anyInput : .pencilOnly
        // A plain black pen, like writing on paper.
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 4)
        canvasView.backgroundColor = .white
        canvasView.isOpaque = true
        // The page stays still, so positions are always measured on the same area.
        canvasView.isScrollEnabled = false
        canvasView.delegate = context.coordinator
        canvasView.addGestureRecognizer(controller.recorder)
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(controller: controller)
    }

    /// Tells the controller whenever the writing changes.
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
```

**What this code does:**

| Part | What it does |
|---|---|
| `allowsFingerWriting` | A simple on/off switch. `true` lets fingers write (we don't have an Apple Pencil yet). Later we'll set it to `false`. |
| `HandwritingCanvasController` | The "remote control" for the box. The screen uses it to **clear** the box and to **capture** the writing when Done is tapped. |
| `@Observable` | Tells SwiftUI to watch this class. When `hasWriting` changes, the screen updates by itself (for example, Done switches on). |
| `fileprivate` | Only code in this file can use these. That keeps the canvas and the recorder safely hidden. |
| `HandwritingCanvas` | A `UIViewRepresentable`. PencilKit is a **UIKit** view, and this is how you use a UIKit view inside **SwiftUI**. |
| `makeUIView` | Sets up the canvas: black pen, white background, no scrolling, and it attaches our recorder. |
| `Coordinator` | PencilKit reports changes through a "delegate". The coordinator receives those reports and tells the controller "the drawing changed". |

---

## Step 3 - Update `HandwritingTestView.swift` (the screen)

Now we put the real writing box on the screen and make the buttons work.

Open `HandwritingTestView.swift`. **Replace everything below the header comment** (from `import SwiftUI` down to the end of the file) with the code below. Keep your own header at the top (the lines starting with `//`).

```swift
import SwiftUI

/// The child copies a sentence into the writing area. Their writing is recorded for analysis.
struct HandwritingTestView: View {
    /// Controls the writing area (clear it, read back what was written).
    @State private var canvas = HandwritingCanvasController()
    /// What was written, saved when Done is tapped.
    @State private var capture: HandwritingCapture?
    /// Opens the Analysis screen.
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
                // Hint text, hidden once writing starts
                .overlay {
                    if !canvas.hasWriting {
                        Text(allowsFingerWriting ? "Write here using Apple Pencil or your finger" : "Write here using Apple Pencil")
                            .foregroundStyle(.secondary)
                            .allowsHitTesting(false)
                    }
                }

            HStack {
                Button("Clear") {
                    canvas.clear()
                }

                Spacer()

                // Only available once something is written
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
```

**What changed:**

| Before | After | Why |
|---|---|---|
| `RoundedRectangle` placeholder with "Writing Area" | `HandwritingCanvas(controller: canvas)` | This is the real writing box now. |
| - | `.clipShape` + `.overlay { RoundedRectangle... }` | Gives the box rounded corners and a grey border. |
| - | Second `.overlay` with the hint text | Shows "Write here..." until the child starts writing. `.allowsHitTesting(false)` lets touches pass through the text to the canvas. |
| Clear did nothing | `canvas.clear()` | Wipes the box. |
| `NavigationLink` to `AnalysisView()` | `Button("Done")` + `.navigationDestination` | We need to **capture the writing first**, then move to the next screen. A plain `NavigationLink` can't run code before it navigates. |
| - | `.disabled(!canvas.hasWriting)` | Done stays greyed out until something is written. |
| - | 3 `@State` properties at the top | `canvas` is the box's controller, `capture` stores the writing, and `showAnalysis` opens the next screen when it becomes `true`. |

> Xcode will show errors after this step, saying `AnalysisView` has no `capture`. That's expected - Steps 4 and 5 fix it.

---

## Step 4 - Update `AnalysisView.swift`

The Analysis screen needs to **receive** the writing and **pass it on** to the Result screen.

Make these 3 small changes.

**4a.** Add the `capture` property at the top of the struct:

```swift
struct AnalysisView: View {
    /// The writing to analyse. Passed on to the Result screen.
    let capture: HandwritingCapture

    var body: some View {
```

**4b.** Pass it on to the Result screen. Change:

```swift
            NavigationLink(destination: ResultView()) {
```

to:

```swift
            NavigationLink(destination: ResultView(capture: capture)) {
```

**4c.** Fix the preview at the bottom. Change `AnalysisView()` to:

```swift
        AnalysisView(capture: .preview)
```

**Why:** `let capture` means "this screen can't be created without the writing". The preview has no real writing, so it uses the empty sample `.preview` that we made in Step 1.

---

## Step 5 - Update `ResultView.swift`

Same idea. We don't use the writing here yet, but **Save Record** and **Download Test Data** will need it later.

**5a.** Add the property at the top of the struct:

```swift
struct ResultView: View {
    /// The writing from the test. Will be used by Save Record and Download Test Data.
    let capture: HandwritingCapture

    var body: some View {
```

**5b.** Fix the preview at the bottom. Change `ResultView()` to:

```swift
        ResultView(capture: .preview)
```

---

## Step 6 - Build and try it

1. Press **Cmd + B**. It should build with **no errors**.
2. Choose an **iPad** simulator and press **Cmd + R**.
3. Tap through to the Handwriting Test screen, then check that:
   - [ ] the box says "Write here using Apple Pencil or your finger"
   - [ ] **Done** is greyed out
   - [ ] dragging with the mouse draws black ink, and the hint disappears
   - [ ] **Done** is now enabled
   - [ ] **Clear** wipes the box, and Done greys out again
   - [ ] after writing again, **Done** takes you to Analysing, then Continue takes you to the Result screen

**Note:** The simulator can't act like an Apple Pencil, so pressure and tilt will always be `0` or empty there. They need testing on a real iPad with a Pencil.

---

## Step 7 - Check your code matches

In **Terminal**, go to the project folder and run:

```bash
git hash-object "Dysgraphia App/HandwritingCapture.swift" "Dysgraphia App/HandwritingCanvas.swift" "Dysgraphia App/HandwritingTestView.swift" "Dysgraphia App/AnalysisView.swift" "Dysgraphia App/ResultView.swift"
```

You should see these 5 lines, in this order:

```
bcb629ca0655ccfdd559835c0ba25886af8cc153
e89a15a3922d87dad49855d277df353c9304b395
7e32805a8b65ceb550ad783bad8a22ad41238c6e
ed4fe02bed40d1479192e5b75fad37229de500e1
4c3af13f2e1c08575a76e54e352a551aee1f930a
```

A hash is a fingerprint of a file's contents. If one line is different, that file differs somewhere - even by a single space or a missing blank line. Compare that file with the code in this guide.

**Common mistakes:**

- Xcode's own header lines were left at the top of a new file (Steps 1 and 2)
- a comment was missed or retyped differently
- the file doesn't end with a single empty line after the last `}`

---

## Things to remember

- **Finger writing is temporary.** When we get an Apple Pencil, change one line in `HandwritingCanvas.swift` to `let allowsFingerWriting = false`. After that only the Pencil can write, and a hand resting on the screen is ignored.
- This screen is only a **screening** tool, not a diagnosis. The data you're capturing is what the analysis will use later.

Well done!
