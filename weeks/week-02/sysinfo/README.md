
# Day 10 — System Information Reporter

## 1. Project Overview

The System Information Reporter is a Bash script that collects
and displays essential information about a Linux system.

It supports two output formats:

- Human-readable system report.
- Machine-readable JSON output.

The script also supports command-line arguments, terminal
colour handling and input validation.

## 2. Build Objective

Create a reusable Bash script that collects:

- Hostname
- Operating system
- Linux kernel version
- System uptime
- CPU architecture
- Available logical CPUs
- Memory and swap usage
- Disk usage
- Top five CPU-consuming processes

## 3. Project Structure

```text
sysinfo/
├── README.md
└── sysinfo.sh
```

## 4. Technologies and Tools

- Bash 5.3.9
- Ubuntu 26.04.1 LTS
- jq 1.8.1
- ShellCheck 0.11.0
- Linux command-line utilities

## 5. Script Architecture

The script separates information collection, presentation and command-line handling into functions.

### Information Collection Functions

| Function | Responsibility |
|---|---|
| get_hostname | Collect hostname |
| get_os | Collect operating system |
| get_kernel | Collect kernel version |
| get_uptime | Collect system uptime |
| get_cpu_architecture | Collect CPU architecture |
| get_cpu_count | Count available logical CPUs |
| get_memory | Collect RAM and swap information |
| get_disk | Collect persistent filesystem usage |
| get_top_processes | Display top five CPU-consuming processes |

### Presentation Functions

- `show_report`: Displays the human-readable report.
- `show_help`: Displays usage instructions.
- `show_json`: Generates JSON output.

### Control Function

- `main`: Handles command-line arguments and selects the appropriate output mode.

## 6. Command-Line Usage

### Human-readable report

```bash
./weeks/week-02/sysinfo/sysinfo.sh
```

### Display help

```bash
./weeks/week-02/sysinfo/sysinfo.sh --help
```

### Generate JSON

```bash
./weeks/week-02/sysinfo/sysinfo.sh --json
```

Invalid options are rejected with exit status `2`.

## 7. Bash Concepts Applied

- Functions and local variables
- Command substitution
- Positional parameters
- Argument validation
- Case statements
- Conditional expressions
- Arithmetic evaluation
- Here-documents
- Standard output and standard error
- Exit statuses
- Environment variables
- Quoting and escaping
- Script execution guards

## 8. Safety and Reliability

The script enables strict mode:

```bash
set -euo pipefail
```

This helps detect command failures, unset variables and pipeline failures.

The script also:

- Uses quoted variable expansions.
- Uses jq to encode JSON safely.
- Sends error messages to standard error.
- Rejects unknown and excessive arguments.
- Avoids terminal colour codes when output is redirected.
- Respects the `NO_COLOR` environment variable.
- Uses an execution guard to support sourcing.

## 9. Testing and Verification

| Test | Result |
|---|---|
| Human-readable report | Passed |
| JSON generation | Passed |
| JSON parsing and data types | Passed |
| `--help` | Passed |
| `--json` | Passed |
| Unknown option | Passed |
| Excessive arguments | Passed |
| Invalid argument exit status | 2 |
| Source guard | Passed |
| Direct execution | Passed |
| `NO_COLOR` | Passed |
| Redirected output | Passed |
| ANSI escape sequence check | Passed |
| Bash syntax validation | Passed |
| ShellCheck | Zero warnings |

### Static Analysis

Commands used:

```bash
bash -n weeks/week-02/sysinfo/sysinfo.sh
shellcheck -x weeks/week-02/sysinfo/sysinfo.sh
```

Both checks passed.

## 10. Environment Evidence

| Component | Observed Value |
|---|---|
| Hostname | linux-lab |
| OS | Ubuntu 26.04.1 LTS |
| Kernel | 7.0.0-42-generic |
| Architecture | x86_64 |
| Available CPUs | 2 |
| Memory | Approximately 3.3 GiB |
| Swap | Approximately 3.8 GiB |
| Root filesystem | 19 GiB |

These values represent the VM during testing and may change.

## 11. Known Limitation

The process snapshot can include the `ps` command itself.

Because the process list is collected while `ps` is executing, its CPU percentage may appear unusually high in a short-lived snapshot.

This does not necessarily indicate sustained CPU consumption.

## 12. Key Lessons Learned

1. Bash functions make scripts modular and reusable.
2. Command substitution captures command output.
3. jq can safely generate valid JSON.
4. Positional parameters support command-line interfaces.
5. Standard output and standard error serve different purposes.
6. Exit statuses communicate success and failure.
7. The shebang and executable permission allow direct execution.
8. Strict mode helps detect scripting errors.
9. ShellCheck identifies questionable Bash practices.
10. Environment variables can control script behaviour.

## 13. Completion Criteria

- [x] Collect system information.
- [x] Organise code into functions.
- [x] Display a human-readable report.
- [x] Support `--help`.
- [x] Support `--json`.
- [x] Validate command-line arguments.
- [x] Implement strict mode.
- [x] Support terminal colours and `NO_COLOR`.
- [x] Pass Bash syntax validation.
- [x] Pass ShellCheck without warnings.
- [x] Verify direct script execution.
