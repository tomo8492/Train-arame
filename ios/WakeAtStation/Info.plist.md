# Info.plist 設定メモ (Xcode プロジェクト作成時に反映)

## 必須キー

- `NSLocationWhenInUseUsageDescription`
  「電車の移動中に降車駅への接近を検知し、通知するために位置情報を使用します。」
- `NSLocationAlwaysAndWhenInUseUsageDescription`
  「アプリがバックグラウンドでも降車駅接近を検知し、寝過ごしを防ぐために常時位置情報を使用します。」
- `UIBackgroundModes`: `location`, `remote-notification`, `audio` (バイブ継続用)
- `NSUserTrackingUsageDescription`: (広告非搭載のため不要だが保険で)

## Capabilities

- Background Modes: Location updates / Background fetch
- Push Notifications (将来、Critical Alerts 権限申請を Apple へ)
- App Groups (Watch と設定共有する場合)
