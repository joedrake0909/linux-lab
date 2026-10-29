# Build 1 — Users, Groups, and Least-Privilege Sudo

## Goal

Allow members of the `devs` group to restart Nginx as root without granting them unrestricted sudo access.

## Environment

- OS: Ubuntu Server 26.04.1 LTS
- Service: Nginx
- Test account: `ama`
- Group: `devs`
- Sudoers drop-in: `/etc/sudoers.d/devs`

## Initial inspection

- `ama` and `kofi` already existed.
- Both accounts were members of `devs`.
- `bio` was a member of `sudo`; `ama` was not.
- Nginx was initially absent, so it was installed as a lab dependency.
- Nginx was verified active before testing the sudo rule.

## Sudoers rule

File: `/etc/sudoers.d/devs`

```sudoers
%devs ALL=(root) /usr/bin/systemctl restart nginx.service
```
This rule grants the devs group permission to run the specified Nginx restart command as root. It does not grant general sudo access.

## Validation and permissions

Commands used:

- `sudo visudo -c`
- `sudo stat -c '%a %U:%G %n' /etc/sudoers.d/devs`
- `sudo -l -U ama`

Observed results:

- Sudoers syntax: `/etc/sudoers: parsed OK`
- File mode and ownership: `440 root:root /etc/sudoers.d/devs`
- `sudo -l -U ama` listed the permitted Nginx restart command.

## Functional tests

| Test | Observed result | Outcome |
|---|---|---|
| Confirm `ama` identity and groups with `id` | `uid=1001(ama)` and group `devs` | Passed |
| Run `sudo /usr/bin/systemctl restart nginx.service` as `ama` | Authentication prompt, then returned to prompt without an error | Passed; service state checked afterward |
| Check Nginx with `systemctl is-active nginx` as `bio` | `active` after restart | Passed |
| Run `sudo /usr/bin/systemctl stop nginx.service` as `ama` | `sudo: I'm sorry ama. I'm afraid I can't do that` | Passed: denied as intended |
| Check Nginx again as `bio` | `active` | Passed |

## Lessons learned

- Group membership can be used to assign a shared, narrowly scoped permission.
- `usermod -aG` preserves existing supplementary group memberships when adding a group.
- Use `visudo` to edit and validate sudoers configuration.
- A sudoers drop-in should be owned by `root:root` and have mode `0440`.
- Test both the permitted operation and a similar prohibited operation.
- Verify service state rather than assuming a command succeeded.

## Safety notes

- The password for `ama` was set locally for interactive testing; no password is recorded here.
- A VM snapshot was taken before the account and sudo changes.
- Nginx was left running after the tests.
