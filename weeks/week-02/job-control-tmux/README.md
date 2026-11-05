# Week 2 — Job Control & tmux

**Date:** 5 November 2026
**Environment:** Ubuntu 26.04.1 LTS running in VMware
**Hostname:** linux-lab
**SSH client:** Windows PowerShell
**tmux version:** 3.6

## Objective

Understand Bash job control, manage background processes, distinguish
`nohup` from `disown`, and use tmux to maintain a persistent terminal
session across an actual SSH disconnection.

The investigation followed this workflow:

1. Establish an SSH connection from Windows into the Ubuntu VM.
2. Suspend, inspect, resume, and terminate a foreground process.
3. Launch and inspect a process using `nohup`.
4. Create a named tmux session.
5. Run a bounded heartbeat workload inside tmux.
6. Detach, disconnect SSH, reconnect, and recover the original session.
7. Practise tmux windows and panes.
8. Remove a background job from Bash's job table using `disown`.

## Environment observations

| Item | Observation |
|---|---|
| Operating system | Ubuntu 26.04.1 LTS |
| Hostname | linux-lab |
| Architecture | x86_64 |
| VM IP address | 192.168.146.134 |
| SSH server | Active and running |
| SSH client | `/usr/bin/ssh` |
| tmux executable | `/usr/bin/tmux` |
| tmux version | 3.6 |

A real SSH connection was established from Windows PowerShell:

```powershell
ssh bio@192.168.146.134
```

The connection authenticated successfully and opened a shell as user `bio`.

## Experiment 1 — Bash job control

### Start a foreground process

```
sleep 300
```

The process occupied the foreground terminal.

Pressing `Ctrl+Z` suspended it.

Observed:

```
[1]+  Stopped                    sleep 300
```

### Inspect the job

```
jobs -l
```

Observed:

```
[1]+  2452 Stopped                    sleep 300
```

The job number was `1`, and its Linux PID was `2452`.

### Resume in the background

```
bg %1
```

Observed:

```
[1]+ sleep 300 &
```

Verification with `jobs -l` showed:

```
[1]+  2452 Running                    sleep 300 &
```

The same process resumed; its PID remained `2452`.

### Return to the foreground and terminate

```
fg %1
```

The process returned to the foreground. Pressing `Ctrl+C` interrupted it.

A subsequent `jobs -l` returned no output.

Observation: `Ctrl+Z` suspended the process, `bg` resumed it in the background, `fg` brought it back to the foreground, and `Ctrl+C` terminated it.

## Experiment 2 — nohup

### Launch a protected background process

```
nohup sleep 120 > /tmp/nohup-test.log 2>&1 < /dev/null &
```

Observed:

```
[1] 2569
```

The process was assigned PID `2569`.

The command used:

- `nohup` to make the command ignore `SIGHUP`.
- `>` to redirect standard output.
- `2>&1` to redirect standard error to the same destination.
- `< /dev/null` to provide empty standard input.
- `&` to run asynchronously in the background.

### Inspect the process

```
ps -p 2569 -o pid,ppid,stat,etime,cmd
```

Observed:

```
PID    PPID STAT     ELAPSED CMD
2569   2268 S          00:37 sleep 120
```

The process was alive and in the interruptible sleep state.

The parent process was Bash, PID `2268`.

### Inspect the output file

```
ls -l /tmp/nohup-test.log
```

The file existed and had a size of zero bytes. This was expected because `sleep` produces no normal output.

Bash subsequently reported the job as `Done`, and a later `ps` check confirmed that PID `2569` no longer existed.

Observation: `nohup` protects against hangup signals. It does not itself background a command; `&` performs that function.

This experiment verified launch, process inspection, output redirection, and natural completion. Survival across an SSH disconnection was not separately tested with `nohup`.

## Experiment 3 — tmux persistent session

### Create the session

```
tmux new -s linux-lab
```

The named session `linux-lab` was created successfully.

The environment used tmux 3.6.

### Run a bounded heartbeat workload

Inside the tmux session:

```
for i in {1..60}; do date '+%F %T'; sleep 5; done >> "$HOME/tmux-heartbeat.log" 2>&1
```

This loop ran 60 iterations, recording a timestamp every five seconds.

Output was appended to:

```
/home/bio/tmux-heartbeat.log
```

### Detach from tmux

Pressed:

```
Ctrl+b
d
```

Observed:

```
[detached (from session linux-lab)]
```

The tmux session remained available.

Verification:

```
tmux ls
```

Observed:

```
linux-lab: 1 windows (created Thu Nov 5 17:05:01 2026)
```

The heartbeat continued writing while detached.

### Verify heartbeat activity

```
tail -n 5 "$HOME/tmux-heartbeat.log"
```

Timestamps were recorded at five-second intervals.

## Experiment 4 — Real SSH disconnection and recovery

This was the central persistence test.

### Disconnect SSH

From Windows PowerShell, while outside the detached tmux session:

```
exit
```

Observed:

```
logout
Connection to 192.168.146.134 closed.
```

The Windows terminal returned to the PowerShell prompt.

### Reconnect SSH

From Windows PowerShell:

```
ssh bio@192.168.146.134
```

Authentication succeeded, and a new SSH shell opened.

### Locate the original tmux session

```
tmux ls
```

Observed:

```
linux-lab: 1 windows (created Thu Nov 5 17:05:01 2026)
```

The original session still existed.

### Reattach to the original session

```
tmux attach -t linux-lab
```

The original tmux session was recovered successfully.

The heartbeat command had completed naturally by this point.

### Verify the heartbeat evidence

```
tail -n 10 "$HOME/tmux-heartbeat.log"
wc -l "$HOME/tmux-heartbeat.log"
```

The final timestamps included:

