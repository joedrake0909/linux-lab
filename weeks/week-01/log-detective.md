# Tuesday Build 1 — Log Detective

## Objective
Analyse a web access log using Bash pipelines and AWK.

## Results from access.log
- Top IP: `41.66.200.7` — 4 entries
- Top URL: `/menu` — 3 requests
- 404 errors: 2 during `12/Oct/2026:10`
- Total requests: 8
- 5xx responses: 1
- 5xx error rate: 12.50%

## Commands practised
- `awk '{print $1}' access.log`
- `sort | uniq -c`
- `sort -rn | head`
- `awk -F '"' '{print $2}' access.log`
- `awk '$9 == 404 {print substr($4, 2, 14)}' access.log`
- `grep -cE` for counting request lines
- AWK counters and `END` for calculating the 5xx rate

## Script
Created `scripts/log-detective.sh`.

The script:
- Accepts a log-file path as an argument.
- Checks for a missing argument.
- Checks that the input is a readable regular file.
- Reports IPs, URLs, 404 errors per hour, and the 5xx error rate.

## Verification
- Ran the script successfully against `access.log`.
- Confirmed the expected metrics.
- Ran the script without an argument and confirmed it printed usage information and exited with status `1`.
- Ran `bash -n` to check script syntax.

## Data-quality observation
The sample contains eight request entries, but the first two have their status details split onto continuation lines. This is a formatting inconsistency. The current analysis works for the supplied sample, but a more general parser should validate complete request records and status-code placement.

## What I learned
- A pipeline connects commands so each stage can transform the previous stage's output.
- `sort` groups identical values so `uniq -c` can count them.
- `sort -rn` ranks counts numerically in descending order.
- AWK can extract fields, filter status codes, count requests, and calculate percentages.
- Script arguments make commands reusable.
- Input validation and exit statuses make scripts easier to use and troubleshoot.
