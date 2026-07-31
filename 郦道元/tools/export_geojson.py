from pathlib import Path

import geopandas as gpd


ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "Data"
TARGET = DATA / "geojson"


def find_dir_with(file_name: str) -> Path:
    matches = [path.parent for path in DATA.rglob(file_name)]
    if not matches:
        raise FileNotFoundError(file_name)
    return matches[0]


LAYERS = {
    "china": find_dir_with("ChinaBoundpoly.shp"),
    "mountains": find_dir_with("Taihangshan.shp"),
    "rivers": find_dir_with("Huanghe.shp"),
    "places": find_dir_with("Luoyang.shp"),
}


def export_one(shp_path: Path, target_dir: Path) -> None:
    gdf = gpd.read_file(shp_path)
    if gdf.empty:
        return

    if gdf.crs is not None:
        gdf = gdf.to_crs(epsg=4326)
    else:
        gdf = gdf.set_crs(epsg=4326)

    target_dir.mkdir(parents=True, exist_ok=True)
    out_path = target_dir / f"{shp_path.stem}.geojson"
    gdf.to_file(out_path, driver="GeoJSON", encoding="utf-8")
    print(f"exported {out_path.relative_to(ROOT)}")


def main() -> None:
    for layer_name, source_dir in LAYERS.items():
        target_dir = TARGET / layer_name
        for shp_path in sorted(source_dir.glob("*.shp")):
            export_one(shp_path, target_dir)


if __name__ == "__main__":
    main()
