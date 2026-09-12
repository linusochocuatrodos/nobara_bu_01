#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
source "$ROOT/lib.sh"

if [[ ! -d "$DATA" ]] || [[ -z "$(ls -A "$DATA" 2>/dev/null)" ]]; then
    echo "Sin datos aún. Agregá líneas a momentos.txt y corré ./momento.sh"
    exit 0
fi

tmp=""
trap 'rm -f "${tmp:-}"' EXIT

while true; do
    set +e
    menu_streamers "=== Streamers ===" "s"
    rc=$?
    set -e
    [[ $rc -ne 0 ]] && exit 0

    filtro=""
    [[ "$SELECCION" != "__ALL__" ]] && filtro="$SELECCION"

    while true; do
        tmp="$(cargar_momentos "$filtro")"
        set +e
        menu_momentos "=== Momentos ===" "$tmp" "n"
        rc=$?
        set -e
        if [[ $rc -eq 2 ]]; then
            break
        elif [[ $rc -eq 3 || $rc -ne 0 ]]; then
            exit 0
        fi

        IFS='|' read -r _ streamer secs minuto desc url <<<"$SELECCION_LINEA"
        target="${url}#t=${secs}"
        abrir_en_navegador "$target" || true
    done
done
