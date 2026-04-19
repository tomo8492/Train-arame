"""Convert 国土数理院 鉄道データ (N02) to stations.json consumed by the iOS app.

Usage:
    1. Download N02 (全国鉄道データ) from
       https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-N02.html
       (ZIP containing N02-XX_Station.shp / .dbf / .shx)
    2. Install deps:  pip install pyshp
    3. Run:           python build_stations.py path/to/N02-XX_Station.shp \
                             -o ../ios/WakeAtStation/Resources/stations.json

Output schema:
    [{ "id": "...", "name": "...", "nameKana": null,
       "lineName": "...", "latitude": 0.0, "longitude": 0.0 }, ...]
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def build(shp_path: Path, out_path: Path) -> None:
    try:
        import shapefile
    except ImportError:
        sys.exit("pyshp is required. Run: pip install pyshp")

    reader = shapefile.Reader(str(shp_path), encoding="cp932")
    fields = [f[0] for f in reader.fields[1:]]

    def field_index(name: str) -> int:
        try:
            return fields.index(name)
        except ValueError:
            return -1

    line_idx = field_index("N02_003")
    station_idx = field_index("N02_005")
    company_idx = field_index("N02_004")

    seen: set[tuple[str, str]] = set()
    stations: list[dict] = []

    for shape_rec in reader.shapeRecords():
        rec = shape_rec.record
        name = (rec[station_idx] if station_idx >= 0 else "").strip()
        line = (rec[line_idx] if line_idx >= 0 else "").strip()
        company = (rec[company_idx] if company_idx >= 0 else "").strip()
        if not name:
            continue

        key = (name, line)
        if key in seen:
            continue
        seen.add(key)

        pts = shape_rec.shape.points
        if not pts:
            continue
        lon_sum = sum(p[0] for p in pts) / len(pts)
        lat_sum = sum(p[1] for p in pts) / len(pts)

        stations.append({
            "id": f"{company}-{line}-{name}".replace(" ", ""),
            "name": name,
            "nameKana": None,
            "lineName": line,
            "latitude": round(lat_sum, 6),
            "longitude": round(lon_sum, 6),
        })

    stations.sort(key=lambda s: (s["lineName"], s["name"]))
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(stations, ensure_ascii=False, indent=0), encoding="utf-8")
    print(f"Wrote {len(stations)} stations to {out_path}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Build stations.json for WakeAtStation")
    parser.add_argument("shp", type=Path, help="Path to N02-XX_Station.shp")
    parser.add_argument("-o", "--out", type=Path,
                        default=Path("../ios/WakeAtStation/Resources/stations.json"))
    args = parser.parse_args()
    build(args.shp, args.out)


if __name__ == "__main__":
    main()
