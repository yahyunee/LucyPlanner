import SwiftUI
import SwiftData
import EventKit

struct TimeTablePanel: View {
    let date: Date

    @Environment(\.modelContext) private var context
    @EnvironmentObject private var calendar: CalendarService
    @Query private var allBlocks: [TimeBlock]
    @State private var pendingDelete: EKEvent?

    private let slotHeight: CGFloat = 34
    private let slotCount = 40          // 6 AM → 2 AM, 30-min slots
    private let labelWidth: CGFloat = 64

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Time table")
                    .font(.headline)
                calendarStatus
                Spacer()
                Text("drag a todo · tap a block")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 12)

            ScrollView {
                HStack(alignment: .top, spacing: 0) {
                    labelColumn
                    gridColumn
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .task(id: date) { await calendar.loadEvents(for: date) }
        .task(id: calendar.access) { await calendar.loadEvents(for: date) }
        .confirmationDialog(
            deleteConfirmTitle,
            isPresented: deleteDialogBinding,
            presenting: pendingDelete
        ) { event in
            Button("Delete from calendar", role: .destructive) {
                try? calendar.delete(event)
                pendingDelete = nil
            }
            Button("Cancel", role: .cancel) { pendingDelete = nil }
        } message: { event in
            Text("This removes \"\(event.title ?? "the event")\" from your calendar. If it's a Google event, Apple Calendar will sync the deletion back.")
        }
    }

    private var deleteConfirmTitle: String {
        guard let event = pendingDelete else { return "Delete event?" }
        return event.hasRecurrenceRules ? "Delete this occurrence?" : "Delete event?"
    }

    private var deleteDialogBinding: Binding<Bool> {
        Binding(
            get: { pendingDelete != nil },
            set: { if !$0 { pendingDelete = nil } }
        )
    }

    @ViewBuilder
    private var calendarStatus: some View {
        switch calendar.access {
        case .unknown:
            Button("Connect Calendar") {
                Task { await calendar.requestAccess() }
            }
            .buttonStyle(.borderless)
            .font(.caption)
        case .denied, .restricted:
            Text("Calendar access denied — enable in System Settings › Privacy")
                .font(.caption)
                .foregroundStyle(.orange)
        case .writeOnly:
            Text("Calendar write-only — grant full access to see events")
                .font(.caption)
                .foregroundStyle(.orange)
        case .granted:
            EmptyView()
        }
    }

    // MARK: - Columns

    private var labelColumn: some View {
        VStack(spacing: 0) {
            ForEach(0..<slotCount, id: \.self) { index in
                Text(timeText(slotIndex: index))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(index.isMultiple(of: 2) ? .primary : .secondary)
                    .frame(width: labelWidth, height: slotHeight, alignment: .trailing)
                    .padding(.trailing, 6)
            }
        }
    }

    private var gridColumn: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                ForEach(0..<slotCount, id: \.self) { index in
                    Rectangle()
                        .fill(Color.secondary.opacity(0.05))
                        .frame(height: slotHeight)
                        .overlay(alignment: .top) {
                            Divider().opacity(index.isMultiple(of: 2) ? 1 : 0.35)
                        }
                }
            }

            ForEach(visibleEvents, id: \.eventIdentifier) { event in
                EventBlockView(
                    event: event,
                    baseY: yOffset(forEvent: event),
                    baseHeight: height(forEvent: event)
                )
                .onTapGesture { pendingDelete = event }
            }

            ForEach(blocks) { block in
                BlockView(
                    block: block,
                    slotHeight: slotHeight,
                    baseY: yOffset(for: block),
                    baseHeight: height(for: block),
                    onToggleDone: { toggleDone(block) },
                    onMove: { slots in move(block, bySlots: slots) },
                    onResize: { slots in resize(block, bySlots: slots) }
                )
                .contextMenu {
                    Button("Delete block", role: .destructive) {
                        context.delete(block)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .dropDestination(for: String.self) { payloads, location in
            handleDrop(payloads, at: location)
        }
    }

    // MARK: - Data

    private var blocks: [TimeBlock] {
        allBlocks.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    private var visibleEvents: [EKEvent] {
        let windowEnd = slotStart(slotCount)
        return calendar.events.filter { event in
            event.endDate > dayStart6AM && event.startDate < windowEnd
        }
    }

    private var dayStart6AM: Date {
        let midnight = Calendar.current.startOfDay(for: date)
        return Calendar.current.date(byAdding: .hour, value: 6, to: midnight) ?? midnight
    }

    // MARK: - Geometry

    private func slotStart(_ index: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: index * 30, to: dayStart6AM) ?? dayStart6AM
    }

    private func slotIndex(of date: Date) -> Int {
        Int((date.timeIntervalSince(dayStart6AM) / 60 / 30).rounded())
    }

    private func durationSlots(of block: TimeBlock) -> Int {
        max(1, Int((block.endTime.timeIntervalSince(block.startTime) / 60 / 30).rounded()))
    }

    private func timeText(slotIndex index: Int) -> String {
        slotStart(index).formatted(.dateTime.hour().minute())
    }

    private func yOffset(for block: TimeBlock) -> CGFloat {
        let minutes = block.startTime.timeIntervalSince(dayStart6AM) / 60
        return CGFloat(minutes) / 30 * slotHeight
    }

    private func height(for block: TimeBlock) -> CGFloat {
        let minutes = block.endTime.timeIntervalSince(block.startTime) / 60
        return max(slotHeight, CGFloat(minutes) / 30 * slotHeight)
    }

    private func yOffset(forEvent event: EKEvent) -> CGFloat {
        let clamped = max(event.startDate, dayStart6AM)
        let minutes = clamped.timeIntervalSince(dayStart6AM) / 60
        return CGFloat(minutes) / 30 * slotHeight
    }

    private func height(forEvent event: EKEvent) -> CGFloat {
        let windowEnd = slotStart(slotCount)
        let start = max(event.startDate, dayStart6AM)
        let end = min(event.endDate, windowEnd)
        let minutes = end.timeIntervalSince(start) / 60
        return max(slotHeight * 0.5, CGFloat(minutes) / 30 * slotHeight)
    }

    // MARK: - Mutations

    private func toggleDone(_ block: TimeBlock) {
        guard let todo = block.todo else { return }
        todo.completedAt = todo.completedAt == nil ? .now : nil
    }

    private func move(_ block: TimeBlock, bySlots delta: Int) {
        guard delta != 0 else { return }
        let duration = durationSlots(of: block)
        let current = slotIndex(of: block.startTime)
        let newStart = max(0, min(slotCount - duration, current + delta))
        block.startTime = slotStart(newStart)
        block.endTime = slotStart(newStart + duration)
    }

    private func resize(_ block: TimeBlock, bySlots delta: Int) {
        guard delta != 0 else { return }
        let start = slotIndex(of: block.startTime)
        let duration = durationSlots(of: block)
        let newDuration = max(1, min(slotCount - start, duration + delta))
        block.endTime = slotStart(start + newDuration)
    }

    // MARK: - Drop

    private func handleDrop(_ payloads: [String], at location: CGPoint) -> Bool {
        guard
            let payload = payloads.first,
            let id = PersistentIdentifier.decode(dragPayload: payload),
            let todo = context.model(for: id) as? Todo
        else { return false }

        let index = max(0, min(slotCount - 1, Int(location.y / slotHeight)))
        let start = slotStart(index)
        let end = Calendar.current.date(byAdding: .minute, value: 60, to: start) ?? start

        let block = TimeBlock(date: date, startTime: start, endTime: end, todo: todo)
        context.insert(block)
        todo.schedule(to: date)
        return true
    }
}

// MARK: - Block

private struct BlockView: View {
    let block: TimeBlock
    let slotHeight: CGFloat
    let baseY: CGFloat
    let baseHeight: CGFloat
    let onToggleDone: () -> Void
    let onMove: (Int) -> Void
    let onResize: (Int) -> Void

    @State private var moveOffset: CGFloat = 0
    @State private var resizeOffset: CGFloat = 0
    @State private var isDragging = false

    private var isDone: Bool { block.todo?.isComplete == true }

    private var tint: Color {
        let quadrant = block.todo?.quadrant ?? .unassigned
        return quadrant == .unassigned ? .accentColor : quadrant.color
    }

    private var displayTitle: String {
        if let title = block.todo?.title, !title.isEmpty { return title }
        return block.note.isEmpty ? "Time block" : block.note
    }

    private var timeRange: String {
        let start = block.startTime.formatted(.dateTime.hour().minute())
        let end = block.endTime.formatted(.dateTime.hour().minute())
        return "\(start) – \(end)"
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(tint.opacity(isDone ? 0.07 : 0.13))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(tint.opacity(0.35))
            )
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(displayTitle)
                        .font(.caption.weight(.medium))
                        .strikethrough(isDone)
                        .lineLimit(2)
                    Text(timeRange)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(6)
            }
            .overlay(alignment: .bottom) { resizeHandle }
            .opacity(isDone ? 0.6 : 1)
            .frame(maxWidth: .infinity)
            .frame(height: max(slotHeight, baseHeight + resizeOffset))
            .shadow(radius: isDragging ? 4 : 0)
            .padding(.horizontal, 3)
            .offset(y: baseY + moveOffset)
            .onTapGesture { onToggleDone() }
            .gesture(moveGesture)
    }

    private var resizeHandle: some View {
        ZStack {
            Color.clear
            Capsule()
                .fill(tint.opacity(0.45))
                .frame(width: 26, height: 4)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 14)
        .contentShape(Rectangle())
        .gesture(resizeGesture)
        .help("Drag to resize")
    }

    private var moveGesture: some Gesture {
        DragGesture(minimumDistance: 5)
            .onChanged { value in
                isDragging = true
                moveOffset = value.translation.height
            }
            .onEnded { value in
                let slots = Int((value.translation.height / slotHeight).rounded())
                moveOffset = 0
                isDragging = false
                onMove(slots)
            }
    }

    private var resizeGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { value in resizeOffset = value.translation.height }
            .onEnded { value in
                let slots = Int((value.translation.height / slotHeight).rounded())
                resizeOffset = 0
                onResize(slots)
            }
    }
}

// MARK: - Event block (read-only, sourced from EventKit)

private struct EventBlockView: View {
    let event: EKEvent
    let baseY: CGFloat
    let baseHeight: CGFloat

    private var tint: Color {
        #if canImport(AppKit)
        if let cg = event.calendar?.cgColor { return Color(cgColor: cg) }
        #endif
        return .secondary
    }

    private var timeRange: String {
        let start = event.startDate.formatted(.dateTime.hour().minute())
        let end = event.endDate.formatted(.dateTime.hour().minute())
        return "\(start) – \(end)"
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(tint.opacity(0.12))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(tint.opacity(0.55), style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
            )
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                            .foregroundStyle(tint)
                        Text(event.title ?? "Untitled")
                            .font(.caption.weight(.medium))
                            .lineLimit(2)
                    }
                    Text(timeRange)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(6)
            }
            .frame(maxWidth: .infinity)
            .frame(height: baseHeight)
            .padding(.horizontal, 3)
            .offset(y: baseY)
            .help("Tap to delete this event from your calendar")
    }
}
