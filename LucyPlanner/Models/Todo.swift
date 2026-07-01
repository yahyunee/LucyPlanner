import Foundation
import SwiftData

@Model
final class Todo {
    var title: String = ""
    var notes: String = ""
    var createdAt: Date = Date()
    var completedAt: Date? = nil
    var dueDate: Date? = nil
    /// Day this todo is planned for. `nil` means it lives in the global inbox.
    var scheduledDate: Date? = nil
    var quadrantRaw: String = Quadrant.unassigned.rawValue

    @Relationship(inverse: \Project.todos) var project: Project? = nil
    @Relationship(deleteRule: .nullify, inverse: \Tag.todos) var tags: [Tag]? = []
    /// Time blocks that schedule this todo. Deleting the todo removes its blocks.
    @Relationship(deleteRule: .cascade, inverse: \TimeBlock.todo) var timeBlocks: [TimeBlock]? = []

    var quadrant: Quadrant {
        get { Quadrant(rawValue: quadrantRaw) ?? .unassigned }
        set { quadrantRaw = newValue.rawValue }
    }

    var isComplete: Bool { completedAt != nil }

    init(title: String = "", notes: String = "") {
        self.title = title
        self.notes = notes
        self.createdAt = .now
    }

    /// Assign to a specific day (normalized to start-of-day), or `nil` for the inbox.
    func schedule(to date: Date?) {
        scheduledDate = date.map { Calendar.current.startOfDay(for: $0) }
    }

    /// Push to the day after its current day (or after `reference` if still in the inbox).
    func moveToNextDay(reference: Date) {
        let base = scheduledDate ?? reference
        let start = Calendar.current.startOfDay(for: base)
        scheduledDate = Calendar.current.date(byAdding: .day, value: 1, to: start)
    }
}
