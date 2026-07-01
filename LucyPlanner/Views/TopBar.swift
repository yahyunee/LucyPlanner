import SwiftUI
import SwiftData

struct TopBar: View {
    @Binding var date: Date
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var calendar: CalendarService
    @Query private var entries: [DailyEntry]
    @State private var showingCalendarSettings = false

    private var todaysEntry: DailyEntry? {
        let start = Calendar.current.startOfDay(for: date)
        return entries.first { Calendar.current.isDate($0.date, inSameDayAs: start) }
    }

    private var goalBinding: Binding<String> {
        Binding(
            get: { todaysEntry?.goal ?? "" },
            set: { newValue in
                if let entry = todaysEntry {
                    entry.goal = newValue
                } else {
                    let entry = DailyEntry(date: date, goal: newValue)
                    context.insert(entry)
                }
            }
        )
    }

    var body: some View {
        HStack(spacing: 16) {
            Button {
                date = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
            } label: {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.borderless)

            DatePicker("", selection: $date, displayedComponents: .date)
                .labelsHidden()
                .frame(width: 160)

            Button {
                date = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.borderless)

            Button("Today") {
                date = Calendar.current.startOfDay(for: .now)
            }
            .buttonStyle(.borderless)

            Spacer()

            TextField("Today's goal…", text: goalBinding, axis: .horizontal)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 640)
                .font(.title3)

            Spacer()

            Menu {
                Button {
                    if calendar.access == .unknown {
                        Task { await calendar.requestAccess() }
                    }
                    showingCalendarSettings = true
                } label: {
                    Label("Calendars…", systemImage: "calendar")
                }
            } label: {
                Image(systemName: "gearshape")
                    .imageScale(.large)
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
            .help("Settings")
        }
        .padding(.horizontal)
        .sheet(isPresented: $showingCalendarSettings) {
            CalendarSettingsSheet()
                .environmentObject(calendar)
        }
    }
}
