#!/usr/bin/env bash
# Live trigger probes: runs each case in evals/triggers.json through `claude -p`
# with this plugin loaded and Bash/Write/Edit disabled, then checks whether the
# remote-dev skill was invoked. Prints the final reply next to expect_behavior
# for review. Exit 1 on any trigger mismatch. Requires claude and jq.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
model="${MODEL:-sonnet}"
fail=0

while IFS= read -r case; do
  id="$(jq -r .id <<<"$case")"
  prompt="$(jq -r .prompt <<<"$case")"
  want="$(jq -r .expect_skill <<<"$case")"

  out="$(claude -p "$prompt" --plugin-dir "$root" --model "$model" \
    --disallowedTools "Bash,Write,Edit" --max-turns 4 \
    --output-format stream-json --verbose </dev/null || true)"

  skills="$(jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use" and .name=="Skill") | .input.skill' <<<"$out" || true)"
  got=false
  if grep -qx 'remote-dev:remote-dev' <<<"$skills"; then got=true; fi
  if [[ "$got" == "$want" ]]; then status=PASS; else status=FAIL; fail=1; fi
  printf '%s %s (skill invoked: %s, expected: %s)\n' "$status" "$id" "$got" "$want"
  printf '  expect: %s\n' "$(jq -r .expect_behavior <<<"$case")"
  printf '  reply:  %s\n\n' "$(jq -r 'select(.type=="result") | .result // empty' <<<"$out" | tr '\n' ' ' | cut -c1-600)"
done < <(jq -c '.[]' "$root/evals/triggers.json")

exit "$fail"
