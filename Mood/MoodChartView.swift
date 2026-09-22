import Charts
import SwiftUI

private struct MoodChartPoint: Identifiable {
    let date: Date
    let level: MoodLevel

    var id: String {
        "\(MoodDayKey.make(for: date))-\(level.rawValue)"
    }
}

private struct MoodChartSegment: Identifiable {
    let id: Int
    let points: [MoodChartPoint]
}

struct MoodChartView: View {
    let entries: [MoodEntry]
    let days: Int

    var body: some View {
        Chart {
            ForEach(segments) { segment in
                ForEach(segment.points) { point in
                    LineMark(
                        x: .value("Дата отметки", point.date),
                        y: .value(
                            "Состояние",
                            point.level.rawValue
                        ),
                        series: .value(
                           "Отрезок",
                            segment.id
                        )
                    )
                    .foregroundStyle(Color.brown)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                }
            }

            ForEach(points) { point in
                PointMark(
                    x: .value("Дата отметки", point.date),
                    y: .value(
                        "Состояние",
                        point.level.rawValue
                    )
                )
                .foregroundStyle(point.level.color)
                .symbolSize(95)
                .accessibilityLabel(
                    localizedStateDescription(for: point)
                )
            }
        }
        .chartYScale(domain: 0...4)
        .chartYAxis {
            AxisMarks(values: [0, 1, 2, 3, 4]) { value in
                AxisGridLine()
                    .foregroundStyle(.gray.opacity(0.22))

                AxisValueLabel {
                    if let rawValue = value.as(Int.self),
                       let level = MoodLevel(rawValue: rawValue) {
                        Text(
                            "\(level.emoji) \(AppLanguage.selected.localized(level.title))"
                        )
                            .font(.caption2)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: days == 7 ? 7 : 6)) {
                AxisGridLine()
                    .foregroundStyle(.gray.opacity(0.12))
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
            }
        }
        .frame(height: 270)
        .accessibilityLabel(
            String(
                format: AppLanguage.selected.localized(
                    "График истории состояний за %lld дней"
                ),
                locale: AppLanguage.selected.locale,
                days
            )
        )
    }

    private var points: [MoodChartPoint] {
        entries.compactMap { entry in
            guard let level = entry.moodLevel else { return nil }
            return MoodChartPoint(
                date: entry.recordedAt,
                level: level
            )
        }
    }

    private var segments: [MoodChartSegment] {
        guard !points.isEmpty else { return [] }

        var result: [MoodChartSegment] = []
        var currentPoints: [MoodChartPoint] = []
        var previousDate: Date?
        var segmentID = 0
        let calendar = Calendar.current

        for point in points {
            if let previousDate,
               let dayDistance = calendar.dateComponents(
                   [.day],
                   from: calendar.startOfDay(for: previousDate),
                   to: calendar.startOfDay(for: point.date)
               ).day,
               dayDistance > 1 {
                if !currentPoints.isEmpty {
                    result.append(
                        MoodChartSegment(
                            id: segmentID,
                            points: currentPoints
                        )
                    )
                    segmentID += 1
                }
                currentPoints = []
            }

            currentPoints.append(point)
            previousDate = point.date
        }

        if !currentPoints.isEmpty {
            result.append(
                MoodChartSegment(
                    id: segmentID,
                    points: currentPoints
                )
            )
        }

        return result
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = AppLanguage.selected.locale
        formatter.timeZone = .current
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func localizedStateDescription(
        for point: MoodChartPoint
    ) -> String {
        String(
            format: AppLanguage.selected.localized(
                "%@, состояние «%@»"
            ),
            locale: AppLanguage.selected.locale,
            formattedDate(point.date),
            AppLanguage.selected.localized(point.level.title)
        )
    }
}
