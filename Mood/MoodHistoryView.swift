import SwiftUI
import SwiftData

struct MoodHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var store = MoodStore()

    @State private var selectedPeriod = 7
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Период", selection: $selectedPeriod) {
                        Text("7 дней").tag(7)
                        Text("30 дней").tag(30)
                    }
                    .pickerStyle(.segmented)
                    .accessibilityHint("Выберите период отображения истории")

                    if store.history.isEmpty {
                        ContentUnavailableView(
                            "Пока нет отметок",
                            systemImage: "chart.xyaxis.line",
                            description: Text(
                                "Оцените уровень спокойствия, и отметка появится здесь."
                            )
                        )
                        .frame(minHeight: 270)
                    } else {
                        MoodChartView(
                            entries: store.history,
                            days: selectedPeriod
                        )

                        historyList
                    }

                    if let errorMessage = store.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label(
                            "Удалить историю состояний",
                            systemImage: "trash"
                        )
                        .font(.system(.body, design: .rounded).weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.red)
                    .background(.red.opacity(0.10))
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 18,
                            style: .continuous
                        )
                    )
                    .disabled(store.history.isEmpty)
                }
                .padding(20)
            }
            .background(
                AppAdaptiveColor.warmFormBackground
                    .ignoresSafeArea()
            )
            .navigationTitle("История спокойствия")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                store.configure(modelContext: modelContext)
                store.loadHistory(days: selectedPeriod)
            }
            .onChange(of: selectedPeriod) { _, newValue in
                store.loadHistory(days: newValue)
            }
            .confirmationDialog(
                "Удалить всю историю состояний?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Удалить", role: .destructive) {
                    store.deleteHistory()
                }

                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Это действие нельзя отменить.")
            }
        }
    }

    private var historyList: some View {
        LazyVStack(spacing: 10) {
            ForEach(store.history.reversed(), id: \.id) { entry in
                if let level = entry.moodLevel {
                    HStack(spacing: 14) {
                        Text(level.emoji)
                            .font(.system(size: 30))
                            .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(formattedDate(entry.recordedAt))
                                .font(.system(.body, design: .rounded).weight(.semibold))

                            Text(level.title)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Circle()
                            .fill(level.color)
                            .frame(width: 16, height: 16)
                            .accessibilityHidden(true)
                    }
                    .padding(14)
                    .background(AppAdaptiveColor.secondaryBackground)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16,
                            style: .continuous
                        )
                    )
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(
                        L10n.format(
                            "%@, состояние «%@»",
                            formattedDate(entry.recordedAt),
                            level.title
                        )
                    )
                }
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = AppLanguage.selected.locale
        formatter.timeZone = .current
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
