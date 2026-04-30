# 駅ウェイク（WakeAtStation）テスト指示書

**対象ブランチ**: `claude/wakeatstation-spec-48U49`
**リポジトリ**: `tomo8492/Train-arame`
**前提環境**: macOS Sonoma 以降 / Xcode 15.0 以降 / Apple Developer アカウント（実機検証時のみ）

このアプリは **Tomo 個人開発 / 公開予定** の駅着接近通知アプリです。
ビルド可否・主要動作の確認 → 結果をレポートください。

---

## A. セットアップ（5分）

```bash
# 1. リポジトリ取得
git clone <リポジトリURL> wakestation
cd wakestation
git checkout claude/wakeatstation-spec-48U49

# 2. XcodeGen（未導入なら）
brew install xcodegen

# 3. Xcode プロジェクト生成
make project   # WakeAtStation.xcodeproj が生成される
make open      # Xcode で開く
```

**期待**: `WakeAtStation.xcodeproj` が生成され Xcode が開く
**失敗パターンと報告**: `xcodegen` の警告/エラーを全文コピー

---

## B. ビルド検証（10分）

Xcode で:

1. **Signing & Capabilities** タブで Team を Personal Team に設定
   - 4ターゲット全部: WakeAtStation / WakeAtStationWatch / WakeAtStationComplication / WakeAtStationTests
2. Bundle Identifier 衝突する場合は接頭辞を `com.<your-team>.` に書き換え
3. スキーム `WakeAtStation` を選択し、シミュレータ `iPhone 15` で **⌘B**（ビルドのみ）

**期待**: Build Succeeded
**失敗パターンと報告**:
- 赤エラーのファイル名・行番号・メッセージを **全部** スクショまたはテキストで貼る
- 警告（黄）も10件以上あれば一覧で

よくあるトラブルと対処:
| 症状 | 対処 |
|---|---|
| `app-extension` ターゲットが認識されない | XcodeGen 2.39+ にアップデート |
| App Group エラー | この時点では無視可（実機テストで必要） |
| Privacy Manifest 警告 | 無視可 |

---

## C. ユニットテスト実行（3分）

```bash
make test
# または Xcode で ⌘U
```

**確認するテスト**:
- `AlarmTests` (4ケース)
- `AlarmStoreTests` (3ケース)
- `StationRepositoryTests` (5ケース)
- `DeepLinkRouterTests` (8ケース)
- `HapticConfigTests` (9ケース)

**期待**: **29ケース全て pass**
**失敗時の報告**: 失敗テスト名 + アサーションメッセージ

---

## D. シミュレータでの機能チェック（15分）

**iPhone 15 シミュレータ**で WakeAtStation スキームを **⌘R** 実行。

### D-1. 起動とオンボーディング
- [ ] 初回起動時、3ページのオンボーディング表示
- [ ] スワイプで次のページへ
- [ ] 最終ページで「位置情報を許可して始める」→ 権限ダイアログ
- [ ] 許可後、ホーム画面（タブ）が表示

### D-2. 駅検索
- [ ] 「駅検索」タブで **`新宿`** と入力
- [ ] 結果に「新宿」が **最上位** に出ること（メジャー駅優先ソート）
- [ ] **`しんじゅく`** で同じ駅がヒット
- [ ] **`シンジュク`** でも同じ駅がヒット（カナ正規化）
- [ ] **`山手線`** で複数駅が出ること
- [ ] **`存在しない駅XYZ`** で「該当する駅が見つかりません」表示

### D-3. 駅詳細・監視開始
- [ ] 検索結果から「東京」をタップ → 駅詳細シート開く
- [ ] 駅名・かな・路線一覧が表示される
- [ ] 通知半径ピッカーで `500m / 1km / 2km` 切替できる
- [ ] 二段階予告トグル ON/OFF できる
- [ ] 右上の星アイコンでお気に入り登録/解除
- [ ] 「ここで起こしてもらう」タップでホームに戻り、**監視中**カード表示

### D-4. 監視動作（シミュレータの位置を疑似）
Xcode の `Debug → Simulate Location → Custom Location...` で、設定した駅の座標を入力する。

