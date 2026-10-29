# Build 2 — Archive, Backup, and Integrity Verification

## Goal

Archive the Linux lab repository, record and verify its SHA-256 checksum, synchronize a second copy, and demonstrate corruption detection safely.

## Environment

- OS: Ubuntu Server 26.04.1 LTS
- Source: `~/linux-lab`
- Backup directory: `~/linux-backups`
- Copy destination: `~/linux-backups-copy`
- Archive: `linux-lab.tar.zst`
- Checksum record: `linux-lab.tar.zst.sha256`

## Archive creation

Command:

```bash
tar --zstd -cf "$HOME/linux-backups/linux-lab.tar.zst" -C "$HOME" linux-lab
```

The archive was created outside the source directory. Its contents were listed successfully with `tar --zstd -tf`.

## Checksum verification

Commands:

```bash
cd "$HOME/linux-backups"
sha256sum linux-lab.tar.zst > linux-lab.tar.zst.sha256
sha256sum -c linux-lab.tar.zst.sha256
```

Observed result: `linux-lab.tar.zst: OK`

Recorded SHA-256:

`4e76d164800080f935865e6c9bbb099f7fceeed77b3bffa9a5019c221785b975`

## Synchronization

The backup directory was synchronized to `~/linux-backups-copy` using `rsync -av`.

The copied archive passed checksum verification, and `cmp` confirmed that the original and copied archive files were identical.

## Corruption experiment

A disposable copy named `linux-lab-corrupt-test.tar.zst` was created in the destination. One byte was changed in that disposable copy using Python.

When compared with the original recorded SHA-256, the corrupted copy reported `FAILED`. The original archive continued to pass verification.

## Safe rsync deletion test

A dry run with `rsync -avn --delete` showed that the disposable corrupted test file would be deleted. The dry run did not perform the deletion.

After reviewing the proposed action, `rsync -av --delete` was run to synchronize the destination with the source. The disposable corrupted test file was removed from the destination.

Final checks:

- Copied archive checksum: `OK`
- `cmp`: `Archive copies are identical`

## Lessons learned

- `tar` packages files and directories; Zstandard compresses the archive.
- A SHA-256 checksum detects changes relative to a trusted recorded hash.
- A successful checksum does not, by itself, prove that an archive can be restored.
- `rsync --delete` can remove destination-only files.
- A dry run should be reviewed before a potentially destructive synchronization.
- Corruption experiments should use disposable copies, not the known-good original.

## Safety notes

- The original archive and checksum were kept separate from the corrupted test copy.
- The corrupted test file was removed during final synchronization.
- No unrelated repository files were intentionally modified or deleted during this build.

