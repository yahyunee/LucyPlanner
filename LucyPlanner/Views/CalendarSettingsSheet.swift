import SwiftUI
import EventKit

struct CalendarSettingsSheet: View {
    @EnvironmentObject private var calendar: CalendarService
    @Environment(\.dismiss) private var dismiss

    private var grouped: [(source: String, calendars: [EKCalendar])] {
        let dict = Dictionary(grouping: calendar.availableCalendars) { $0.source.title }
        return dict
            .map { (source: $0.key, calendars: $0.value) }
            .sorted { $0.source < $1.source }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Calendars to show")
                    .font(.title2.bold())
                Spacer()
                Button("Refresh") { calendar.refreshCalendars() }
                    .buttonStyle(.borderless)
            }

            Text("Events from unchecked calendars are hidden from the time table.")
                .font(.caption)
                .foregroundStyle(.secondary)

            if calendar.availableCalendars.isEmpty {
                ContentUnavailableView(
                    "No calendars found",
                    systemImage: "calendar.badge.exclamationmark",
                    description: Text("Grant Full Access in System Settings › Privacy › Calendars.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(grouped, id: \.source) { group in
                        Section(group.source) {
                            ForEach(group.calendars, id: \.calendarIdentifier) { cal in
                                row(for: cal)
                            }
                        }
                    }
                }
                .listStyle(.inset)
            }

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 420, height: 460)
    }

    private func row(for cal: EKCalendar) -> some View {
        let id = cal.calendarIdentifier
        let included = Binding(
            get: { !calendar.excludedCalendarIDs.contains(id) },
            set: { newValue in
                if newValue {
                    calendar.excludedCalendarIDs.remove(id)
                } else {
                    calendar.excludedCalendarIDs.insert(id)
                }
            }
        )
        return Toggle(isOn: included) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(cgColor: cal.cgColor))
                    .frame(width: 10, height: 10)
                Text(cal.title)
            }
        }
    }
}
