#!/usr/bin/env bash
# Structural self-check for harness-foundation.
#
# Deliberately dependency-free (POSIX tools only, no package manager, no runtime) so that this
# repository can have a real verification step without acquiring a stack. On Windows, run it from
# Git Bash.
#
# Usage: bash scripts/validate-harness.sh

set -u

cd "$(dirname "$0")/.." || exit 1

fail_count=0
warn_count=0

fail() { printf 'FAIL  %s\n' "$1"; fail_count=$((fail_count + 1)); }
warn() { printf 'WARN  %s\n' "$1"; warn_count=$((warn_count + 1)); }
pass() { printf 'ok    %s\n' "$1"; }

# Reads the value of a frontmatter key from the first frontmatter block of a file.
frontmatter_value() {
  awk -v key="$2" '
    NR == 1 && $0 != "---" { exit }
    NR == 1 { next }
    $0 == "---" { exit }
    { if (index($0, key ":") == 1) { sub("^" key ": *", ""); print; exit } }
  ' "$1"
}

has_frontmatter() {
  [ "$(head -n 1 "$1")" = "---" ]
}

echo "== required files =="
required="
CLAUDE.md
README.md
.gitignore
.claude/settings.json
docs/harness-engineering.md
docs/architecture.md
docs/workflow.md
docs/agent-design.md
docs/skill-design.md
docs/portability.md
templates/CLAUDE.template.md
templates/agent.template.md
templates/skill.template.md
templates/settings.template.json
examples/README.md
"
for f in $required; do
  if [ -f "$f" ]; then pass "$f"; else fail "missing: $f"; fi
done

echo
echo "== agents =="
agent_count=0
for f in .claude/agents/*.md; do
  [ -e "$f" ] || { fail "no agent files found in .claude/agents/"; break; }
  agent_count=$((agent_count + 1))
  base=$(basename "$f" .md)
  if ! has_frontmatter "$f"; then
    fail "$f: no frontmatter block"
    continue
  fi
  name=$(frontmatter_value "$f" name)
  desc=$(frontmatter_value "$f" description)
  tools=$(frontmatter_value "$f" tools)
  [ -n "$name" ] || fail "$f: frontmatter missing 'name'"
  [ -n "$desc" ] || fail "$f: frontmatter missing 'description'"
  [ -n "$tools" ] || warn "$f: no 'tools' grant — the agent inherits every tool"
  [ "$name" = "$base" ] || fail "$f: name '$name' does not match filename '$base'"
  [ "${#desc}" -ge 40 ] || warn "$f: description is short; it must say when to use this role"
  case "$tools" in
    *Edit*|*Write*)
      case "$base" in
        implementer) : ;;
        *) warn "$f: read-only role appears to grant Edit/Write" ;;
      esac
      ;;
  esac
  for section in "## Responsibilities" "## Constraints" "## Output"; do
    grep -q "^$section" "$f" || fail "$f: missing section '$section'"
  done
  pass "$f ($name)"
done
[ "$agent_count" -gt 0 ] && pass "$agent_count agent(s)"

echo
echo "== skills =="
# Built-in skill names this harness must not shadow. See docs/skill-design.md.
builtin_skills="code-review security-review simplify init run loop schedule design dataviz"
skill_count=0
for d in .claude/skills/*/; do
  [ -e "$d" ] || { fail "no skill directories found in .claude/skills/"; break; }
  skill_count=$((skill_count + 1))
  base=$(basename "$d")
  f="${d}SKILL.md"
  if [ ! -f "$f" ]; then
    fail "$d: missing SKILL.md"
    continue
  fi
  if ! has_frontmatter "$f"; then
    fail "$f: no frontmatter block"
    continue
  fi
  name=$(frontmatter_value "$f" name)
  desc=$(frontmatter_value "$f" description)
  [ -n "$name" ] || fail "$f: frontmatter missing 'name'"
  [ -n "$desc" ] || fail "$f: frontmatter missing 'description'"
  [ "$name" = "$base" ] || fail "$f: name '$name' does not match directory '$base'"
  [ "${#desc}" -ge 40 ] || warn "$f: description is short; it must say when to use this skill"
  # A local skill that shadows a built-in leaves the user unable to tell which one ran.
  case " $builtin_skills " in
    *" $base "*) fail "$f: '$base' shadows a built-in skill — rename it and compose over the built-in instead" ;;
  esac
  for section in "## Purpose" "## When to use" "## Inputs" "## Procedure" "## Validation" "## Failure handling" "## Output"; do
    grep -q "^$section" "$f" || fail "$f: missing section '$section'"
  done
  pass "$f ($name)"