```
2026-11-05 17:13:16
2026-11-05 17:13:21
2026-11-05 17:13:26
2026-11-05 17:13:31
```

The SSH disconnection occurred at approximately 17:13:14 UTC.

The records at 17:13:16, 17:13:21, 17:13:26, and 17:13:31 demonstrate that the workload continued after the SSH client disconnected.

The line count was:

```
60 /home/bio/tmux-heartbeat.log
```

All 60 iterations completed.

Result: The original tmux session survived the actual SSH disconnection and was recovered after reconnecting.

## Experiment 5 — tmux windows and panes

### Windows

Created a second window using:

```
Ctrl+b, c
```

Switched to the previous window using:

```
Ctrl+b, p
```

Opened the window selector using:

```
Ctrl+b, w
```

The session contained two windows:

- Window 0: bash
- Window 1: bash

### Panes

Split a window vertically using:

```
Ctrl+b, %
```

Switched between panes using:

```
Ctrl+b, o
```

The two panes maintained independent Bash shells.

Changing the working directory in one pane did not change the working directory in the other.

The extra pane was closed using:

```
Ctrl+b, x
```

After cleanup:

```
tmux display-message -p '#{window_panes}'
```

returned:

```
1
```

Window inspection:

```
tmux list-windows -t linux-lab
```

showed two windows, each containing one pane.

## Experiment 6 — Bash disown

### Start a background process

```
sleep 300 &
```

Observed:

```
[1] 3188
```

### Inspect the job

```
jobs -l
```

Observed:

```
[1]+  3188 Running                    sleep 300 &
```

### Remove the job from Bash's job table

```
disown %1
```

A subsequent `jobs -l` returned no output.

### Verify the process independently

```
ps -p 3188 -o pid,ppid,stat,etime,cmd
```

Observed:

```
PID    PPID STAT     ELAPSED CMD
3188   2697 S          04:39 sleep 300
```

The process still existed even though Bash no longer listed it as a job.

A later attempt to terminate PID `3188` reported that no such process existed. A subsequent `ps` check returned only the column headings.

The process had completed its five-minute sleep naturally before the termination attempt.

Observation: `disown` removes a job from Bash's job table; it does not terminate the underlying process or guarantee persistence after shell exit.

## Commands and shortcuts practised

| Command or shortcut    | Purpose                            |
| ---------------------- | ---------------------------------- |
| `jobs -l`              | List shell jobs with process IDs   |
| `bg %1`                | Resume job 1 in the background     |
| `fg %1`                | Bring job 1 to the foreground      |
| `sleep 300 &`          | Start a background process         |
| `nohup`                | Ignore hangup signals              |
| `disown %1`            | Remove job 1 from Bash's job table |
| `ps -p`                | Inspect a process by PID           |
| `tmux new -s`          | Create a named tmux session        |
| `tmux ls`              | List tmux sessions                 |
| `tmux attach -t`       | Attach to an existing session      |
| `tmux list-windows`    | List session windows               |
| `tmux display-message` | Display tmux information           |
| `tail -n`              | Inspect the end of a file          |
| `wc -l`                | Count lines                        |
| `Ctrl+Z`               | Suspend a foreground process       |
| `Ctrl+C`               | Interrupt a foreground process     |
| `Ctrl+b`, `d`          | Detach from tmux                   |
| `Ctrl+b`, `c`          | Create a window                    |
| `Ctrl+b`, `p`          | Previous window                    |
| `Ctrl+b`, `w`          | Window selector                    |
| `Ctrl+b`, `%`          | Vertical pane split                |
| `Ctrl+b`, `o`          | Switch panes                       |
| `Ctrl+b`, `x`          | Close active pane                  |

## Key observations and lessons

1. Bash job numbers and Linux PIDs are different identifiers.
2. A background process is not automatically protected from `SIGHUP`.
3. `nohup` makes a command ignore `SIGHUP`, while `&` places it in the background.
4. `disown` removes a job from Bash's job table but does not kill the process.
5. An empty `jobs` listing does not prove that no process exists.
6. `ps` can inspect processes independently of the current shell's job table.
7. tmux maintains sessions independently of the SSH client.
8. Detaching from tmux does not terminate the session.
9. A tmux session can contain multiple windows, and each window can contain multiple panes.
10. Each pane has its own shell and working-directory state.
11. tmux does not protect against machine shutdown, VM power-off, or termination of the tmux server.
12. Process inspection and verification should precede cleanup actions.

## Verification

- Established an SSH connection from Windows to Ubuntu.
- Suspended a foreground process using `Ctrl+Z`.
- Inspected jobs using `jobs -l`.
- Resumed a job using `bg`.
- Returned a job to the foreground using `fg`.
- Terminated the test process.
- Started and inspected a `nohup` process.
- Created a named tmux session.
- Ran a bounded heartbeat workload inside tmux.
- Detached without terminating the workload.
- Disconnected the actual SSH client.
- Reconnected and recovered the original tmux session.
- Verified timestamps recorded after SSH disconnection.
- Verified all 60 heartbeat records.
- Created and switched between tmux windows.
- Split and switched between tmux panes.
- Verified independent pane working directories.
- Removed a job from Bash's job table using `disown`.
- Inspected the disowned process using `ps`.

## What I learned

Linux job control, process persistence, and terminal multiplexing solve related but different problems.

Bash job control manages processes associated with the current shell. `nohup` changes how a command handles hangup signals. `disown` changes Bash's tracking of a job. tmux maintains a persistent terminal session that can be detached from and recovered after an SSH disconnection.

The most important practical lesson is that a disconnected terminal does not have to mean lost work. With tmux, a running terminal session can survive a client disconnection and be recovered after reconnecting.

The engineering principle remains: inspect first, act deliberately, and verify afterward.
