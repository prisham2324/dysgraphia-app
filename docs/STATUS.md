# Project Status

*Last checked: 30 September 2026*

## In short

The first 5 screens of the **New Record** flow have been built as **basic layouts**. You can tap through them from start to finish. Nothing is "live" yet:

- the child can't actually write
- the app doesn't analyse anything
- nothing gets saved or downloaded

The whole **Saved Records** tab, the **tab bar** and the **Download screen** have not been started.

**Overall progress: roughly 20-25% of Phase 1** (screen layouts in place, no working features yet).

---

## What is done

| Screen | Status | What works today |
|---|---|---|
| Home | Basic layout done | Title, short message, Start button takes you to the next screen |
| Student Details | Basic layout done | Name, Age, Gender and Notes boxes you can type in, Continue button |
| Handwriting Test | Basic layout done | Shows the sentence to copy and an empty box for writing, Clear and Done buttons |
| Analysing | Basic layout done | Title, message and a spinning loader, Continue button |
| Screening Result | Basic layout done | Tick icon, result message and 3 buttons |

All 5 screens are linked, so you can move from Home through to the Result screen.

## What is not started

| Item | Status |
|---|---|
| Tab bar (New Record / Saved Records) | Not started |
| Download Complete screen | Not started |
| Saved Records list | Not started |
| Student Details page (saved record) | Not started |
| View Handwriting Test screen | Not started |
| Actually writing with Apple Pencil or a finger | Not started |
| Handwriting analysis | Not started (the result is always the same fixed message) |
| Saving records | Not started |
| Downloading test data | Not started |

---

## Differences from the wireframe and requirements

These are places where the work done so far doesn't match what we agreed. Most are small and expected at this early stage. The ones marked **Important** need fixing before the next review.

### Across the app

- **Important - No tab bar.** The wireframe has two tabs at the bottom (New Record and Saved Records) on every screen. At the moment there is only one straight path of screens.
- **Important - "Take Another Test" doesn't really go back to the start.** It opens a fresh copy of the Home screen on top of the old screens. The result is that the Back button now leads back into the old test, and the screens pile up every time a new test is started. It should return the user to the original Home screen.
- **Screen look is plainer than the wireframe.** No illustrations, cards or styling yet. This is fine for now, but the design will need to be matched later.

### Home

- Missing the illustration of the child writing on a tablet. There is a simple icon instead.
- The message is different. The wireframe says *"This activity will take a few minutes. Please write naturally."* The app says *"Complete a short handwriting screening to assess writing patterns."* and adds *"Estimated time: 5-10 minutes"*, which wasn't in the wireframe.

### Student Details

- Screen is titled **"User Details"** - the wireframe says **"Student Details"**.
- **Add Photo** is missing.
- **Age** is a free text box. It should accept numbers only and show "years".
- **Gender** is a free text box. It should be three buttons to pick from: Male / Female / Other.
- **Important - Required fields aren't checked.** You can tap Continue with everything left blank. Name, Age and Gender should be filled in before moving on.
- Notes is a single-line box. The wireframe shows a bigger multi-line box.

### Handwriting Test

- **Important - The child can't write yet.** The writing area is an empty box with the words "Writing Area".
- The **Clear** button does nothing.
- **Done** is shown as small text rather than a large button.

### Analysing

- **Needs a decision - the user has to tap "Continue".** The wireframe shows the app moving to the result on its own once the analysis finishes. The extra button should be removed once real analysis is in place.
- Uses a spinning loader instead of a progress bar.
- The tip *"This may take a few seconds."* is missing.
- The message wording is slightly different.

### Screening Result

- Titled **"Screening Complete"** - the wireframe says **"Screening Result"**.
- **Important - The reminder is missing.** The wireframe shows *"This is a screening result and does not replace professional evaluation."* The requirements say this must always be shown.
- The result message isn't in a highlighted box.
- **Save Record** and **Download Test Data** buttons do nothing yet.
- Missing the icons on the buttons.

### UK vs US spelling

- The app uses "Analyzing" (US spelling). To keep with UK English it should be "Analysing".

---

## Suggested next steps

1. Add the two-tab layout and fix the "Take Another Test" behaviour.
2. Make the Student Details form match the wireframe (photo, Age as a number, Gender buttons, required fields).
3. Make the writing area work with Apple Pencil and finger, including Clear.
4. Add the missing reminder text on the Result screen and match the wording to the wireframe.
5. Build saving records, then the Saved Records tab screens.
6. Build the Download feature and the Download Complete screen.
7. Plug in the real handwriting analysis.
