"""Convert 国土数値情報 鉄道データ (N02) to stations.json consumed by the iOS app.

Same-name stations within ~1km are merged (multi-line transfer stations
become a single record with a "lines" array).

Usage:
    1. Download N02 (全国鉄道データ) from
       https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-N02.html
    2. Install deps:  pip install pyshp pykakasi
    3. Run:           python build_stations.py path/to/N02-XX_Station.shp \
                             -o ../ios/WakeAtStation/Resources/stations.json

Output schema:
    [{ "id": "...",
       "name": "...",
       "nameKana": "...",
       "lines": ["...", "..."],
       "latitude": 0.0,
       "longitude": 0.0 }, ...]
"""

from __future__ import annotations

import argparse
import json
import sys
from collections import OrderedDict
from pathlib import Path


def _build_kana_converter():
    try:
        import pykakasi
    except ImportError:
        return None
    k = pykakasi.kakasi()

    def to_hira(text: str) -> str:
        return "".join(item["hira"] for item in k.convert(text))

    return to_hira


def _merge_by_station(raw: list[dict], threshold_m: float = 800) -> list[dict]:
    """Cluster same-name stations whose centroids are within `threshold_m` meters.

    Uses union-find within each name group so a chain like A-B-C all under
    threshold get merged into one. Distinct same-name stations far apart
    (e.g. 大手町 vs 大手町 別駅) stay separate.
    """
    import math
    from collections import defaultdict

    def haversine_m(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
        R = 6371000.0
        phi1, phi2 = math.radians(lat1), math.radians(lat2)
        dphi = math.radians(lat2 - lat1)
        dlmd = math.radians(lng2 - lng1)
        a = math.sin(dphi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlmd / 2) ** 2
        return 2 * R * math.asin(math.sqrt(a))

    by_name: dict[str, list[dict]] = defaultdict(list)
    for s in raw:
        by_name[s["name"]].append(s)

    merged: list[dict] = []
    for name, members in by_name.items():
        n = len(members)
        parent = list(range(n))

        def find(x: int) -> int:
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x

        def union(a: int, b: int) -> None:
            ra, rb = find(a), find(b)
            if ra != rb:
                parent[ra] = rb

        for i in range(n):
            for j in range(i + 1, n):
                if haversine_m(members[i]["latitude"], members[i]["longitude"],
                               members[j]["latitude"], members[j]["longitude"]) <= threshold_m:
                    union(i, j)

        clusters: dict[int, list[dict]] = defaultdict(list)
        for i in range(n):
            clusters[find(i)].append(members[i])

        for cluster in clusters.values():
            lines: list[str] = []
            for m in cluster:
                if m["lineName"] not in lines:
                    lines.append(m["lineName"])
            avg_lat = sum(m["latitude"] for m in cluster) / len(cluster)
            avg_lng = sum(m["longitude"] for m in cluster) / len(cluster)
            ident = f"{name}-{round(avg_lat, 4)}-{round(avg_lng, 4)}"
            merged.append({
                "id": ident,
                "name": name,
                "nameKana": cluster[0].get("nameKana"),
                "lines": lines,
                "latitude": round(avg_lat, 6),
                "longitude": round(avg_lng, 6),
            })
    return merged


def build(shp_path: Path, out_path: Path, encoding: str | None = None) -> None:
    try:
        import shapefile
    except ImportError:
        sys.exit("pyshp is required. Run: pip install pyshp")

    if encoding is None:
        encoding = "utf-8" if "UTF-8" in str(shp_path) else "cp932"

    to_hira = _build_kana_converter()
    if to_hira is None:
        print("warning: pykakasi not installed; nameKana will be null. "
              "Run: pip install pykakasi")

    reader = shapefile.Reader(str(shp_path), encoding=encoding)
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
    raw: list[dict] = []

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

        display_line = f"{company} {line}".strip() if company else line
        name_kana = to_hira(name) if to_hira else None

        raw.append({
            "name": name,
            "nameKana": name_kana,
            "lineName": display_line,
            "latitude": round(lat_sum, 6),
            "longitude": round(lon_sum, 6),
        })

    stations = _merge_by_station(raw)
    stations.sort(key=lambda s: s["name"])
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(stations, ensure_ascii=False, indent=0), encoding="utf-8")
    print(f"Wrote {len(stations)} stations (from {len(raw)} raw records) to {out_path}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Build stations.json for WakeAtStation")
    parser.add_argument("shp", type=Path, help="Path to N02-XX_Station.shp")
    parser.add_argument("-o", "--out", type=Path,
                        default=Path("../ios/WakeAtStation/Resources/stations.json"))
    args = parser.parse_args()
    build(args.shp, args.out)


if __name__ == "__main__":
    main()
