# Week 2 — Process Inspector

**Date:** 3 November 2026
**Environment:** Ubuntu 26.04.1 LTS running in VMware
**Hostname:** linux-lab

## Objective

Investigate running Linux processes, identify CPU- and memory-intensive workloads, inspect their properties, adjust scheduling priority, and terminate test processes safely.

The investigation followed this workflow:

1. Inspect the system and its running processes.
2. Generate a controlled CPU-intensive workload.
3. Identify and inspect the workload using `ps`, `top`, and `pgrep`.
4. Change its scheduling niceness using `renice`.
5. Generate a bounded memory workload and inspect its memory usage.
6. Terminate test processes gracefully and verify cleanup.

## Environment observations

| Item | Observation |
|---|---|
| Operating system | Ubuntu 26.04.1 LTS |
| Kernel | 7.0.0-38-generic |
| Architecture | x86_64 |
| Logical CPUs visible to VM | 2 |
| VM memory | 3.3 GiB |
| Available memory at inspection | 2.6 GiB |
| Swap | 3.8 GiB |
| Python | 3.14.4 |
| `ps` executable | `/usr/bin/ps` |

## Experiment 1 — CPU-intensive process

### Generate the workload

```bash
yes > /dev/null &
```

The `yes` command continuously produces output. The `>` operator redirects standard output, `/dev/null` discards it, and `&` starts the command in the background.

### Inspect the process

```bash
pgrep -a yes
ps -p 42412 -o pid,ppid,user,stat,%cpu,%mem,ni,pri,cmd
```

Two CPU workloads were identified:
- PID `42041`
- PID `42412`

Both consumed approximately one logical CPU during inspection.

### Observe live resource usage

Used `top` to monitor CPU and memory usage in real time.

The initial CPU observation was approximately 98.7%.

### Change scheduling priority

```bash
renice 10 -p 42412
```

The system reported:

```text
42412 (process ID) old priority 0, new priority 10
```

Verification:

```bash
ps -p 42412 -o pid,stat,%cpu,ni,pri,cmd
```

Observed:

```text
42412 RN 98.4 10 9 yes
```

The niceness value changed from `0` to `10`.

**Important:** Increasing niceness makes a process less favoured by the scheduler relative to competing processes. It does not impose a CPU usage limit.

### Terminate and verify

```bash
kill -TERM 42041
kill -TERM 42412
pgrep -a yes
```

The final `pgrep` returned no output, confirming that no matching `yes` workloads remained.

## Experiment 2 — Memory-intensive process

### Generate a bounded memory workload

```bash
python3 -c 'import time; data = bytearray(64 * 1024 * 1024); data[::4096] = b"\x01" * len(data[::4096]); print("Allocated 64 MiB"); time.sleep(300)' &
```

This allocated a 64 MiB byte array, touched its memory pages, printed a confirmation, and slept for 300 seconds.

### Inspect memory usage

```bash
ps -p 42657 -o pid,ppid,stat,%cpu,%mem,vsz,rss,ni,cmd
```

Observed:

| Metric | Result |
|---|---:|
| PID | 42657 |
| State | S |
| CPU usage | 0.4% |
| Memory percentage | 2.2% |
| VSZ | 84,232 KB |
| RSS | 75,796 KB |

RSS was approximately 74 MiB. The additional memory beyond the 64 MiB allocation includes Python interpreter and process overhead.

The process was sleeping but still retained its allocated memory.

### Terminate and verify

```bash
kill -TERM 42657
```

The shell reported that the Python background job had terminated.

## Commands practised

| Command | Purpose |
|---|---|
| `ps aux` | Display a snapshot of running processes |
| `ps -p` | Inspect selected process IDs |
| `top` | Monitor processes interactively |
| `pgrep -a` | Find processes by name and display commands |
| `renice` | Change process niceness |
| `kill -TERM` | Request graceful process termination |
| `free -h` | Inspect memory and swap |
| `nproc` | Display available processing units |

## Key observations and lessons

1. `ps` provides a snapshot, while `top` provides a continuously updating view.
2. A PID identifies a particular process. A process name alone is insufficient evidence for safely terminating it.
3. Approximately 100% CPU can mean one logical CPU is fully utilised; it does not necessarily mean the entire machine is exhausted.
4. Niceness influences relative scheduling priority; it does not cap CPU usage.
5. VSZ represents virtual memory size, while RSS represents resident physical memory.
6. A sleeping process can retain memory while it waits.
7. `SIGTERM` requests graceful termination and should generally be tried before `SIGKILL`.
8. Pressing `Ctrl+C` at the shell prompt does not automatically terminate every background process.

## Verification

- [x] Identified running processes.
- [x] Observed CPU usage with `top`.
- [x] Located processes using `pgrep`.
- [x] Inspected process attributes using `ps`.
- [x] Changed niceness using `renice`.
- [x] Inspected virtual and resident memory.
- [x] Terminated test workloads using `SIGTERM`.
- [x] Verified that the CPU test workloads were no longer running.

## What I learned

Linux process management is not simply about finding a process and killing it. It involves gathering evidence, understanding process identity and state, interpreting resource usage, making controlled changes, and verifying the outcome.

The most important lesson is to **inspect first, act deliberately, and verify afterward.**
