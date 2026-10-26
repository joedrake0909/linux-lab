# Linux System Map

## Environment

- Hostname: linux-lab
- Operating system: Ubuntu Server 26.04 LTS
- User: bio
- Home directory: /home/bio

## Filesystem hierarchy

| Path | Purpose |
|---|---|
| `/` | Root of the filesystem tree. |
| `/etc` | System-wide configuration files. |
| `/var` | Variable system and application data, including logs and caches. |
| `/usr` | Installed programs, libraries, and shared resources. |
| `/home` | Home directories for regular users. |
| `/proc` | Virtual filesystem exposing process and kernel information. |
| `/dev` | Device files and interfaces. |
| `/sys` | Virtual filesystem exposing kernel and device information. |
| `/boot` | Files needed to boot Linux. |
| `/tmp` | Temporary files. |
| `/root` | Home directory of the root administrator. |
| `/run` | Runtime state for the current boot. |
| `/srv` | Data served by system services. |
| `/mnt` | Conventional mount point for temporary mounts. |
| `/media` | Conventional mount point for removable media. |
| `/opt` | Optional third-party software. |
| `/snap` | Snap package data and mount points. |

## Directory usage under /var

Measured with `sudo du -sh /var/* | sort -h`:

| Path | Reported size |
|---|---:|
| `/var/lock` | 0 |
| `/var/run` | 0 |
| `/var/crash` | 4.0K |
| `/var/local` | 4.0K |
| `/var/mail` | 4.0K |
| `/var/opt` | 4.0K |
| `/var/spool` | 16K |
| `/var/snap` | 44K |
| `/var/tmp` | 52K |
| `/var/backups` | 996K |
| `/var/log` | 21M |
| `/var/cache` | 160M |
| `/var/lib` | 315M |

The largest reported entries were `/var/lib`, `/var/cache`, and `/var/log`.

## Filesystem capacity

From `df -h`:

| Mount point | Filesystem size | Used | Available | Use |
|---|---:|---:|---:|---:|
| `/` | 19G | 6.8G | 11G | 39% |
| `/boot` | 2.0G | 96M | 1.7G | 6% |
| `/run` | 671M | 1.6M | 669M | 1% |
| `/dev/shm` | 1.7G | 0 | 1.7G | 0% |
| `/tmp` | 1.7G | 0 | 1.7G | 0% |

The `tmpfs` filesystems shown by `df -h` are memory-backed temporary filesystems. They should not be interpreted as ordinary persistent disk partitions.

## Commands practised

- `cd` — change the current directory.
- `pwd` — print the current working directory.
- `ls -la` — list directory entries, including hidden entries, with details.
- `tree -L 1 /` — display the root directory and one level below it.
- `du -sh /var/* | sort -h` — summarize directory usage and sort by human-readable size.
- `sudo du -sh /var/* | sort -h` — repeat the inspection with elevated permissions.
- `df -h` — report capacity and usage for mounted filesystems.
- `find . -maxdepth 3 -type d -print` — inspect the repository's directory structure.

## What I learned

`du` measures disk usage for files and directories, while `df` reports capacity and available space on mounted filesystems. Permission errors from `du` can occur when my user cannot read protected directories. I used `sudo` for the system-wide `/var` inspection and compared the results. The root filesystem was 39% used when I ran `df -h`.

## Follow-up

Consult `man hier` to review the standard filesystem hierarchy and verify any directory purpose that is unclear.
