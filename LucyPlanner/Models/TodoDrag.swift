import Foundation
import SwiftData

/// Encodes a SwiftData object's identifier as a plain string so it can ride
/// along a SwiftUI `.draggable` / `.dropDestination` pair without a custom UTType.
extension PersistentIdentifier {
    var dragPayload: String {
        guard let data = try? JSONEncoder().encode(self) else { return "" }
        return data.base64EncodedString()
    }

    static func decode(dragPayload: String) -> PersistentIdentifier? {
        guard let data = Data(base64Encoded: dragPayload) else { return nil }
        return try? JSONDecoder().decode(PersistentIdentifier.self, from: data)
    }
}
