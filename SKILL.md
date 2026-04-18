---
name: remote-dev
description: Start Kanna for remote development via Claude Code and Codex from any device. Use when the user wants to work remotely, start Kanna, access the dev environment from another machine, or mentions "remote dev", "kanna", "work remotely", "remote coding", or "access from phone/tablet".
---

# Remote Dev

Start a Kanna instance so you can use Claude Code and Codex from any device — phone, tablet, another laptop — via a public URL with password protection.

## Prerequisites

Run these checks before starting. Install anything missing.

### 1. Bun (required for Kanna)

```bash
bun --version
# Install if missing:
curl -fsSL https://bun.sh/install | bash
```

### 2. Kanna

```bash
kanna --version
# Install or update:
bun install -g kanna-code
```

### 3. cloudflared (optional — Kanna bundles its own for `--share`)

Only needed if you want to tunnel other services independently.

```bash
cloudflared --version
# Install if missing:
brew install cloudflared
```

## Start

```bash
# Generate a password
openssl rand -base64 24

# Start Kanna from the project root
cd <PROJECT_ROOT>
kanna --password "<PASSWORD>" --share
```

Kanna starts on `localhost:3210`, creates a Cloudflare quick tunnel, and prints a public URL + QR code.

**Reference**: https://github.com/jakemor/kanna

## What You Get

- **Claude Code** sessions in the browser — full terminal, file diffs, branch management
- **Codex** sessions (if Codex CLI is installed)
- **Embedded terminal** with PTY support (macOS/Linux)
- **Branch switcher** — switch, push, sync from the sidebar
- **Diff viewer** — browse file diffs, discard/ignore files, commit

## Access

| | |
|---|---|
| **Local** | `http://localhost:3210` |
| **Public** | Printed on start (ephemeral — changes every restart) |
| **Password** | Whatever you generated with `openssl rand -base64 24` |

The public URL works from any device. Enter the password at the prompt.

## Tips

- Use `--no-open` to suppress the browser auto-open when starting from an agent
- Use `--port <number>` if 3210 is taken
- Kanna's tunnel URL is ephemeral. For a persistent URL, use `--cloudflared <token>` with a named Cloudflare tunnel

## Stop

```bash
pkill -f kanna
```

## Restart (same password)

```bash
pkill -f kanna; sleep 1
cd <PROJECT_ROOT>
kanna --password "<PASSWORD>" --share --no-open &
```
