# Wednesday Build 1 — Text Transformer

## Objective
Transform student scores from a CSV into a report showing average
scores per course, sorted from highest to lowest and aligned as a table.

## Input
- `student_scores.csv` — student, course, and score records.

## Commands practised
- `cut -d ',' -f 2` — extract the course field.
- `tail -n +2` — skip the CSV header.
- `sort | uniq -c` — group and count repeated course names.
- `awk -F ','` — accumulate scores and counts by course and calculate averages.
- `sed` — rename report headings through substitutions.
- `sort -t ',' -k2,2nr` — sort course averages numerically, highest first.
- `column -t -s ','` — align comma-separated data into a table.
- `>` — save command output to a file.

## Results
| Course | Average score |
|---|---:|
| Networking | 84.00 |
| Python | 84.00 |
| Linux | 79.00 |

## What I learned
- CSV fields can be extracted using a delimiter and field number.
- `uniq -c` counts adjacent duplicates, so sorting first matters.
- `awk` can use associative arrays to keep a total and count for each course.
- `sort -k2,2nr` sorts numerically by the second field in descending order.
- `column -t` produces a readable aligned report.
- A pipeline can be built one stage at a time and verified at each step.

## Files produced
- `course_report.csv` — course averages in CSV format.
- `final_report.txt` — sorted, aligned report.

## Limitation
These commands assume a simple comma-separated file without quoted commas
inside fields. For complex CSV data, use a CSV-aware parser.
