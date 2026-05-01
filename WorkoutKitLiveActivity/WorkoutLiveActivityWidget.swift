import ActivityKit
import SwiftUI
import WidgetKit

@main
struct WorkoutKitLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        WorkoutLiveActivityWidget()
    }
}

struct WorkoutLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            // Lock screen / banner UI
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.state.currentExerciseName, systemImage: "dumbbell.fill")
                        .font(.caption)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.completedSets)/\(context.state.totalSets)")
                        .font(.caption.bold())
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if context.state.isResting {
                        Text("休憩 \(context.state.secondsRemaining)秒")
                            .font(.caption)
                    }
                }
            } compactLeading: {
                Image(systemName: "dumbbell.fill")
                    .foregroundStyle(.tint)
            } compactTrailing: {
                Text("\(context.state.completedSets)/\(context.state.totalSets)")
                    .font(.caption2.bold())
            } minimal: {
                Image(systemName: "dumbbell.fill")
            }
        }
    }
}

private struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<WorkoutActivityAttributes>

    var body: some View {
        HStack {
            Image(systemName: "dumbbell.fill")
                .foregroundStyle(.tint)
            VStack(alignment: .leading) {
                Text(context.state.currentExerciseName)
                    .font(.headline)
                    .lineLimit(1)
                if context.state.isResting {
                    Text("休憩 \(context.state.secondsRemaining)秒")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text("\(context.state.completedSets)/\(context.state.totalSets)")
                .font(.title3.bold())
        }
        .padding()
        .activityBackgroundTint(Color(.systemBackground).opacity(0.8))
    }
}
