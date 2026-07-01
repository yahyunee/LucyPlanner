import SwiftUI
import SwiftData

struct EisenhowerMatrixView: View {
    let date: Date

    @Environment(\.modelContext) private var context
    @Query(sort: \Todo.createdAt, order: .reverse) private var todos: [Todo]

    var body: some View {
        VStack(spacing: 8) {
            unsortedStrip

            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    quadrantCell(.doNow)
                    quadrantCell(.decide)
                }
                HStack(spacing: 6) {
                    quadrantCell(.delegate)
                    quadrantCell(.delete)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
    }

    // MARK: - Unsorted strip

    @ViewBuilder
    private var unsortedStrip: some View {
        if unsorted.isEmpty {
            Text("Everything is sorted ✓")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            VStack(alignment: .leading, spacing: 2) {
                Text("Unsorted · \(unsorted.count) — drag into a quadrant, or tap a suggestion")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(unsorted) { todo in
                            UnsortedCard(todo: todo)
                        }
                    }
                }
            }
            .padding(8)
            .background(Color.secondary.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
            .dropDestination(for: String.self) { items, _ in
                applyQuadrant(.unassigned, payload: items.first)
            }
        }
    }

    // MARK: - Quadrant cell

    private func quadrantCell(_ quadrant: Quadrant) -> some View {
        QuadrantCell(quadrant: quadrant, todos: todos(in: quadrant)) { payload in
            applyQuadrant(quadrant, payload: payload)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Data

    private var relevantTodos: [Todo] {
        todos.filter { todo in
            guard todo.completedAt == nil else { return false }
            return todo.scheduledDate == nil
                || Calendar.current.isDate(todo.scheduledDate!, inSameDayAs: date)
        }
    }

    private var unsorted: [Todo] {
        relevantTodos.filter { $0.quadrant == .unassigned }
    }

    private func todos(in quadrant: Quadrant) -> [Todo] {
        relevantTodos.filter { $0.quadrant == quadrant }
    }

    private func applyQuadrant(_ quadrant: Quadrant, payload: String?) -> Bool {
        guard
            let payload,
            let id = PersistentIdentifier.decode(dragPayload: payload),
            let todo = context.model(for: id) as? Todo
        else { return false }
        todo.quadrant = quadrant
        return true
    }
}

// MARK: - Quadrant cell

private struct QuadrantCell: View {
    let quadrant: Quadrant
    let todos: [Todo]
    let onDrop: (String) -> Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(quadrant.title)
                        .font(.subheadline.bold())
                    Text(quadrant.subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(todos.count)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .padding(8)
            .background(quadrant.color.opacity(0.22))

            ScrollView {
                VStack(spacing: 4) {
                    ForEach(todos) { todo in
                        MatrixTodoChip(todo: todo)
                    }
                }
                .padding(6)
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
        .background(quadrant.color.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(quadrant.color.opacity(0.45))
        )
        .dropDestination(for: String.self) { items, _ in
            guard let first = items.first else { return false }
            return onDrop(first)
        }
    }
}

// MARK: - Rows

private struct MatrixTodoChip: View {
    @Bindable var todo: Todo

    var body: some View {
        HStack(spacing: 6) {
            Button {
                todo.completedAt = todo.completedAt == nil ? .now : nil
            } label: {
                Image(systemName: "circle")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)

            Text(todo.title)
                .font(.caption)
                .lineLimit(2)

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
        .background(.background, in: RoundedRectangle(cornerRadius: 5))
        .draggable(todo.persistentModelID.dragPayload) {
            Text(todo.title.isEmpty ? "Todo" : todo.title)
                .font(.caption)
                .padding(6)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
        }
    }
}

private struct UnsortedCard: View {
    @Bindable var todo: Todo

    private var suggestion: Quadrant? {
        EisenhowerSuggestion.suggest(for: todo)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(todo.title.isEmpty ? "Untitled" : todo.title)
                .font(.caption)
                .lineLimit(2)
                .frame(width: 130, alignment: .leading)

            if let suggestion {
                Button {
                    todo.quadrant = suggestion
                } label: {
                    Text("→ \(suggestion.title)")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(suggestion.color)
                }
                .buttonStyle(.borderless)
                .help("Suggested from the title — tap to accept")
            } else {
                Text("no hint")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(8)
        .frame(height: 64, alignment: .top)
        .background(.background, in: RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(
                    Color.secondary.opacity(0.4),
                    style: StrokeStyle(lineWidth: 1, dash: [3])
                )
        )
        .draggable(todo.persistentModelID.dragPayload) {
            Text(todo.title.isEmpty ? "Todo" : todo.title)
                .font(.caption)
                .padding(6)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
        }
    }
}

// MARK: - Quadrant color

extension Quadrant {
    var color: Color {
        switch self {
        case .doNow:      return .green
        case .decide:     return .blue
        case .delegate:   return .red
        case .delete:     return .gray
        case .unassigned: return .gray
        }
    }
}
