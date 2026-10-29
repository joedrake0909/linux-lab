# Wednesday Build 2 — Vim Survival

## Objective
Practise editing text files from the Linux terminal using Vim,
including safe changes to copies of configuration files.

## Skills practised
- Open files with `vim filename`.
- Switch between Normal and Insert modes.
- Navigate with `h`, `j`, `k`, `l`, `0`, `$`, `gg`, and `G`.
- Insert lines with `o`.
- Search with `/pattern`, repeat with `n` and `N`.
- Replace text with `:%s/old/new/`.
- Select characters with `v` and whole lines with `V`.
- Delete a character with `x` and a line with `dd`.
- Undo with `u` and redo with `Ctrl+r`.
- Save with `:w`, save and quit with `:wq`, quit with `:q`,
  and discard unsaved changes with `:q!`.

## Practice files
- `practice.txt` — main Vim exercise file.
- `hosts.practice` — safe copy of `/etc/hosts`, edited with a comment.
- `bashrc.practice` — safe copy of `~/.bashrc`, edited with a comment.

## Safety habits
- Practise on copies of configuration files instead of editing originals.
- Inspect a file before changing it.
- Use `u` to undo unwanted edits.
- Use `:q!` only when you intentionally want to discard unsaved changes.
- Verify saved content with shell commands such as `cat`, `grep`, and `tail`.

## Verification
- Confirmed edits with `tail` and `grep`.
- Verified that `:q!` discarded the unsaved test line.
- Completed 10 Vim Survival Challenge tasks.

## Reflection
Vim uses different modes for navigation, editing, and commands.
Learning these modes makes terminal-based file editing more efficient.
