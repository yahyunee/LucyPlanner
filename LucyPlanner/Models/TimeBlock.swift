import Foundation
import SwiftData

@Model
final class TimeBlock {
    var date: Date = Date()
    var startTime: Date = Date()
    var endTime: Date = Date()
    var note: String = ""

    @Relationship(deleteRule: .nullify) var todo: Todo? = nil

    init(
        date: Date = .now,
        startTime: Date = .now,
        endTime: Date = .now,
        note: String = "",
        todo: Todo? = nil
    ) {
        self.date = Calendar.current.startOfDay(for: date)
        self.startTime = startTime
        self.endTime = endTime
        self.note = note
        self.todo = todo
    }
}
