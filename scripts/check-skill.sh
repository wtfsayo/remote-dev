#!/usr/bin/env bash
# Static checks for the audit's acceptance criteria. No network, no Kanna.
set -uo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
skill="$root/SKILL.md"
readme="$root/README.md"
fail=0

ok()  { printf 'ok   %s\n' "$1"; }
bad() { printf 'FAIL %s\n' "$1"; fail=1; }
check() { if eval "$2"; then ok "$1"; else bad "$1"; fi; }

# Stop/Restart lifecycle
check "SKILL.md has no pkill"                       "! grep -q pkill '$skill'"
check "SKILL.md stops with kanna stop"              "grep -q '\`kanna stop\`' '$skill'"
check "SKILL.md has no same-password restart"       "! grep -qi 'same password' '$skill'"
check "SKILL.md warns that stop cancels chats"      "grep -q 'cancels every running Kanna chat' '$skill'"

# Start: preflight, background launch, URL capture, completion criterion
check "Start preflights /health"                    "grep -q 'curl -fsS http://localhost:3210/health' '$skill'"
check "Start command passes --no-open"              "grep -q 'kanna --password \"<PASSWORD>\" --share --no-open' '$skill'"
check "Start runs in the background"                "grep -q 'run_in_background' '$skill'"
check "Start logs to kanna-share.log"               "grep -q 'kanna-share.log' '$skill'"
check "Start handles the single-instance guard"     "grep -q 'already running' '$skill'"
check "Start has a done criterion"                  "grep -q '^5\. Done when' '$skill'"
check "No second instance on another port"         "! grep -q -- '--port' '$skill'"

# Triggers and confirmation
desc="$(sed -n 's/^description: *//p' "$skill" | head -n1)"
check "description starts with 'Kanna share link'"  "[[ \"\$desc\" == '\"Kanna share link:'* ]]"
check "description <= 200 bytes"                    "(( \${#desc} <= 200 ))"
check "SKILL.md confirms before install/--share"    "grep -q \"Proceed only on the user's yes\" '$skill'"

# Sediment and stale facts
check "No cloudflared install section"              "! grep -q 'brew install cloudflared' '$skill'"
check "No 'What You Get' section"                   "! grep -q 'What You Get' '$skill'"
check "Bun minimum is 1.3.5"                        "grep -q '1\.3\.5' '$skill' && grep -q 'bun upgrade' '$skill'"

# README is a human doc, not a copy of SKILL.md
check "README differs from SKILL.md"                "! diff -q '$skill' '$readme' >/dev/null"
check "README has no frontmatter"                   "[[ \"\$(head -n1 '$readme')\" != '---' ]]"
check "README has no Kanna command lines"           "! grep -Eq '^[[:space:]]*kanna( |\$)' '$readme'"
check "README points at SKILL.md"                   "grep -q '(SKILL.md)' '$readme'"
check "README has an install line"                  "grep -q 'claude plugin install remote-dev@remote-dev' '$readme'"

# Manifests and evals parse
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json evals/triggers.json; do
  check "$f is valid JSON" "python3 -m json.tool '$root/$f' >/dev/null 2>&1"
done

exit "$fail"
