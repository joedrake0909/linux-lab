# Day 11 — File Organisation Automation

## 1. Project Overview

**Project:** `organise.sh`
**Week:** 2 — Processes, Job Control and Your First Script
**Build:** Day 11
**Language:** Bash
**Environment:** Ubuntu 26.04.1 LTS

### Objective

Build a Bash utility that organises files in a specified directory by classifying them according to their extensions, creating category directories, and adding a date prefix to filenames.

The utility supports a dry-run mode so users can preview proposed changes before moving files.

### Input → Process → Output

- **Input:** A directory containing files and an optional `--dry-run` argument.
- **Process:** Discover files, identify extensions, classify files, construct destination paths, and move eligible files safely.
- **Output:** Organised category directories containing date-prefixed filenames.

## 2. Supported File Categories

| Category | Extensions |
|---|---|
| PDF | `.pdf` |
| Images | `.jpg`, `.jpeg`, `.png`, `.gif` |
| Archives | `.zip`, `.tar`, `.gz`, `.bz2`, `.xz` |
| Documents | `.txt`, `.md`, `.csv` |
| Other | Unrecognised extensions and extensionless files |

Extensions are converted to lowercase before classification.

## 3. Project Structure

```text
organise/
├── organise.sh
├── README.md
└── test-data/
    ├── Archives/
    ├── Documents/
    ├── Images/
    ├── Other/
    └── PDF/
```

The `test-data` directory was used as a controlled environment for testing.

## 4. Usage

```bash
cd weeks/week-02/organise
```

Make the script executable:

```bash
chmod +x organise.sh
```

Preview changes:

```bash
./organise.sh --dry-run ~/Downloads
```

Run the organisation:

```bash
./organise.sh ~/Downloads
```

Display help:

```bash
./organise.sh --help
```

The script also accepts the dry-run option after the directory argument.

## 5. Implementation Details

### Strict mode

```bash
set -euo pipefail
```

Enables stricter error handling, undefined-variable detection and pipeline failure detection.

### Argument parsing

The `parse_arguments()` function handles:

- `--dry-run`
- `--help` and `-h`
- Unknown options
- Missing directory arguments
- Multiple directory arguments
- Nonexistent directories

### File discovery

The `discover_files()` function uses Bash arrays and `nullglob` to collect entries from the target directory.

Hidden files are excluded by the current `*` glob pattern.

### Classification

The `classify_file()` function extracts the extension, normalises its case and uses a `case` statement to select a category.

### Destination construction

The `build_destination()` function constructs destination paths using the category, date prefix and original filename.

Date format:

```text
YYYYMMDD
```

### Safe file handling

The implementation uses:

- Quoted variable expansions to handle filenames containing spaces.
- `mkdir -p` to create category directories.
- `mv -n` to prevent overwriting existing destinations.
- Destination existence checks to skip collisions.
- Source and destination checks to verify move outcomes.
- `--dry-run` to preview changes without moving files.

Only regular files are processed. Directories encountered during discovery are skipped.

## 6. Test Evidence

The following tests were performed in controlled temporary directories.

| Test | Observed result |
|---|---|
| PDF classification | Passed |
| Image classification | Passed |
| Archive classification | Passed |
| Document classification | Passed |
| Uppercase extension | Passed |
| Filename containing spaces | Passed |
| Extensionless file | Passed |
| Hidden `.env` file | Excluded as expected |
| Empty directory | Reported no files found |
| Dry-run | Previewed operations without moving files |
| Real organisation | Files moved into category directories |
| Existing destination | Existing destination preserved |
| Successful move reporting | Source disappeared and destination existed |
| Option after directory | Accepted |
| Unknown option | Rejected |
| Missing directory argument | Rejected |
| Nonexistent directory | Rejected |
| Multiple directory arguments | Rejected |

### Collision test

An existing destination was created for the same date-prefixed filename.

Observed behaviour:

```text
Skipping: destination already exists: ...
```

Both the original source and existing destination were verified to remain present.

### Successful move test

A fresh file named `final-report.pdf` was organised.

Observed output:

```text
Moved: /tmp/organise-success/final-report.pdf -> /tmp/organise-success/PDF/20261119_final-report.pdf
```

A subsequent filesystem inspection confirmed that only the destination file remained.

## 7. Code Quality Validation

Commands used:

```bash
bash -n weeks/week-02/organise/organise.sh
```

```bash
shellcheck -x weeks/week-02/organise/organise.sh
```

Both checks completed without output or reported issues.

## 8. Limitations and Safety Considerations

1. Hidden files are excluded by the current glob pattern.
2. The utility processes only files directly inside the supplied directory; it does not recursively organise nested directories.
3. Unrecognised extensions are classified as `Other`.
4. Existing destination files are skipped rather than overwritten.
5. Dry-run is a preview, not a backup.
6. Always preview changes before running the utility against an important directory.
7. Test with a controlled directory before using real personal files.

## 9. Skills Practised

- Bash functions
- Positional parameters
- Argument parsing
- Arrays
- `for` loops
- `case` statements
- Filename expansion
- Parameter expansion
- Command substitution
- File and directory tests
- `mkdir` and `mv`
- Quoting and filename safety
- Dry-run design
- Strict shell scripting
- ShellCheck
- Bash syntax validation

## 10. Completion Summary

The Day 11 build demonstrates how Bash can automate repetitive file-management tasks.

The script was tested with multiple file types, filenames containing spaces, hidden files, empty directories, existing destinations and successful moves.

Static analysis and Bash syntax validation both completed successfully.

**Build status:** Implementation and testing completed. Git commit and push pending.
