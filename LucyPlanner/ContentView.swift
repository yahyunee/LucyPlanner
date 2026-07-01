import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: .now)

    var body: some View {
        VStack(spacing: 0) {
            TopBar(date: $selectedDate)
                .frame(height: 72)
                .background(.bar)

            Divider()

            HStack(spacing: 0) {
                TimeTablePanel(date: selectedDate)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider()

                TodoListPanel(date: selectedDate)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            Divider()

            HabitTrackerPanel()
                .frame(height: 160)
                .background(.bar)
        }
        .frame(minWidth: 1100, minHeight: 720)
    }
}

#Preview {
    ContentView()
        .environmentObject(CalendarService())
        .modelContainer(
            for: [
                DailyEntry.self,
                Todo.self,
                TimeBlock.self,
                Habit.self,
                HabitLog.self,
                Project.self,
                Tag.self,
            ],
            inMemory: true
        )
}
