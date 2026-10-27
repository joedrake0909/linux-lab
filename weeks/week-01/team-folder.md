# Monday Build 2 — Shared Team Folder

## Objective
Create two users and a shared development directory with group inheritance,
group-write access, and the sticky bit.

## Users and group
- Users: `ama` and `kofi`
- Shared group: `devs`
- Both users are members of `devs`.

## Directory configuration
- Directory: `/srv/project`
- Owner and group: `root:devs`
- Mode: `3770` (`drwxrws--T`)

### Permission breakdown
- `3`: setgid (`2`) plus sticky bit (`1`)
- Owner permissions: `rwx`
- Group permissions: `rwx`
- Other permissions: none

The setgid bit makes new directory entries inherit the directory's group.
The sticky bit restricts users from deleting or renaming entries owned by
other users, unless an applicable ownership or privilege exception applies.

## Verification
- Confirmed both users belong to `devs`.
- Created files as both `ama` and `kofi`.
- Confirmed new files inherited group `devs`.
- Confirmed files created with umask `0002` had mode `664`.
- Confirmed `kofi` could create and write to `kofi-write-test.txt`.
- Confirmed the sticky-bit test prevented `kofi` from deleting `ama-file.txt`.
- Confirmed the directory mode remained `3770`.

## Follow-up observation
Appending to `/srv/project/ama-shared.txt` as `kofi` failed with
`Permission denied`, although the file was owned by `ama:devs`, had mode
`664`, and `kofi` belonged to `devs`. The ACL output showed no additional
ACL entries or restrictive ACL mask. This issue remains unresolved and
should be investigated separately; permissions were not loosened to hide it.

## What I learned
- Linux users and groups control shared access.
- Directory permissions determine who can create and access directory entries.
- Setgid supports group inheritance in shared directories.
- The sticky bit restricts deletion of other users' entries.
- Umask influences the permissions assigned to newly created files.
- Permission troubleshooting requires evidence rather than assumptions.
