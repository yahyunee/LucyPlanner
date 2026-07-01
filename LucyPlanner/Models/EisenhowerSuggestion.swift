import Foundation

/// A first-pass heuristic that suggests an Eisenhower quadrant for a todo by
/// scanning its title for keywords and checking its due date.
///
/// Keyword lists are English-only for now. When a todo gives no signal the
/// engine returns `nil` rather than guessing — the user sorts it by hand.
enum EisenhowerSuggestion {

    /// Words that hint the work matters to research / studies.
    static let importantKeywords: [String] = [
        "thesis", "dissertation", "research", "paper", "presentation",
        "present", "coding", "code", "experiment", "advisor", "proposal",
        "analysis", "study", "project", "lab", "defense", "review",
    ]

    /// Words that hint the work is time-pressured.
    static let urgentKeywords: [String] = [
        "today", "tonight", "asap", "urgent", "tomorrow", "deadline",
        "immediately", "submit", "reply", "respond", "now", "due",
    ]

    /// A due date within this window counts as urgent.
    static let urgentWindow: TimeInterval = 36 * 3600

    static func suggest(for todo: Todo, now: Date = .now) -> Quadrant? {
        let text = todo.title.lowercased()

        let isImportant = importantKeywords.contains { text.contains($0) }

        var isUrgent = urgentKeywords.contains { text.contains($0) }
        if let due = todo.dueDate, due.timeIntervalSince(now) < urgentWindow {
            isUrgent = true
        }

        guard isImportant || isUrgent else { return nil }

        switch (isImportant, isUrgent) {
        case (true, true):   return .doNow
        case (true, false):  return .decide
        case (false, true):  return .delegate
        case (false, false): return .delete
        }
    }
}
