# URL Scheme 仕様

WakeAtStation は `wakestation://` スキームを受け付けます。
他アプリ（Yahoo! 乗換案内、メモ、Safari等）から駅名・座標を渡して
ワンタップで降車駅を事前セットできます。

## パス

すべて `goto` ホストを使います。

| クエリ | 例 | 意味 |
|---|---|---|
| `name` | `新宿` | 駅名で検索（かな可） |
| `lat` + `lng` | `35.68093` / `139.76748` | 座標で最近傍検索 |
| `name` + `lat` + `lng` | 両方指定 | name優先、失敗時に座標フォールバック |

## 例

```
wakestation://goto?name=新宿
wakestation://goto?lat=35.68093&lng=139.76748
wakestation://goto?name=東京&lat=35.68093&lng=139.76748
```

## 挙動

- アプリ起動 → `DeepLinkRouter` が駅を解決
- ホーム画面で `StationDetailSheet` が自動で開く
- ユーザーが半径を確認して「ここで起こしてもらう」→ 監視開始
