import SwiftUI
import SwiftData

enum TodoViewMode: String, CaseIterable {
    case list = "List"
    case matrix = "Matrix"
}

struct TodoListPanel: View {
    let date: Date

    @Environment(\.modelContext) private var context
    @Query(sort: \Todo.createdAt, order: .reverse) private var todos: [Todo]

    @State private var newTitle: String = ""
    @State private var viewMode: TodoViewMode = .list

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Todos")
                    .font(.headline)
                Spacer()
                Text("\(inboxTodos.count + dayTodos.count) open")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 12)

            Picker("View", selection: $viewMode) {
                ForEach(TodoViewMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.horizontal)

            HStack {
                TextField("Brain-dump anything…", text: $newTitle)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { addTodo() }
                Button("Add") { addTodo() }
                    .keyboardShortcut(.return, modifiers: [])
                    .disabled(newTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal)

            switch viewMode {
            case .list:   listView
            case .matrix: EisenhowerMatrixView(date: date)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: - List

    private var listView: some View {
        List {
                Section("\(dayLabel) · \(dayTodos.count)") {
                    if dayTodos.isEmpty {
                        Text("No todos planned for this day yet.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    ForEach(dayTodos) { todo in
                        TodoRow(todo: todo, viewedDate: date)
                    }
                }

                Section("Inbox · \(inboxTodos.count)") {
                    if inboxTodos.isEmpty {
                        Text("Nothing waiting. Brain-dump above.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    ForEach(inboxTodos) { todo in
                        TodoRow(todo: todo, viewedDate: date)
                    }
                }

                if !doneTodos.isEmpty {
                    Section("Done · \(doneTodos.count)") {
                        ForEach(doneTodos) { todo in
                            TodoRow(todo: todo, viewedDate: date)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
    }

    // MARK: - Derived lists

    private var inboxTodos: [Todo] {
        todos.filter { $0.scheduledDate == nil && $0.completedAt == nil }
    }

    private var dayTodos: [Todo] {
        todos.filter { todo in
            todo.completedAt == nil
                && isSameDay(todo.scheduledDate, date)
        }
    }

    private var doneTodos: [Todo] {
        todos
            .filter { todo in
                guard let completedAt = todo.completedAt else { return false }
                return Calendar.current.isDate(completedAt, inSameDayAs: date)
            }
            .sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
    }

    private var dayLabel: String {
        if Calendar.current.isDateInToday(date) { return "Today" }
        if Calendar.current.isDateInTomorrow(date) { return "Tomorrow" }
        return date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }

    // MARK: - Helpers

    private func isSameDay(_ a: Date?, _ b: Date) -> Bool {
        guard let a else { return false }
        return Calendar.current.isDate(a, inSameDayAs: b)
    }

    private func addTodo() {
        let trimmed = newTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        context.insert(Todo(title: trimmed))
        newTitle = ""
    }

}

// MARK: - Row

private struct TodoRow: View {
    @Bindable var todo: Todo
    let viewedDate: Date

    @Environment(\.modelContext) private var context

    var body: some View {
        HStack(spacing: 8) {
            Button {
                todo.completedAt = todo.completedAt == nil ? .now : nil
            } label: {
                Image(systemName: todo.isComplete ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(todo.isComplete ? .green : .secondary)
            }
            .buttonStyle(.borderless)

            Image(systemName: "line.3.horizontal")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .help("Drag onto the time table to block a time")

            TextField("", text: $todo.title)
                .textFieldStyle(.plain)
                .strikethrough(todo.isComplete)

            Spacer(minLength: 4)

            if todo.quadrant != .unassigned {
                Text(todo.quadrant.title)
                    .font(.caption2)
                    .foregroundStyle(todo.quadrant.color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(todo.quadrant.color.opacity(0.15), in: Capsule())
            }

            Menu {
                Section("Schedule") {
                    Button("Plan for this day") { todo.schedule(to: viewedDate) }
                    Button("Move to next day") { todo.moveToNextDay(reference: viewedDate) }
                    Button("Send to Inbox") { todo.schedule(to: nil) }
                }
                Section("Priority") {
                    ForEach(Quadrant.allCases) { quadrant in
                        Button {
                            todo.quadrant = quadrant
                        } label: {
                            if todo.quadrant == quadrant {
                                Label(quadrant.title, systemImage: "checkmark")
                            } else {
                                Text(quadrant.title)
                            }
                        }
                    }
                }
                Divider()
                Button("Delete", role: .destructive) { context.delete(todo) }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
        }
        .opacity(todo.isComplete ? 0.5 : 1)
        .draggable(todo.persistentModelID.dragPayload) {
            Text(todo.title.isEmpty ? "Todo" : todo.title)
                .font(.caption)
                .padding(6)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
        }
    }
}
