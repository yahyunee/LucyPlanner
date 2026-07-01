import Foundation
import SwiftData

@Model
final class Project {
    var name: String = ""
    var colorHex: String = "#007AFF"
    var createdAt: Date = Date()

    @Relationship(deleteRule: .nullify) var todos: [Todo]? = []

    init(name: String = "", colorHex: String = "#007AFF") {
        self.name = name
        self.colorHex = colorHex
        self.createdAt = .now
    }
}