- [ ] ホーム画面の現在地距離が更新される
- [ ] 半径内に入ると通知発火（バナー＋音）
- [ ] 通知に「停止」ボタンが表示される
- [ ] 「停止」タップでホーム画面の監視中カードが消える
- [ ] アラームの 30秒/60秒/90秒... フォローアップ通知が予約されている
  - シミュレータの「Settings → Notifications」で複数件確認できる

### D-5. ホーム画面のセクション
- [ ] お気に入りに登録した駅が「お気に入り」セクションに出る
- [ ] 監視を一度開始した駅が「最近使った駅」セクションに出る
- [ ] 駅をスワイプ削除でお気に入りから外せる

### D-6. 設定画面
- [ ] 通知半径のデフォルト値変更 → 駅詳細シートに反映される
- [ ] バイブの強さ（弱/標準/強）が選べる
- [ ] バイブ継続時間（30秒/1分/2分/3分）が選べる
- [ ] iPhone本体バイブ ON/OFF
- [ ] 「最近使った駅をクリア」 → 確認ダイアログ → 削除実行
- [ ] 位置情報権限の状態が表示される

### D-7. URL Scheme
ターミナルから:
```bash
xcrun simctl openurl booted "wakestation://goto?name=新宿"
```
- [ ] アプリが起動し、新宿の駅詳細シートが自動表示

```bash
xcrun simctl openurl booted "wakestation://goto?lat=35.6812&lng=139.7671"
```
- [ ] 東京駅（座標最近傍）の詳細シートが表示

---

## E. 実機検証（20分・任意）

App Group 設定が必要なため、Apple Developer Portal で:
1. `Identifiers → App Groups` で `group.com.tomo.wakeatstation` 作成
2. 各ターゲットの App Group capability にチェック

### E-1. iPhone 実機
- [ ] 上記 D-1～D-7 を実機で確認
- [ ] **電車に乗って実走**（最重要）
  - 自宅近くの駅を設定し、電車で移動 → 通知発火を確認
  - バックグラウンドで region monitoring が機能するか
  - バッテリー消費感（30分走行で何%減か）

### E-2. Apple Watch（必須）
- [ ] iPhone と Watch をペアリング、Watch アプリを Watch にインストール
- [ ] iPhone でアラームをセット → Watch アプリで駅名が表示
- [ ] **コンプリケーション**を文字盤に追加
  - Modular / Infograph 等で `WakeAtStation` を選択
  - 監視中の駅名が文字盤に表示されるか
- [ ] 通知発火時、Watch で **連続バイブ**（2分間）するか
- [ ] 「起きた！停止」ボタンで停止できるか
- [ ] 設定で「弱」に変えると、間隔が広くなることを体感確認

---

## F. レポートテンプレート

以下を埋めて返してください。

```markdown
# 駅ウェイク テストレポート

## 環境
- macOS: <バージョン>
- Xcode: <バージョン>
- 実機: iPhone <型番> / Apple Watch <型番> / なし

## A. セットアップ
- xcodegen 生成: ✅ / ❌ <エラー全文>
- 開けた: ✅ / ❌

## B. ビルド
- iPhone Simulator: ✅ / ❌
  - エラー <あれば全文>
  - 警告件数 <数>
- Watch Simulator: ✅ / ❌
- Complication: ✅ / ❌

## C. ユニットテスト
- 結果: <pass/fail 件数>
- 失敗詳細 <あれば>

## D. シミュレータ機能
- D-1 オンボーディング: ✅ / ❌
- D-2 駅検索: ✅ / ❌
- D-3 駅詳細: ✅ / ❌
- D-4 監視動作: ✅ / ❌
- D-5 ホーム: ✅ / ❌
- D-6 設定: ✅ / ❌
- D-7 URL Scheme: ✅ / ❌

## E. 実機（任意）
- iPhone: <所感>
- Apple Watch: <所感>
- 電車実走: <所感、バッテリー消費>

## 気になった挙動
- <UX的に違和感のあった箇所>

## バグ・要修正
- <優先度高: ...>
- <優先度中: ...>
- <優先度低: ...>
```

---

## 補足

- **コードは全て `claude/wakeatstation-spec-48U49` ブランチ上にあります**
- main ブランチへのマージは Tomo の判断後
- `docs/APPSTORE.md` に申請文ドラフト、`docs/PRIVACY.md` にプラポリ草案あり
- 不明点あれば Tomo に直接確認してください
