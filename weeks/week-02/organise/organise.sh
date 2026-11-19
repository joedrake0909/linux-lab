#!/usr/bin/env bash

set -euo pipefail

usage () {
    printf 'Usage: %s [--dry-run] DIRECTORY\n' "${0##*/}"
}

parse_arguments() {
    dry_run=false
    target_dir=""

    while (($#)); do
        case "$1" in
            --dry-run)
                dry_run=true
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            -*)
                printf 'Error: Unknown option: %s\n' "$1" >&2
                usage >&2
                exit 2
                ;;
            *)
                if [[ -n "$target_dir" ]]; then
                    printf 'Error: Only one directory may be supplied.\n' >&2
                    usage >&2
                    exit 2
                fi
                target_dir="$1"
                ;;
        esac
        shift
    done

    if [[ -z "$target_dir" ]]; then
        printf 'Error: A directory is required.\n' >&2
        usage >&2
        exit 2
    fi

    if [[ ! -d "$target_dir" ]]; then
        printf 'Error: Directory does not exist: %s\n' "$target_dir" >&2
        exit 2
    fi

}


classify_file() {
    local filename="$1"
    local extension=""

    if [[ "$filename" == *.* && "$filename" != .* ]]; then
        extension="${filename##*.}"
    elif [[ "$filename" == .*.* ]]; then
        extension="${filename##*.}"
    fi

    extension="${extension,,}"

    case "$extension" in
        pdf)
            printf 'PDF\n'
            ;;
        jpg|jpeg|png|gif)
            printf 'Images\n'
            ;;
        zip|tar|gz|bz2|xz)
            printf 'Archives\n'
            ;;
        txt|md|csv)
            printf 'Documents\n'
            ;;
        *)
            printf 'Other\n'
            ;;
    esac
}


build_destination() {
    local filename="$1"
    local category="$2"
    local date_prefix="$3"

    printf '%s/%s/%s_%s\n' "$target_dir" "$category" "$date_prefix" "$filename"
}


discover_files() {
    shopt -s nullglob
    files=("$target_dir"/*)
    shopt -u nullglob
}


process_file() {
    local source_file="$1"
    local filename="${source_file##*/}"
    local category
    local date_prefix
    local destination

    if [[ ! -f "$source_file" ]]; then
        printf 'Skipping non-regular file: %s\n' "$source_file"
        return 0
    fi

    category="$(classify_file "$filename")"
    date_prefix="$(date +%Y%m%d)"
    destination="$(build_destination "$filename" "$category" "$date_prefix")"

    if [[ -e "$destination" ]]; then
        printf 'Skipping: destination already exists: %s\n' "$destination"
        return 0
    fi

    if [[ "$dry_run" == true ]]; then
        printf '[DRY-RUN] %s -> %s\n' "$source_file" "$destination"
    else
        mkdir -p "${destination%/*}"
        mv -n -- "$source_file" "$destination"

        if [[ -e "$source_file" ]]; then
            printf 'Skipping: move was not completed: %s\n' "$source_file"
        elif [[ -e "$destination" ]]; then
            printf 'Moved: %s -> %s\n' "$source_file" "$destination"
        else
            printf 'Error: Move result could not be verified: %s\n' "$source_file" >&2
            return 1
        fi
    fi
}

organise_directory() {
    discover_files

    if ((${#files[@]} == 0)); then
        printf 'No files found in: %s\n' "$target_dir"
        return 0
    fi

    for source_file in "${files[@]}"; do
        process_file "$source_file"
    done
}


main() {
    parse_arguments "$@"
    organise_directory
}


if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
