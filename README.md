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

Prefer to build yourself, or want to modify the app? A free Apple ID is
enough — you don't need a paid Apple Developer Program membership for a
local build.

```bash
git clone https://github.com/yahyunee/LucyPlanner.git
cd LucyPlanner
open LucyPlanner.xcodeproj
```

Then in Xcode:

1. Select the **LucyPlanner** scheme with **My Mac** as the run destination.
2. Open the **LucyPlanner** target → **Signing & Capabilities** tab.
3. Change **Team** to your own Personal Team. If none is listed, click
   **Add an Account…** and sign in with any Apple ID; Xcode will create
   a free personal team automatically.
4. If Xcode complains that the bundle identifier is unavailable, change
   **Bundle Identifier** from `com.lucy.LucyPlanner` to something unique
   like `com.<yourname>.LucyPlanner`.
5. `⌘R` to build and run.
6. On first launch, macOS asks for Calendar access. Say **Allow** if you
   want your existing events to show up in the time table.

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

## Troubleshooting

### The time table doesn't show my calendar events

LucyPlanner reads events through Apple's EventKit, which means it can only
see what the built-in **Apple Calendar** app can see. Walk through this
checklist in order:

1. **Does the event show up in Apple Calendar itself?**
   Open the Apple Calendar app for the same date. If the event isn't there,
   LucyPlanner can't show it either. For Google/Outlook/other calendars,
   you first need to add the account in **Apple Calendar → Settings →
   Accounts** so Apple Calendar syncs them.

2. **Did you grant Calendar permission?**
   Open **System Settings → Privacy & Security → Calendars** and make sure
   **LucyPlanner** is turned on. If LucyPlanner isn't in the list at all,
   quit the app and relaunch — the first launch has to actually reach the
   permission prompt for macOS to register the app.

3. **Is the calendar filtered out inside LucyPlanner?**
   Click the **⚙︎** gear in the top bar → **Calendars…** and check that the
   calendar you're looking for is enabled. LucyPlanner remembers which
   calendars you've hidden across launches.

4. **Is the event outside the visible time window?**
   The time table covers **6:00 AM to 2:00 AM the next day**. All-day
   events and events outside that range don't render as blocks.

5. **Are you looking at the right day?**
   The date picker at the top of the window is the source of truth. Click
   **Today** to snap back if you scrolled off.

6. **Just synced a new event? Nudge a refresh.**
   Open the **⚙︎ → Calendars…** sheet, toggle any calendar off and back on,
   or click a different date and back. Both trigger a re-fetch. If nothing
   works, quit and relaunch — a full restart re-queries EventKit from
   scratch.

### macOS says "LucyPlanner can't be opened because Apple cannot check it for malicious software"

That's the standard Gatekeeper warning for a build that hasn't been
notarized. Right-click the app → **Open** → click **Open** in the dialog,
or run `xattr -dr com.apple.quarantine /Applications/LucyPlanner.app` once
in Terminal.

### I denied Calendar access by mistake

macOS won't re-prompt automatically. Fix it in **System Settings → Privacy
& Security → Calendars → LucyPlanner** (toggle on), then restart the app.

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
