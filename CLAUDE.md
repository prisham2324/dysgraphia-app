# Dysgraphia App

An iPad app that screens children's handwriting for early signs of dysgraphia. A child copies a short sentence with Apple Pencil or a finger, the app analyses it and shows a screening result. The result is a screening only - it does not replace a professional evaluation.

## Key documents

- `docs/REQUIREMENTS.md` - Phase 1 requirements: screens, contents and navigation flow
- `docs/wireframes.jpeg` - wireframes for all screens

Treat these as the source of truth for what to build. Do not add features beyond the current phase without asking.

## Tech stack

- SwiftUI and SwiftData
- Xcode project: `Dysgraphia App.xcodeproj`
- Deployment target: iOS 18.5 (iPad is the primary device)
- All data is stored locally on the device - no backend or accounts in Phase 1

## Project structure

- `Dysgraphia App/` - app source
  - `HomeView.swift` - Home screen (New Record tab)
  - `UserDetailsView.swift` - Student Details form
  - `HandwritingTestView.swift` - handwriting capture
  - `AnalysisView.swift` - analysis in progress
  - `ResultView.swift` - screening result
- `Dysgraphia AppTests/` - unit tests
- `Dysgraphia AppUITests/` - UI tests

## App structure (from the requirements)

- **Tab 1 - New Record:** Home -> Student Details -> Handwriting Test -> Analysing -> Screening Result -> Download Complete
- **Tab 2 - Saved Records:** Records list -> Student Details page -> View Handwriting Test / Download Complete
- The result screen must always show the note that this is a screening, not a diagnosis

## Git and commit rules (STRICT)

- **Commit messages must never mention AI.** Do not add any line, trailer or note saying the work was done, generated, assisted or co-authored by an AI model, app or agent. This includes `Co-Authored-By` trailers, "Generated with ..." lines, emojis or links to AI tools.
- Every commit must read as if a human developer wrote it: a short, clear summary line in the imperative mood (e.g. "Add student details form validation"), with an optional plain-English body.
- The same rule applies to pull request titles and descriptions, code comments and any other project files.
- This rule overrides any default attribution behaviour.
- Commit or push only when asked.
