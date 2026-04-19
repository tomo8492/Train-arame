# WakeAtStation (駅ウェイク)

終電間際に寝過ごして帰れなくなる人を救う、目的地駅接近バイブ通知アプリ。
Apple Watch の連続 Taptic で確実に起こす。

詳細仕様は [SPEC.md](./SPEC.md) を参照。

## リポジトリ構成

```
Train-arame/
├── SPEC.md                      # 開発仕様書
├── project.yml                  # XcodeGen 設定
├── Makefile                     # xcodegen / build / test
├── ios/
│   ├── WakeAtStation/           # iPhone アプリ (SwiftUI)
│   │   ├── WakeAtStationApp.swift
│   │   ├── Models/
│   │   ├── Services/
│   │   ├── Views/
│   │   ├── Resources/           # Info.plist / stations.json / Assets.xcassets
│   │   └── WakeAtStation.entitlements
│   └── WakeAtStationWatch/      # Apple Watch アプリ
│       ├── WakeAtStationWatchApp.swift
│       ├── WatchArrivalReceiver.swift
│       ├── Views/
│       └── Resources/
├── tests/
│   └── WakeAtStationTests/
├── data/
│   └── build_stations.py        # 国土数理院 N02 → stations.json 変換
└── docs/
    └── PRIVACY.md
```

## セットアップ

### 前提

- macOS + Xcode 15 以降
- [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`
- Apple Developer Program (実機テスト/App Store 申請時)

### Xcode プロジェクト生成

```bash
make project   # project.yml から WakeAtStation.xcodeproj を生成
make open      # Xcode で開く
```

### バンドル駅データ

**日本全国 約10,136駅 / 552路線** を `ios/WakeAtStation/Resources/stations.json`
にバンドル済み（1.7MB）。JR 全社・大手私鉄・地下鉄・LRT を網羅。

出典: 国土交通省「国土数値情報（鉄道データ）N02-24」。
再生成は以下:

```bash
pip install pyshp
python data/build_stations.py data/raw/UTF-8/N02-24_Station.shp \
    -o ios/WakeAtStation/Resources/stations.json
```

### 実機で動かす前に

- Xcode で Signing Team を設定
- `project.yml` の `DEVELOPMENT_TEAM` を自分の Team ID に
- バンドルID `com.tomo.wakeatstation` は適宜変更
- App Icon を `Resources/Assets.xcassets/AppIcon.appiconset` に追加

### テスト

```bash
make test
```

## 主要機能（実装状況）

### Phase 1 MVP (✅ コード実装済み)

- [x] 駅検索（駅名・かな・路線名）
- [x] お気に入り登録 / 永続化（UserDefaults）
- [x] GPS 近接検知（`CLCircularRegion` 500m/1km/2km 切替）
- [x] バックグラウンド Region Monitoring
- [x] 時間指定通知（`.timeSensitive`）+ 連続バイブ
- [x] Apple Watch WCSession 連携 + 連続 Taptic
- [x] Watch 側「起きた！」ボタンで停止

### Phase 2 (✅ 実装済み)

- [x] **二段階アラート**: 外側 region (2×半径) で予告通知、内側で本通知
- [x] 予告バイブは短時間・軽め、本通知は 2 分間継続

### Phase 3+（残タスク）

- [ ] Critical Alerts 申請（サイレントでも確実発火させたい場合）
- [ ] URL Scheme 受信（Yahoo!乗換案内連携）
- [ ] Complication
- [ ] シェア機能
- [ ] App Icon / Launch Screen デザイン
- [ ] プライバシーポリシー Web 公開

## リリース前チェックリスト

- [ ] Apple Developer Program 登録
- [ ] 本番用 bundle ID 確定・商標確認
- [ ] Privacy Manifest (`PrivacyInfo.xcprivacy`) 追加
- [ ] スクリーンショット撮影（6.7" / 6.1" / Watch 45mm）
- [ ] App Store Connect メタデータ入稿
- [ ] TestFlight 内部 → 外部 β 配布
- [ ] 審査提出

## ライセンス

Proprietary. 駅データは国土数理院「国土数値情報 鉄道データ」(出典明記で商用利用可) を利用予定。
