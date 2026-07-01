import EventKit
import Foundation
import SwiftUI

@MainActor
final class CalendarService: ObservableObject {
    enum Access: Equatable {
        case unknown, denied, restricted, granted, writeOnly
    }

    @Published private(set) var access: Access = .unknown
    @Published private(set) var events: [EKEvent] = []
    @Published private(set) var loadedDate: Date?
    @Published private(set) var availableCalendars: [EKCalendar] = []
    @Published var excludedCalendarIDs: Set<String> {
        didSet {
            UserDefaults.standard.set(
                Array(excludedCalendarIDs),
                forKey: Self.excludedKey
            )
            if let date = loadedDate {
                Task { await self.loadEvents(for: date) }
            }
        }
    }

    private static let excludedKey = "excludedCalendarIDs"

    private let store = EKEventStore()
    private var changeObserver: NSObjectProtocol?

    init() {
        let saved = UserDefaults.standard.array(forKey: Self.excludedKey) as? [String] ?? []
        self.excludedCalendarIDs = Set(saved)
        access = currentAccess()
        if access == .granted {
            refreshCalendars()
        }
        changeObserver = NotificationCenter.default.addObserver(
            forName: .EKEventStoreChanged,
            object: store,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.refreshCalendars()
                if let date = self.loadedDate {
                    await self.loadEvents(for: date)
                }
            }
        }
    }

    deinit {
        if let changeObserver {
            NotificationCenter.default.removeObserver(changeObserver)
        }
    }

    // MARK: - Authorization

    func requestAccess() async {
        do {
            let granted = try await store.requestFullAccessToEvents()
            access = granted ? .granted : .denied
            if granted { refreshCalendars() }
        } catch {
            access = .denied
        }
    }

    func refreshCalendars() {
        availableCalendars = store.calendars(for: .event).sorted { lhs, rhs in
            let lhsSource = lhs.source.title
            let rhsSource = rhs.source.title
            if lhsSource != rhsSource { return lhsSource < rhsSource }
            return lhs.title < rhs.title
        }
    }

    private func currentAccess() -> Access {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined: return .unknown
        case .denied: return .denied
        case .restricted: return .restricted
        case .fullAccess, .authorized: return .granted
        case .writeOnly: return .writeOnly
        @unknown default: return .unknown
        }
    }

    // MARK: - Loading

    func loadEvents(for date: Date) async {
        loadedDate = date
        guard access == .granted else {
            events = []
            return
        }
        let cal = Calendar.current
        let dayStart = cal.startOfDay(for: date)
        guard let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart) else { return }
        let included = availableCalendars.filter { !excludedCalendarIDs.contains($0.calendarIdentifier) }
        // Passing an empty array would still match all calendars, so bail early.
        guard !included.isEmpty else {
            events = []
            return
        }
        let predicate = store.predicateForEvents(withStart: dayStart, end: dayEnd, calendars: included)
        let fetched = store.events(matching: predicate)
            .filter { !$0.isAllDay }
            .sorted { $0.startDate < $1.startDate }
        events = fetched
    }

    // MARK: - Mutation

    /// Delete a single occurrence of an event. For recurring events,
    /// pass `.thisEvent` (default) to remove just today's instance.
    func delete(_ event: EKEvent, span: EKSpan = .thisEvent) throws {
        try store.remove(event, span: span, commit: true)
        events.removeAll { $0.eventIdentifier == event.eventIdentifier }
    }
}
