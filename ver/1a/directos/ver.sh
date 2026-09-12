#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
DATA="$ROOT/data"
BACKUP="$DATA/backup"

if [[ ! -d "$DATA" ]]; then
    echo "Sin datos aún. Agregá líneas a momentos.txt y corré ./momento.sh"
    exit 0
fi

mapfile -t files < <(find "$DATA" -type f -name '*.md' -not -path "$DATA/backup/*" | sort)

if [[ ${#files[@]} -eq 0 ]]; then
    echo "Sin momentos guardados."
    exit 0
fi

# streamer|segundos|minuto|desc|url|video_id
for f in "${files[@]}"; do
    title="$(head -n1 "$f" | sed 's/^# //')"
    streamer="${title%% — *}"
    streamer="$(echo "$streamer" | tr -d ' ')"
    url="$(grep -m1 '^\*\*URL:\*\*' "$f" | sed 's/^\*\*URL:\*\* //')"

    while IFS='|' read -r _ secs minuto desc _; do
        secs="$(echo "$secs" | xargs)"
        minuto="$(echo "$minuto" | xargs)"
        desc="$(echo "$desc" | xargs)"
        if [[ -z "$secs" || "$secs" =~ ^-+$ || "$secs" == "Segundos" ]]; then
            continue
        fi
        [[ -z "$desc" || ! "$secs" =~ ^[0-9]+$ ]] && continue
        printf '%s|%010d|%s|%s|%s\n' "$streamer" "$secs" "$minuto" "$desc" "$url"
    done < <(tail -n +8 "$f")
done | sort -t'|' -k1,1 -k2,2n | awk -F'|' '{
    printf "%s-%s  %s  ->  %s#t=%d\n", $1, $3, $4, $5, $2+0
}'
