import Foundation
import SwiftData

@Model
final class HabitLog {
    var date: Date = Date()
    var value: String = ""
    var note: String = ""

    var habit: Habit? = nil

    init(
        date: Date = .now,
        value: String = "",
        note: String = "",
        habit: Habit? = nil
    ) {
        self.date = Calendar.current.startOfDay(for: date)
        self.value = value
        self.note = note
        self.habit = habit
    }
}
