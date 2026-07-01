import SwiftUI
import SwiftData

struct HabitTrackerPanel: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Habit.order) private var habits: [Habit]

    @State private var showingEditor = false
    @State private var visibleMonth: Date = Self.startOfMonth(.now)

    private static func startOfMonth(_ date: Date) -> Date {
        let cal = Calendar.current
        return cal.date(from: cal.dateComponents([.year, .month], from: date)) ?? cal.startOfDay(for: date)
    }

    private var monthLabel: String {
        visibleMonth.formatted(.dateTime.year().month(.wide))
    }

    private var daysInMonth: [Date] {
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: visibleMonth) else { return [] }
        return range.compactMap { day in
            cal.date(byAdding: .day, value: day - 1, to: visibleMonth)
        }
    }

    private var isCurrentMonth: Bool {
        Calendar.current.isDate(visibleMonth, equalTo: .now, toGranularity: .month)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text("Habits")
                    .font(.headline)

                HStack(spacing: 4) {
                    Button { shiftMonth(-1) } label: {
                        Image(systemName: "chevron.left")
                    }
                    .buttonStyle(.borderless)
                    .help("Previous month")

                    Text(monthLabel)
                        .font(.subheadline.monospacedDigit())
                        .frame(minWidth: 120)
                        .multilineTextAlignment(.center)

                    Button { shiftMonth(1) } label: {
                        Image(systemName: "chevron.right")
                    }
                    .buttonStyle(.borderless)
                    .help("Next month")

                    if !isCurrentMonth {
                        Button("This month") {
                            visibleMonth = Self.startOfMonth(.now)
                        }
                        .buttonStyle(.borderless)
                        .font(.caption)
                    }
                }

                Spacer()

                if !habits.isEmpty {
                    Button {
                        showingEditor = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .buttonStyle(.borderless)
                    .help("Edit habits")
                }
                Text("tap a cell")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 8)

            if habits.isEmpty {
                Button("Seed default habits") { seedDefaultHabits() }
                    .padding(.horizontal)
            } else {
                ForEach(habits) { habit in
                    HabitRow(habit: habit, days: daysInMonth)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .sheet(isPresented: $showingEditor) {
            HabitEditorSheet()
        }
    }

    private func shiftMonth(_ delta: Int) {
        let cal = Calendar.current
        if let next = cal.date(byAdding: .month, value: delta, to: visibleMonth) {
            visibleMonth = Self.startOfMonth(next)
        }
    }

    private func seedDefaultHabits() {
        let defaults: [(String, String)] = [
            ("Workout", "🏃"),
            ("Productive commute", "📚"),
            ("Research energy", "🔬"),
        ]
        for (index, item) in defaults.enumerated() {
            context.insert(Habit(name: item.0, defaultEmoji: item.1, order: index))
        }
    }
}

// MARK: - Row

private struct HabitRow: View {
    let habit: Habit
    let days: [Date]

    var body: some View {
        HStack(spacing: 4) {
            Text(habit.defaultEmoji)
            Text(habit.name)
                .font(.caption)
                .frame(width: 130, alignment: .leading)
                .lineLimit(1)

            ForEach(days, id: \.self) { day in
                HabitCell(day: day, habit: habit)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Cell

private struct HabitCell: View {
    let day: Date
    let habit: Habit

    @Environment(\.modelContext) private var context
    @State private var showingPopover = false

    private var matchingLogs: [HabitLog] {
        (habit.logs ?? []).filter { Calendar.current.isDate($0.date, inSameDayAs: day) }
    }
    private var log: HabitLog? {
        matchingLogs.first { !$0.value.isEmpty } ?? matchingLogs.first
    }
    private var isDone: Bool { matchingLogs.contains { !$0.value.isEmpty } }
    private var hasNote: Bool { matchingLogs.contains { !$0.note.isEmpty } }
    private var isToday: Bool { Calendar.current.isDateInToday(day) }

    private var effectiveEmoji: String {
        let trimmed = habit.defaultEmoji.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? "✅" : trimmed
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(isDone ? Color.green.opacity(0.65) : Color.secondary.opacity(0.12))
            .frame(width: 18, height: 18)
            .overlay {
                if isDone {
                    Text(log?.value ?? effectiveEmoji).font(.system(size: 10))
                }
            }
            .overlay(alignment: .topTrailing) {
                if hasNote {
                    Circle()
                        .fill(.orange)
                        .frame(width: 5, height: 5)
                        .offset(x: 1, y: -1)
                }
            }
            .overlay {
                if isToday {
                    RoundedRectangle(cornerRadius: 3)
                        .strokeBorder(Color.primary, lineWidth: 1.5)
                }
            }
            .onTapGesture { showingPopover = true }
            .popover(isPresented: $showingPopover) { editor }
    }

    private var editor: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(day.formatted(date: .complete, time: .omitted))
                .font(.headline)

            Button(isDone ? "Mark not done" : "Mark done \(effectiveEmoji)") {
                toggleDone()
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Note")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("e.g. what you did on the commute", text: noteBinding, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3, reservesSpace: true)
                    .frame(width: 240)
            }
        }
        .padding()
    }

    private var noteBinding: Binding<String> {
        Binding(
            get: { log?.note ?? "" },
            set: { newValue in
                if let log {
                    log.note = newValue
                    cleanupIfEmpty(log)
                } else if !newValue.isEmpty {
                    context.insert(HabitLog(date: day, value: "", note: newValue, habit: habit))
                }
            }
        )
    }

    private func toggleDone() {
        if isDone {
            for log in matchingLogs {
                log.value = ""
                cleanupIfEmpty(log)
            }
        } else if let log = matchingLogs.first {
            log.value = effectiveEmoji
        } else {
            context.insert(HabitLog(date: day, value: effectiveEmoji, note: "", habit: habit))
        }
    }

    private func cleanupIfEmpty(_ log: HabitLog) {
        if log.value.isEmpty && log.note.isEmpty {
            context.delete(log)
        }
    }
}

// MARK: - Editor sheet

private struct HabitEditorSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Habit.order) private var habits: [Habit]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Edit habits")
                .font(.title2.bold())

            List {
                ForEach(habits) { habit in
                    HabitEditorRow(habit: habit)
                }
                .onDelete { offsets in
                    for index in offsets { context.delete(habits[index]) }
                }
            }
            .listStyle(.inset)

            HStack {
                Button {
                    context.insert(
                        Habit(name: "New habit", defaultEmoji: "✅", order: habits.count)
                    )
                } label: {
                    Label("Add habit", systemImage: "plus")
                }

                Spacer()

                Button("Done") { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 400, height: 380)
    }
}

private struct HabitEditorRow: View {
    @Bindable var habit: Habit

    var body: some View {
        HStack(spacing: 8) {
            TextField("⭐️", text: $habit.defaultEmoji)
                .multilineTextAlignment(.center)
                .frame(width: 44)
            TextField("Habit name", text: $habit.name)
        }
    }
}
