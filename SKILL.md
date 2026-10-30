---
name: remote-dev
description: "Kanna share link: start, restart, or stop a password-protected public Kanna URL so the user can drive Claude Code/Codex on this machine from a phone, tablet, or another computer."
---

# Remote Dev

Kanna serves Claude Code and Codex in a browser. `--share` publishes it on a Cloudflare quick tunnel, so anyone with the URL and password gets a terminal on this machine. Upstream: https://github.com/jakemor/kanna

## Confirm

Before any install or `--share`, tell the user that this installs Bun/Kanna (if missing) and opens a public URL with terminal access to this machine. Proceed only on the user's yes.

## Prerequisites

1. `bun --version` prints 1.3.5 or later. Missing: `curl -fsSL https://bun.sh/install | bash`. Older: `bun upgrade`.
2. `kanna --version` succeeds. Missing: `bun install -g kanna-code`.

## Start

1. Preflight: `curl -fsS http://localhost:3210/health`. A response means Kanna is already running, and its password and share mode cannot be read back. Ask the user whether to restart it; on yes, follow Restart. A connection error means it is not running: continue.
2. Generate the password: `openssl rand -base64 24`. Use the printed value as `<PASSWORD>`.
3. Launch with the Bash tool's `run_in_background`:
   ```bash
   cd <PROJECT_ROOT> && kanna --password "<PASSWORD>" --share --no-open > "${TMPDIR:-/tmp}/kanna-share.log" 2>&1
   ```
4. Poll the log for up to 60 s:
   ```bash
   LOG="${TMPDIR:-/tmp}/kanna-share.log"
   for i in $(seq 60); do grep -Eq 'trycloudflare\.com|already (running|starting)' "$LOG" && break; sleep 1; done
   grep -Eo 'https://[a-z0-9-]+\.trycloudflare\.com' "$LOG" | head -n1
   grep -A1 'Local URL:' "$LOG" | tail -n1
   ```
   - `already running` or `already starting` in the log: another Kanna holds the single-instance lock, so nothing was shared. Ask the user whether to restart, as in step 1.
   - Confirm `curl -fsS http://localhost:<port>/health` returns `{"ok":true…}`, with `<port>` taken from the `Local URL:` line.
5. Done when the reply to the user contains the public URL, the local URL, and the password. If 60 s pass with no public URL, show the user `tail -n 40` of the log and stop.

The public URL changes on every start. Other flags: run `kanna --help` (named tunnel for a persistent URL: `--cloudflared <token>`).

## Stop

Stopping cancels every running Kanna chat. If this session runs inside Kanna, tell the user that and get a yes first.

Run `kanna stop`. Done when it prints `stopped` or `kanna isn't running` and exits 0. On exit 1, show the user its output: an older Kanna has to be stopped with Ctrl-C where it runs, or shutdown is still in progress.

## Restart

Run Stop; once `kanna stop` exits 0, run Start. Restart always yields a new password and a new public URL; give both to the user.
