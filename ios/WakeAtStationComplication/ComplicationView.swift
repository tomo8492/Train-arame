import WidgetKit
import SwiftUI

struct WakeAtStationComplication: Widget {
    let kind = "WakeAtStationComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ComplicationProvider()) { entry in
            ComplicationView(entry: entry)
        }
        .configurationDisplayName("駅ウェイク")
        .description("次の降車駅と監視状態を表示")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryInline,
            .accessoryRectangular
        ])
    }
}

struct ComplicationView: View {
    let entry: ComplicationEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryCircular: circular
        case .accessoryCorner: corner
        case .accessoryInline: inline
        case .accessoryRectangular: rectangular
        default: inline
        }
    }

    private var circular: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Image(systemName: entry.isMonitoring
                      ? "alarm.waves.left.and.right.fill"
                      : "alarm")
                    .font(.title3)
                Text(entry.stationName ?? "—")
                    .font(.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
    }

    private var corner: some View {
        Image(systemName: "alarm.fill")
            .widgetLabel {
                Text(entry.stationName ?? "駅未設定")
            }
    }

    private var inline: some View {
        Label {
            Text(entry.stationName ?? "駅未設定")
        } icon: {
            Image(systemName: entry.isMonitoring ? "alarm.waves.left.and.right.fill" : "alarm")
        }
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: entry.isMonitoring
                      ? "alarm.waves.left.and.right.fill"
                      : "alarm")
                Text(entry.stationName ?? "未設定")
                    .font(.caption.bold())
                    .lineLimit(1)
            }
            if let line = entry.lines.first {
                Text(line)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Text(entry.isMonitoring ? "監視中" : "停止中")
                .font(.caption2)
                .foregroundStyle(entry.isMonitoring ? .green : .secondary)
        }
    }
}
