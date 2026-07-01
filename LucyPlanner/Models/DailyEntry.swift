import Foundation
import SwiftData

@Model
final class DailyEntry {
    var date: Date = Date()
    var goal: String = ""

    init(date: Date = .now, goal: String = "") {
        self.date = Calendar.current.startOfDay(for: date)
        self.goal = goal
    }
}
