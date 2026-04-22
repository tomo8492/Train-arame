import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss
    @State private var page: Int = 0

    var body: some View {
        VStack {
            TabView(selection: $page) {
                OnboardPage(
                    icon: "alarm.waves.left.and.right.fill",
                    title: "寝てても降りられる",
                    body: "目的地の駅が近づいたら、iPhone と Apple Watch のバイブであなたを起こします。"
                ).tag(0)

                OnboardPage(
                    icon: "applewatch.radiowaves.left.and.right",
                    title: "手首で確実に",
                    body: "Apple Watch の連続 Taptic で、手首を叩いて起こします。\nサイレント中でも振動で気づけます。"
                ).tag(1)

                OnboardPage(
                    icon: "location.circle.fill",
                    title: "位置情報を「常に許可」",
                    body: "電車で寝ていても降車駅への接近を検知するために、\nバックグラウンドでの位置情報利用が必要です。\n位置情報は端末内でのみ使用し、外部送信しません。"
                ).tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button {
                if page < 2 {
                    withAnimation { page += 1 }
                } else {
                    locationManager.requestAuthorization()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        locationManager.requestAlwaysAuthorization()
                    }
                    dismiss()
                }
            } label: {
                Text(page < 2 ? "次へ" : "位置情報を許可して始める")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .interactiveDismissDisabled()
    }
}

private struct OnboardPage: View {
    let icon: String
    let title: String
    let body: String

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundStyle(.tint)
            Text(title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text(body)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
        .padding()
    }
}
