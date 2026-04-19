# WakeAtStation (駅ウェイク)

終電間際に寝過ごして帰れなくなる人を救う、目的地駅接近バイブ通知アプリ。

詳細は [SPEC.md](./SPEC.md) を参照。

## リポジトリ構成

```
Train-arame/
├── SPEC.md                      # 開発仕様書
├── README.md
├── ios/                         # iOS / watchOS アプリ (SwiftUI)
│   ├── WakeAtStation/           # iPhone アプリ本体
│   │   ├── WakeAtStationApp.swift
│   │   ├── Models/
│   │   ├── Services/
│   │   └── Views/
│   └── WakeAtStationWatch/      # Apple Watch アプリ
│       ├── WakeAtStationWatchApp.swift
│       └── Views/
├── data/                        # 駅データ関連
│   └── build_stations.py        # 国土数理院データ → JSON 変換
└── docs/
    └── PRIVACY.md               # プライバシーポリシー草案
```

## 開発フェーズ

- [x] Phase -1: 仕様書作成
- [ ] Phase 0: SwiftUI + Core Location + WatchKit 学習
- [ ] Phase 1: MVP (駅検索・GPS通知・基本UI)
- [ ] Phase 2: Apple Watch 対応 / 強バイブ
- [ ] Phase 3: β テスト (TestFlight)
- [ ] Phase 4: App Store 申請・公開

## ライセンス

Proprietary. 駅データは国土数理院「鉄道データ」(CC BY 4.0 相当) を利用予定。
