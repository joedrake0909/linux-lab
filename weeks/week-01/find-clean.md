# Tuesday Build 2 — Find & Clean

## Objective
Find large files, files not modified for more than 90 days, and empty
directories. Inspect candidates before considering deletion.

## Commands practised

### Files larger than 100 MiB
`find ~ -type f -size +100M -print`

Result: no matching regular files found under `/home/bio`.

### Files not modified for more than 90 days
`find ~ -type f -mtime +90 -print`

Matches:
- `/home/bio/.bashrc`
- `/home/bio/.bash_logout`
- `/home/bio/.profile`

Decision: preserve these shell configuration files.

### Empty directories
`find ~ -type d -empty -print`

Matches:
- `/home/bio/linux-lab/configs`
- `/home/bio/linux-lab/.git/refs/tags`
- `/home/bio/linux-lab/.git/objects/pack`
- `/home/bio/linux-lab/.git/objects/info`
- `/home/bio/.local/share/nano`

Decision: preserve these directories because they are part of the lab,
Git metadata, or application data.

### Safe pathname handling
`find ~ -type f -mtime +90 -print0 | xargs -0 -r printf 'Candidate: %s\n'`

`-print0` separates pathnames with NUL characters.
`xargs -0` reads NUL-delimited pathnames, preserving spaces and other
characters that can break ordinary whitespace-separated arguments.
`-r` prevents `xargs` from running the command when there is no input.

## Safety and verification
- Used `-print` to inspect candidates before considering deletion.
- No files or directories were deleted.
- Reviewed `git status --short` before documenting the build.
- Left `.baaki.txt.swp`, `access.log`, and
  `scripts/.log-detective.sh.swp` untouched.

## What I learned
- `find` can filter by type, size, modification age, and emptiness.
- A file's age alone does not mean it is safe to delete.
- Empty directories may contain important structural or application meaning.
- `-print0` and `xargs -0` safely handle unusual filenames.
- Inspect first, decide deliberately, and only then perform destructive work.
