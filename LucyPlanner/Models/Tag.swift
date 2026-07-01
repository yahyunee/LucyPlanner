import Foundation
import SwiftData

@Model
final class Tag {
    var name: String = ""
    var createdAt: Date = Date()

    @Relationship(deleteRule: .nullify) var todos: [Todo]? = []

    init(name: String = "") {
        self.name = name
        self.createdAt = .now
    }
}
