import SwiftUI

struct WatchRootView: View {
    @EnvironmentObject var receiver: WatchArrivalReceiver

    var body: some View {
        ZStack {
            if receiver.isAlerting {
                AlertingView()
            } else {
                IdleView()
            }
        }
    }
}

private struct IdleView: View {
    @EnvironmentObject var receiver: WatchArrivalReceiver

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "alarm.waves.left.and.right.fill")
                .font(.largeTitle)
                .foregroundStyle(.tint)
            Text(receiver.currentStationName ?? "駅未設定")
                .font(.headline)
            if let line = receiver.currentLinesSummary {
                Text(line).font(.caption).foregroundStyle(.secondary).lineLimit(2)
            }
            Text("iPhoneで降車駅を設定してください")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

private struct AlertingView: View {
    @EnvironmentObject var receiver: WatchArrivalReceiver

    private var isPreAlert: Bool { receiver.currentStage == "preAlert" }

    var body: some View {
        VStack(spacing: 12) {
            Text(isPreAlert ? "もうすぐ（予告）" : "まもなく降車")
                .font(.title3)
                .foregroundStyle(isPreAlert ? .secondary : .primary)
            Text(receiver.currentStationName ?? "目的地")
                .font(.title.bold())
            if let line = receiver.currentLinesSummary {
                Text(line).font(.caption).foregroundStyle(.secondary).lineLimit(2)
            }
            Button {
                receiver.acknowledge()
            } label: {
                Text(isPreAlert ? "了解" : "起きた！停止")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(isPreAlert ? .orange : .red)
        }
        .padding()
    }
}
