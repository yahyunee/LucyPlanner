import SwiftUI
import SwiftData

@main
struct LucyPlannerApp: App {
    let modelContainer: ModelContainer
    @StateObject private var calendarService = CalendarService()

    init() {
        let schema = Schema([
            DailyEntry.self,
            Todo.self,
            TimeBlock.self,
            Habit.self,
            HabitLog.self,
            Project.self,
            Tag.self,
        ])

        // Local-only for now. CloudKit sync is wired up in Phase 4 (iPhone).
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )

        do {
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // Dev-time recovery: an on-disk store left over from an older model
            // version can fail to open. Discard it and start fresh.
            // Remove this fallback in Phase 6, once there is real data to protect.
            print("⚠️ ModelContainer failed (\(error)). Resetting local store.")
            LucyPlannerApp.deleteStore(at: configuration.url)
            do {
                modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            } catch {
                fatalError("ModelContainer still failing after store reset: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(calendarService)
                .task {
                    if calendarService.access == .unknown {
                        await calendarService.requestAccess()
                    }
                }
        }
        .modelContainer(modelContainer)
    }

    private static func deleteStore(at url: URL) {
        let fileManager = FileManager.default
        for suffix in ["", "-shm", "-wal"] {
            try? fileManager.removeItem(at: URL(fileURLWithPath: url.path + suffix))
        }
    }
}
