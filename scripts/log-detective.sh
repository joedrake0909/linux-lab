#!/usr/bin/env bash

set -u

LOG_FILE="${1:-}"

if [[ -z "$LOG_FILE" ]]; then
    echo "Usage: $0 <access-log-file>" >&2
    exit 1
fi

if [[ ! -f "$LOG_FILE" || ! -r "$LOG_FILE" ]]; then
    echo "Error: '$LOG_FILE' is not a readable regular file." >&2
    exit 1
fi

echo "=== Top 10 IP addresses ==="
awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -rn | head

echo
echo "=== Top requested URLs ==="
awk -F '"' '{print $2}' "$LOG_FILE" |
    awk '{print $2}' |
    sort | uniq -c | sort -rn | head

echo
echo "=== 404 errors per hour ==="
awk '$9 == 404 {print substr($4, 2, 14)}' "$LOG_FILE" |
    sort | uniq -c

echo
echo "=== 5xx error rate ==="
awk '
/"(GET|POST|PUT|DELETE|PATCH|HEAD|OPTIONS) / {
    requests++
    if ($9 >= 500 && $9 < 600) errors++
}
END {
    if (requests > 0) {
        printf "Requests: %d\n", requests
        printf "5xx errors: %d\n", errors
        printf "5xx error rate: %.2f%%\n", errors / requests * 100
    } else {
        print "No request lines found."
    }
}' "$LOG_FILE"