done
[ "$skill_count" -gt 0 ] && pass "$skill_count skill(s)"

echo
echo "== no project-specific commands in the harness =="
# The harness is applied to projects whose stack it cannot know; a concrete build/test command
# baked in here would teach the agent to invent commands. docs/ may name them as anti-examples.
if grep -rnE '\b(npm|pnpm|yarn|npx|gradle|mvn|pytest|cargo|go test|dotnet|poetry|pip) ' \
     .claude/ templates/CLAUDE.template.md templates/agent.template.md templates/skill.template.md 2>/dev/null; then
  fail "hardcoded package-manager/build command found above"
else
  pass "no hardcoded stack commands in .claude/ or templates"
fi

echo
echo "== templates are not active instructions =="
# A file named CLAUDE.md inside templates/ can be picked up as real guidance for anything under
# that directory. Templates carry an explicit .template. infix so they never can be.
if [ -e templates/CLAUDE.md ]; then
  fail "templates/CLAUDE.md would be read as active instructions — name it CLAUDE.template.md"
else
  pass "no active-instruction filename in templates/"
fi
for f in templates/*.md; do
  [ -e "$f" ] || continue
  case "$(basename "$f")" in
    *.template.md|README.md) : ;;
    *) warn "$f: template files should be named <name>.template.md" ;;
  esac
done

echo
echo "== translations =="
# Two copies of the README will drift. This does not compare prose — it only catches the case where
# one language gained or lost a section and the other did not.
if [ -f README.ko.md ]; then
  en_h=$(grep -c '^## ' README.md)
  ko_h=$(grep -c '^## ' README.ko.md)
  if [ "$en_h" -ne "$ko_h" ]; then
    warn "README.md has $en_h sections but README.ko.md has $ko_h — the translations have drifted"
  else
    pass "README.md and README.ko.md have the same section structure ($en_h sections)"
  fi
  grep -q 'README.ko.md' README.md || warn "README.md does not link to README.ko.md"
  grep -q 'README.md' README.ko.md || warn "README.ko.md does not link back to README.md"
fi

echo
echo "== settings.json =="
s=.claude/settings.json
if [ -f "$s" ]; then
  opens=$(tr -cd '{' < "$s" | wc -c)
  closes=$(tr -cd '}' < "$s" | wc -c)
  if [ "$opens" -ne "$closes" ]; then
    fail "$s: unbalanced braces ($opens open, $closes close)"
  else
    pass "$s: braces balanced"
  fi
  for key in '"permissions"' '"allow"' '"ask"' '"deny"'; do
    grep -q "$key" "$s" || fail "$s: missing $key"
  done
  grep -q 'Read(\./\.env)' "$s" || fail "$s: .env is not denied"
  grep -q 'git push --force' "$s" || fail "$s: force-push is not denied"
  grep -q 'rm -rf' "$s" || fail "$s: 'rm -rf' is not denied"
  if diff -q "$s" templates/settings.template.json >/dev/null 2>&1; then
    pass "settings template matches the active policy"
  else
    warn "templates/settings.template.json has diverged from .claude/settings.json"
  fi
fi

echo
echo "== intra-repo links =="
broken=0
checked=0
while IFS= read -r md; do
  dir=$(dirname "$md")
  grep -oE '\]\([^)#][^)]*\)' "$md" 2>/dev/null | sed -E 's/^\]\(//; s/\)$//' | while IFS= read -r link; do
    case "$link" in
      http*|mailto:*|'<'*) continue ;;
    esac
    target=${link%%#*}
    [ -n "$target" ] || continue
    if [ ! -e "$dir/$target" ] && [ ! -e "$target" ]; then
      printf 'FAIL  %s: broken link -> %s\n' "$md" "$link"
      echo x >> .harness-link-errors
    fi
  done
  checked=$((checked + 1))
done <<< "$(find . -name '*.md' -not -path './.git/*')"
if [ -f .harness-link-errors ]; then
  broken=$(wc -l < .harness-link-errors)
  rm -f .harness-link-errors
  fail_count=$((fail_count + broken))
else
  pass "all relative markdown links resolve"
fi

echo
if [ "$fail_count" -eq 0 ]; then
  printf 'PASS — %d failure(s), %d warning(s)\n' "$fail_count" "$warn_count"
  exit 0
else
  printf 'FAILED — %d failure(s), %d warning(s)\n' "$fail_count" "$warn_count"
  exit 1
fi
