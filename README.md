# LucyPlanner

A single-window macOS day planner that keeps four things visible at once:
your **goal for the day**, your **time table**, your **todos**, and your
**habits**. No tabs, no context switching — the whole day fits on one screen.

Built with **SwiftUI** and **SwiftData**, integrated with **Apple Calendar**
(and any calendar it syncs, including Google Calendar) via **EventKit**.

> 한국어 문서: [README.ko.md](README.ko.md)

---

## Screenshot layout

```
┌─────────────────────────────────────────────────────────────────────┐
│  ‹  2026-07-01  ›  [Today]         Today's goal…              ⚙︎    │
├──────────────────────────────────┬──────────────────────────────────┤
│  Time table                      │  Todos       ┌───────┬───────┐   │
│                                  │              │ List  │Matrix │   │
│   6:00                           │  Brain-dump anything…   [Add] │  │
│   6:30  ▓ Morning run            │                                │  │
│   7:00                           │  Today · 3                     │  │
│   ...                            │   ○ Write intro section        │  │
│  10:00  ▓ Lab meeting            │   ● Reply to advisor           │  │
│  10:30  ▓ Lab meeting            │   ○ Push branch                │  │
│  11:00                           │                                │  │
│   ...                            │  Inbox · 2                     │  │
│                                  │   ○ Read new paper             │  │
│                                  │   ○ Buy running shoes          │  │
├──────────────────────────────────┴──────────────────────────────────┤
│  Habits                                                             │
│  Read 30 min   ▓ ▓ · ▓ ▓ ▓ · · ▓ ▓ ▓ ▓ · · ▓                        │
│  Run           · ▓ · · ▓ · · · ▓ · · ▓ · ·                          │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Features

### 🎯 A goal, front and center
The top bar always shows a single "Today's goal" text field. It's saved per
day, so yesterday's goal doesn't hang around and today's doesn't leak into
tomorrow.

### 🗓️ Time table with real calendar events
- A 30-minute grid from 6:00 AM to 2:00 AM the next day.
- Reads events from any Apple Calendar you allow (Google, iCloud, work — any
  calendar Apple Calendar shows).
- Filter which calendars appear from the **⚙︎ → Calendars…** sheet.
- **Drag a todo** from the right panel onto a slot to block a time for it.
- **Tap a block** to delete the underlying calendar event (with a confirmation
  step so nothing disappears by accident).

### ✅ Todos with an Inbox and a plan
- Brain-dump anything into the input at the top of the todo panel.
- Todos start life in the **Inbox** (no scheduled date).
- Schedule a todo for a day, push it to tomorrow, or send it back to the
  Inbox — all from the row's ellipsis menu.
- Two view modes: **List** or **Matrix** (see below).

### 🧭 Eisenhower Matrix view
Switch to Matrix view to see todos organized into the four Eisenhower
quadrants: **Do Now**, **Decide**, **Delegate**, **Delete**.

A lightweight keyword heuristic suggests a quadrant based on the title (e.g.
words like `deadline`, `today`, `asap` → urgent; `paper`, `research`,
`review` → important). Suggestions only fire when there's a clear signal;
otherwise you place the todo yourself. Assigning a quadrant by hand always
overrides the suggestion.

### 📈 Habit tracker
- A monthly grid of your habits along the bottom of the window.
- One tap toggles a day. Navigate month by month.
- Habits stay small and physical — a row per habit, a column per day.

### 💾 Local-first storage
All data lives in a local SwiftData store inside the app's container. Nothing
is uploaded anywhere. CloudKit sync is planned for a future iPhone version.

---

## Requirements

- macOS 15 Sequoia or later
- Apple Calendar access permission (prompted on first launch)
- Xcode 16+ **only if building from source**

---

## Install (recommended)

1. Go to the [Releases page](https://github.com/yahyunee/LucyPlanner/releases).
2. Download `LucyPlanner.zip` from the latest release.
3. Double-click the zip to unpack. Drag `LucyPlanner.app` into `/Applications`.
4. **First launch**: because the app isn't notarized through Apple yet,
   Gatekeeper will refuse a plain double-click. Do one of the following:
   - **Right-click** `LucyPlanner.app` → **Open** → click **Open** in the
     dialog. macOS remembers your choice for future launches.
   - Or, in Terminal:
     ```bash
     xattr -dr com.apple.quarantine /Applications/LucyPlanner.app
     ```
5. macOS will ask for **Calendar** access on first run. Grant it if you want
   your existing calendar events to appear in the time table (the app still
   works if you decline — the time table just stays event-free).

> No releases yet? See [Build from source](#build-from-source) below.

---

## Build from source

Prefer to build yourself, or want to modify the app?

```bash
git clone https://github.com/yahyunee/LucyPlanner.git
cd LucyPlanner
open LucyPlanner.xcodeproj
```

Then in Xcode:

1. Select the **LucyPlanner** scheme, **My Mac** as the run destination.
2. Under **Signing & Capabilities**, change the signing team to your own
   (or leave it "Sign to Run Locally" for a local-only build).
3. `⌘R` to build and run.

---

## Usage examples

**A typical morning**

1. Open LucyPlanner. It lands on today.
2. Type today's goal into the top bar — e.g. *"Finish draft of Section 3."*
3. Look at the time table. Meetings from your calendar are already there.
4. In the todo panel, brain-dump everything on your mind. All of it lands
   in the **Inbox**.
5. Drag *"Write Section 3"* from the Inbox onto the 9:00–11:00 slot on the
   time table. It becomes a real calendar event.
6. Toggle habits at the bottom as you go through the day.

**Triaging with the Eisenhower Matrix**

1. Switch the todo panel to **Matrix**.
2. Anything urgent or important gets a suggested quadrant automatically.
3. Drag the rest into a quadrant that makes sense to you.
4. Work through **Do Now**, then **Decide** and schedule those for later,
   then **Delegate**, then delete the rest.

**Planning tomorrow**

1. Click the `›` arrow next to the date to move to tomorrow.
2. Set tomorrow's goal.
3. Use the ellipsis menu on any Inbox todo → **Plan for this day**.
4. Drag anything time-sensitive onto tomorrow's time table.

---

## Project structure

```
LucyPlanner/
├── LucyPlannerApp.swift       // @main + SwiftData ModelContainer setup
├── ContentView.swift           // Root layout: TopBar / TimeTable / Todos / Habits
├── LucyPlanner.entitlements    // Sandbox + Calendars entitlement
├── Models/                     // @Model types: Todo, Habit, TimeBlock, DailyEntry, ...
├── Services/
│   └── CalendarService.swift   // EventKit access, event loading, delete
└── Views/                      // TopBar, TimeTablePanel, TodoListPanel, HabitTrackerPanel, ...
```

Data lives at:
`~/Library/Containers/com.<your-team>.LucyPlanner/Data/Library/Application Support/default.store`

---

## Roadmap

- **iPhone companion**  — SwiftUI on iOS with the same schema
- **CloudKit sync**  — enable in `ModelConfiguration` once the iPhone target exists
- **Richer habit stats**  — streaks, completion rate, monthly summaries
- **Better Eisenhower suggestions**  — learn from user-assigned quadrants instead of a keyword list

---

## Contributing

This is a personal project built around one specific daily routine, so PRs
that fundamentally reshape the workflow probably won't land. Bug fixes,
polish, small quality-of-life improvements, and localization are welcome.

Please open an issue before starting anything larger than a few files of
changes — it saves both of us time.

---

## License

[GPL-3.0](LICENSE) © 2026 yahyunee

This is copyleft: you're free to use, study, modify, and redistribute the
code, but any distributed derivative must also be released under GPL-3.0
with source available. If you want to reuse the code under different terms,
open an issue.
