import Foundation

enum Quadrant: String, Codable, CaseIterable, Identifiable {
    case doNow = "do"
    case decide = "decide"
    case delegate = "delegate"
    case delete = "delete"
    case unassigned = "unassigned"

    var id: String { rawValue }

    /// The four real quadrants, excluding `.unassigned`.
    static var matrixCases: [Quadrant] { [.doNow, .decide, .delegate, .delete] }

    var title: String {
        switch self {
        case .doNow: return "Do"
        case .decide: return "Decide"
        case .delegate: return "Delegate"
        case .delete: return "Delete"
        case .unassigned: return "Unassigned"
        }
    }

    var subtitle: String {
        switch self {
        case .doNow: return "Important + Urgent"
        case .decide: return "Important + Not Urgent"
        case .delegate: return "Not Important + Urgent"
        case .delete: return "Not Important + Not Urgent"
        case .unassigned: return "Not yet prioritized"
        }
    }
}
