"""Descarga el catálogo completo de speCies.blue (16 páginas de 100) en es y en.

Uso: python tool/download_catalog.py
Escribe tool/catalog/catalog_<lang>.json (fuera del control de versiones). Cada archivo trae
las especies tal como las devuelve /species, sin tocar nada a mano. Lo usan las pruebas de
aceptación de la búsqueda; si el archivo no existe, esas pruebas se saltan.
"""
import json
import pathlib
import subprocess
import sys

BASE = "https://skfqeznlqqprmvamwyrf.supabase.co/functions/v1/public-api/v1"
PER_PAGE = 100
OUT = pathlib.Path(__file__).parent / "catalog"


def get(url):
    raw = subprocess.run(["curl.exe", "-s", "-w", "\n%{http_code}", url], capture_output=True).stdout
    body, code = raw.decode("utf-8").rsplit("\n", 1)
    return int(code), body


def main():
    OUT.mkdir(exist_ok=True)
    for lang in ("es", "en"):
        items, page, total = [], 1, None
        while total is None or len(items) < total:
            code, body = get(f"{BASE}/species?lang={lang}&per_page={PER_PAGE}&page={page}")
            if code != 200:
                sys.exit(f"{lang} página {page}: HTTP {code}")
            data = json.loads(body)
            total = data["pagination"]["total"]
            items += data["data"]
            print(f"{lang} página {page}: {len(items)}/{total}")
            page += 1
        (OUT / f"catalog_{lang}.json").write_text(
            json.dumps({"total": total, "data": items}, ensure_ascii=False), encoding="utf-8"
        )


main()
