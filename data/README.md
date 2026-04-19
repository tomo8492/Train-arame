# 駅データビルド

国土数理院 N02 (鉄道データ) を `stations.json` に変換するスクリプト群。

## 手順

```bash
pip install pyshp
python build_stations.py /path/to/N02-23_Station.shp \
    -o ../ios/WakeAtStation/Resources/stations.json
```

## ライセンス

国土数理院の鉄道データは出典明記で商用利用可。
アプリ内「このアプリについて」画面に出典を記載すること。
