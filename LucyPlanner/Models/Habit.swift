import Foundation
import SwiftData

@Model
final class Habit {
    var name: String = ""
    var defaultEmoji: String = "✅"
    var order: Int = 0
    var colorHex: String = "#34C759"
    var createdAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \HabitLog.habit)
    var logs: [HabitLog]? = []

    init(
        name: String = "",
        defaultEmoji: String = "✅",
        order: Int = 0,
        colorHex: String = "#34C759"
    ) {
        self.name = name
        self.defaultEmoji = defaultEmoji
        self.order = order
        self.colorHex = colorHex
        self.createdAt = .now
    }
}
