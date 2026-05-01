# WorkoutKit — CLAUDE.md

> 実装時はこのファイルの記述を最優先とする。

---

## §1. Project Summary

**WorkoutKit** — 筋トレ記録 × 最大挙上重量推定 iOS アプリ

- Platform: iOS 17.0+ / iPhone
- Stack: Swift 5.9 / SwiftUI / SwiftData / HealthKit
- Target: 筋トレ習慣者（週3回以上）

---

## §7. Architecture

```
WorkoutKit/App/          → エントリポイント
WorkoutKit/Features/     → UI層（View + @Observable Store）
  Dashboard/             → ホーム・直近ログ
  Workout/               → セッション記録
  Exercise/              → 種目一覧・履歴
  Profile/               → 設定・プロフィール
WorkoutKit/Core/         → ビジネスロジック（純粋関数）
  Calculator/            → OneRepMaxCalculator
WorkoutKit/Resources/    → exercises_seed.json / PrivacyInfo.xcprivacy
Config/                  → Debug.xcconfig / Beta.xcconfig / Release.xcconfig
Tests/WorkoutKitTests/   → Swift Testing ユニットテスト
```

### §7.1 データフロー

```
View → @Observable Store → Repository → SwiftData
```

- View は Store の `@Observable` プロパティを監視
- Store はビジネスロジックを Core/ に委譲
- Repository プロトコル経由のみ SwiftData にアクセス

---

## §11. Key Rules

### §11.1 アーキテクチャ

- Clean Architecture の 4 層: App / Features / Core / Infrastructure
- 依存関係は内側へのみ（Core は Features に依存しない）

### §11.2 SwiftData

- `@Model` クラスは `Domain/Models/` に集約
- View から直接 `@Query` 禁止（Repository 経由のみ）
- `ModelContainer` は App 層で 1 つのみ生成

### §11.3 HealthKit

- 権限取得は起動時に一度だけ
- バックグラウンド配信は歩数・ワークアウトのみ

### §11.4 NGリスト（厳禁）

| 禁止事項 | 代替 |
|---|---|
| `print(...)` | `#if DEBUG` + Logger |
| 強制アンラップ `!` | `guard let` / `if let` |
| `.shared` Singleton パターン | 依存注入（DI） |
| `ViewModel` suffix クラス | `@State` または `@Observable Store` |
| ハードコード文字列（UI表示） | `Localizable.xcstrings` |
| 1ファイル 300行超 | 適切なファイル分割 |

### §-1.7 テスト必須対象

- `OneRepMaxCalculator` → Swift Testing で 6 本以上のユニットテスト（全式・境界値を網羅）
- `Repository` 実装 → モック差し替えでテスト

### §-1.8 ビルド設定

- Configurations: Debug / Beta / Release
- 各 Configuration は `Config/*.xcconfig` に紐付け
- App Groups: `group.com.tomo.workoutkit`

---

## §12. 1RM 計算式

Brzycki 式（採用）:

```
1RM = weight × (36 / (37 - reps))
```

- reps ≥ 37 は無効（返値: nil）
- reps < 1 は無効（返値: nil）
- weight ≤ 0 は無効（返値: nil）
- reps = 1 のとき 1RM = weight（厳密解）

---

## §13. Development Phases

| Phase | Scope |
|---|---|
| **A1** | Xcode プロジェクト・TabView 骨格・OneRepMaxCalculator |
| **A2** | SwiftData モデル・種目データ投入・Exercise 一覧 |
| **A3** | ワークアウト記録フロー・セット入力 |
| **A4** | HealthKit 連携・統計 |
| **A5** | Widget / StoreKit / App Store 申請 |
