# Palabrita 🇪🇸
*A Spanish word-of-the-day widget app*

## Overview
Palabrita is a lightweight iOS app whose primary purpose is to display a rotating Spanish word throughout the day via **Home Screen and Lock Screen widgets**.

Each word includes:
- Spanish word
- English translation
- Example sentences
- Audio pronunciation

Users can open the app to explore the current word and swipe up to advance to a new one.

This repository currently contains **initial project setup only**. The tasks below define the full MVP implementation.

---

## MVP Constraints
- Platform: iOS (SwiftUI + WidgetKit)
- Monetization: None (free)
- Data source: Bundled JSON word list (no paid APIs)
- Audio: iOS Text-to-Speech (AVSpeechSynthesizer)
- App Store–ready architecture

---

## Word Refresh Schedule
Words rotate **several** times a day:
Specified by the user. EXAMPLE: User chooses - 5 words a day between 7am and 9pm

---

# TODO BACKLOG

## Epic 1 — Project & Targets
- [ ] Create SwiftUI iOS App target
- [ ] Add Widget Extension target
- [ ] Enable Lock Screen widgets (AccessoryInline, AccessoryRectangular)
- [ ] Enable App Group for shared storage (app + widget)

**Acceptance Criteria**
- App builds and runs
- Widgets appear in widget gallery
- App Group data accessible from app and widget

---

## Epic 2 — Data Models
- [ ] Create `WordEntry` model
  - `id`
  - `spanish`
  - `english`
  - `examples: [ExampleSentence]`
- [ ] Create `ExampleSentence` model
  - `spanish`
  - `english`

**Acceptance Criteria**
- Models are Codable
- IDs are stable and unique
- Safe to persist and share between targets

---

## Epic 3 — Word Source (Free)
- [ ] Add bundled file `words_es_en.json`
- [ ] Implement `BundledWordSource`
  - load JSON
  - return random unseen word
  - avoid duplicates
  - reset or allow repeats when exhausted

**Acceptance Criteria**
- App always returns a valid word
- No crashes if examples are missing

---

## Epic 4 — Persistence & Shared State
- [ ] Persist data using `UserDefaults` with App Group
  - seen word IDs
  - today’s word schedule
  - current word ID
- [ ] Widgets must read from the same shared state

**Acceptance Criteria**
- Seen words persist across app launches
- Widgets show data without opening the app first

---

## Epic 5 — Word Scheduling Engine
- [ ] Implement `WordScheduler`
  - assign word IDs to each daily time slot
  - select current word based on local time
- [ ] Generate schedule once per day

**Acceptance Criteria**
- No duplicate words within the same day
- Correct word selected for current time slot

---

## Epic 6 — Widget Timeline
- [ ] Implement WidgetKit `TimelineProvider`
  - read schedule from App Group
  - generate timeline entries for each slot
  - fallback placeholder if data is missing

**Acceptance Criteria**
- Widgets refresh at correct times
- No empty or broken widget states

---

## Epic 7 — Widget UI

### Home Screen Widget
- [ ] Display Spanish word (large)
- [ ] Display English translation (secondary)

### Lock Screen Widgets
- [ ] Inline: Spanish word only
- [ ] Rectangular: Spanish + English

**Acceptance Criteria**
- Readable in light and dark mode
- Long words handled gracefully

---

## Epic 8 — In-App UI
- [ ] Main word screen
  - Spanish word
  - English translation
  - Example sentences (if available)
  - Audio play button
- [ ] Swipe up gesture to get next word
- [ ] Button fallback (“Next word”)
- [ ] History screen (last 20–50 words)

**Acceptance Criteria**
- Swipe gesture works reliably
- History persists across launches
- UI transitions are stable

---

## Epic 9 — Audio Pronunciation
- [ ] Implement `PronunciationService`
  - AVSpeechSynthesizer
  - Spanish voice (`es-ES` or `es-MX`)
- [ ] Prevent overlapping audio playback

**Acceptance Criteria**
- Works offline
- Clear pronunciation
- Restart behavior on repeated taps

---

## Epic 10 — App Store Readiness
- [ ] App icon and display name: Palabrita
- [ ] About screen
- [ ] Privacy note (offline-first, no tracking)
- [ ] Graceful empty/error states

**Acceptance Criteria**
- App safe for TestFlight submission
- No dependency on network availability

---

## Deliverables
- [ ] Working Xcode project
- [ ] `words_es_en.json`
- [ ] README updates describing:
  - word scheduling logic
  - how to add more words
  - known MVP limitations

---

## Notes for Agents
- Do not introduce paid APIs
- Keep architecture simple and stable
- Design so a remote word source can be added later
