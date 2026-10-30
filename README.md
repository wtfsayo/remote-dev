# remote-dev

A Claude Code plugin with one skill. It starts, restarts, or stops a password-protected public [Kanna](https://github.com/jakemor/kanna) link, so you can drive Claude Code or Codex on this machine from a phone, tablet, or another computer.

The link gives terminal access to the machine. The skill asks before it installs Bun or Kanna or opens the link.

## Install

```bash
claude plugin marketplace add wtfsayo/remote-dev
claude plugin install remote-dev@remote-dev
```

To try it from a local checkout instead: `claude --plugin-dir /path/to/remote-dev`.

## Use

Ask Claude Code something like "start a Kanna share link so I can code from my phone", or run `/remote-dev:remote-dev`. It replies with the public URL, the local URL, and the password.

The agent instructions live in [SKILL.md](SKILL.md); edit that file to change behaviour.

## Checks

- `scripts/check-skill.sh`: static checks on SKILL.md, README.md, and the manifests.
- `evals/run.sh`: live trigger probes from `evals/triggers.json` (calls `claude -p`, costs a few cents).
