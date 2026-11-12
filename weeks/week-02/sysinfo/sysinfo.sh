#!/usr/bin/env bash

set -euo pipefail

# Terminal colours
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    RED=$'\033[0;31m'
    GREEN=$'\033[0;32m'
    CYAN=$'\033[0;36m'
    RESET=$'\033[0m'
else
    RED=''
    GREEN=''
    CYAN=''
    RESET=''
fi

# Collect the system hostname
get_hostname() {
   hostname
}

# Collect the operating system name
get_os() {
    . /etc/os-release
    printf '%s\n' "$PRETTY_NAME"
}

# Collect the linux kernel version
get_kernel() {
    uname -r
}

# Collect system uptime
get_uptime() {
    uptime -p
}


# Collect CPU architecture
get_cpu_architecture() {
    lscpu | awk -F: '/^Architecture:/ {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
        print $2
    }'
}

# Collect the number of logical CPUs
get_cpu_count() {
    nproc
}


# Collect memory information
get_memory() {
    free -h
}

# Collect disk usage for persistent filesystems
get_disk() {
    df -h -x tmpfs -x devtmpfs
}

# Collect the five processes using the most CPU
get_top_processes() {
    local script_pid=$$
    ps -eo user,pid,pcpu,pmem,stat,comm --sort=-%cpu |
        awk -v pid="$script_pid" 'NR == 1 || $2 != pid' |
        sed -n '1,6p'
}


# Display the human-readable system report
show_report() {
    printf '\n%bSYSTEM INFORMATION%b\n' "$CYAN" "$RESET"
    printf '%bHostname:%b %s\n' "$GREEN" "$RESET" "$(get_hostname)"
    printf '%bOperating System:%b %s\n' "$GREEN" "$RESET" "$(get_os)"
    printf '%bKernel:%b %s\n' "$GREEN" "$RESET" "$(get_kernel)"
    printf '%bUptime:%b %s\n' "$GREEN" "$RESET" "$(get_uptime)"

    printf '\n%bCPU INFORMATION%b\n' "$CYAN" "$RESET"
    printf '%bArchitecture:%b %s\n' "$GREEN" "$RESET" "$(get_cpu_architecture)"
    printf '%bAvailable CPUs:%b %s\n' "$GREEN" "$RESET" "$(get_cpu_count)"

    printf '\n%bMEMORY INFORMATION%b\n' "$CYAN" "$RESET"
    get_memory

    printf '\n%bDISK INFORMATION%b\n' "$CYAN" "$RESET"
    get_disk

    printf '\n%bTOP PROCESSES%b\n' "$CYAN" "$RESET"
    get_top_processes
}


# Display script usage instructions
show_help() {
    cat <<'EOF'
Usage: sysinfo.sh [OPTION]

Display system information.

Options:
  --help    Display this help message.
  --json    Display system information in JSON format.

With no option, display a human-readable system report.
EOF
}


# Generate machine-readable JSON output
show_json() {
    jq -n \
        --arg hostname "$(get_hostname)" \
        --arg os "$(get_os)" \
        --arg kernel "$(get_kernel)" \
        --arg uptime "$(get_uptime)" \
        --arg architecture "$(get_cpu_architecture)" \
        --argjson available_cpus "$(get_cpu_count)" \
        --arg memory "$(get_memory)" \
        --arg disk "$(get_disk)" \
        --arg top_processes "$(get_top_processes)" \
        '{
            hostname: $hostname,
            os: $os,
            kernel: $kernel,
            uptime: $uptime,
            cpu: {
                architecture: $architecture,
                available_cpus: $available_cpus
            },
            memory: $memory,
            disk: $disk,
            top_processes: $top_processes
        }'
}


# Handle command-line arguments
main() {
    if (( $# > 1 )); then
        printf '%bError:%b Too many arguments.\n' "$RED" "$RESET" >&2
        show_help >&2
        return 2
    fi

    case "${1:-}" in
        "")
            show_report
            ;;
        --help)
            show_help
            ;;
        --json)
            show_json
            ;;
        *)
            printf '%bError:%b Unknown option: %s\n' "$RED" "$RESET" "$1" >&2
            show_help >&2
            return 2
            ;;
    esac
}

# Run main only when the script is executed directly, not when sourced.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
