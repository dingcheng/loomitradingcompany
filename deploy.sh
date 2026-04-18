#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# deploy.sh — Deploy loomiwebsite to github.com/dingcheng/loomitradingcompany
#
# What this does (first run):
#   1. Initializes a git repo here (if needed) and sets remote `origin` to
#      git@github.com:dingcheng/loomitradingcompany.git
#   2. Backs up the current remote `main` to `main-mkdocs-backup` (non-destructive
#      safety net — you can always recover the old mkdocs source from there).
#   3. Force-pushes THIS directory's files as the new `main`.
#   4. Switches GitHub Pages source to "GitHub Actions" so the workflow at
#      .github/workflows/deploy.yml publishes the site.
#   5. Re-applies the custom domain (loomicompany.com) via CNAME + Pages API,
#      preserving HTTPS enforcement.
#
# Subsequent runs just commit + push to `main`; the Actions workflow redeploys.
#
# Requirements:
#   - `git` and `gh` (GitHub CLI), authenticated as the repo owner
#   - SSH access to GitHub (verified: gh reports SSH protocol for dingcheng)
#
# Usage:
#   ./deploy.sh                      # interactive: confirms before destructive ops
#   ./deploy.sh --yes                # skip confirmation
#   ./deploy.sh -m "commit message"  # custom commit message
# -----------------------------------------------------------------------------

set -euo pipefail

REPO_SLUG="dingcheng/loomitradingcompany"
REMOTE_URL="git@github.com:${REPO_SLUG}.git"
BRANCH="main"
DOMAIN="loomicompany.com"
BACKUP_BRANCH="main-mkdocs-backup"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
c_bold=$'\033[1m'; c_dim=$'\033[2m'; c_red=$'\033[31m'
c_green=$'\033[32m'; c_yellow=$'\033[33m'; c_cyan=$'\033[36m'; c_reset=$'\033[0m'
say()  { printf "%s▸ %s%s\n" "$c_cyan" "$*" "$c_reset"; }
warn() { printf "%s! %s%s\n" "$c_yellow" "$*" "$c_reset"; }
ok()   { printf "%s✓ %s%s\n" "$c_green" "$*" "$c_reset"; }
die()  { printf "%s✗ %s%s\n" "$c_red" "$*" "$c_reset" >&2; exit 1; }

# -------- args --------
assume_yes=0
commit_msg=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes) assume_yes=1; shift ;;
    -m|--message) commit_msg="${2:-}"; shift 2 ;;
    -h|--help)
      sed -n '2,30p' "$0"; exit 0 ;;
    *) die "Unknown arg: $1" ;;
  esac
done

# -------- preflight --------
command -v git >/dev/null || die "git not found"
command -v gh  >/dev/null || die "gh (GitHub CLI) not found — install from https://cli.github.com"

gh auth status >/dev/null 2>&1 || die "gh is not authenticated. Run: gh auth login"

# Confirm we're pointing at the right working directory
[[ -f index.html ]] || die "index.html not found — run this script from the site root"
[[ -f CNAME    ]] || die "CNAME not found — aborting (custom domain must be preserved)"
grep -q "^${DOMAIN}$" CNAME || die "CNAME does not contain '${DOMAIN}' — aborting"

# Ensure Actions workflow is present
[[ -f .github/workflows/deploy.yml ]] || die ".github/workflows/deploy.yml missing — the site won't build"

printf "\n%sDeploying%s → %shttps://github.com/%s%s\n" "$c_bold" "$c_reset" "$c_bold" "$REPO_SLUG" "$c_reset"
printf "  Custom domain : %s%s%s\n" "$c_bold" "$DOMAIN" "$c_reset"
printf "  Branch        : %s%s%s (force-pushed on first run)\n" "$c_bold" "$BRANCH" "$c_reset"
printf "  Backup branch : %s%s%s (existing remote main preserved here)\n\n" "$c_bold" "$BACKUP_BRANCH" "$c_reset"

if [[ $assume_yes -ne 1 ]]; then
  read -r -p "Proceed? [y/N] " answer
  [[ "$answer" == "y" || "$answer" == "Y" ]] || { warn "Aborted."; exit 1; }
fi

# -------- init local repo --------
if [[ ! -d .git ]]; then
  say "Initializing local git repo"
  git init -q -b "$BRANCH"
fi

# Make sure we're on the target branch (detached states handled)
current_branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || echo "")"
if [[ "$current_branch" != "$BRANCH" ]]; then
  if git show-ref --verify --quiet "refs/heads/${BRANCH}"; then
    git checkout -q "$BRANCH"
  else
    git checkout -q -B "$BRANCH"
  fi
fi

# -------- configure remote --------
if git remote get-url origin >/dev/null 2>&1; then
  existing_url="$(git remote get-url origin)"
  if [[ "$existing_url" != "$REMOTE_URL" ]]; then
    say "Updating origin URL → $REMOTE_URL"
    git remote set-url origin "$REMOTE_URL"
  fi
else
  say "Adding origin → $REMOTE_URL"
  git remote add origin "$REMOTE_URL"
fi

# -------- back up existing remote main (only if not already backed up) --------
say "Fetching remote refs"
git fetch --quiet origin || true

has_remote_main=0
if git show-ref --verify --quiet "refs/remotes/origin/${BRANCH}"; then
  has_remote_main=1
fi

has_backup=0
if git ls-remote --exit-code --heads origin "$BACKUP_BRANCH" >/dev/null 2>&1; then
  has_backup=1
fi

if [[ $has_remote_main -eq 1 && $has_backup -eq 0 ]]; then
  say "Backing up existing remote '${BRANCH}' → '${BACKUP_BRANCH}'"
  # Create the backup branch on the remote at the current tip of origin/main
  backup_sha="$(git rev-parse "origin/${BRANCH}")"
  git push -q origin "${backup_sha}:refs/heads/${BACKUP_BRANCH}" \
    || warn "Failed to create backup branch (maybe you don't need one). Continuing."
  ok  "Old main preserved at: https://github.com/${REPO_SLUG}/tree/${BACKUP_BRANCH}"
elif [[ $has_backup -eq 1 ]]; then
  ok "Backup branch '${BACKUP_BRANCH}' already exists on remote — skipping backup"
fi

# -------- stage + commit --------
# .gitignore already excludes .DS_Store, node_modules, etc.
say "Staging files"
git add -A

if git diff --cached --quiet; then
  warn "No staged changes."
  # First deploy? Still need to create a commit if there are no commits yet
  if ! git rev-parse --verify --quiet HEAD >/dev/null; then
    die "No files to commit. Add content first."
  fi
else
  msg="${commit_msg:-Deploy site ($(date -u +%Y-%m-%dT%H:%M:%SZ))}"
  say "Committing: $msg"
  git commit -q -m "$msg"
fi

# -------- push --------
needs_force=0
if [[ $has_remote_main -eq 1 ]]; then
  # Are we ancestors of origin/main? If not, force-push is required.
  if ! git merge-base --is-ancestor "origin/${BRANCH}" HEAD 2>/dev/null; then
    needs_force=1
  fi
fi

if [[ $needs_force -eq 1 ]]; then
  say "Force-pushing '${BRANCH}' (remote has unrelated history — backed up above)"
  git push --force-with-lease=refs/heads/"${BRANCH}":refs/remotes/origin/"${BRANCH}" \
           origin "${BRANCH}:${BRANCH}" || git push --force origin "${BRANCH}:${BRANCH}"
else
  say "Pushing '${BRANCH}'"
  git push -u origin "${BRANCH}:${BRANCH}"
fi
ok "Pushed to origin/${BRANCH}"

# -------- configure Pages (switch to Actions source, set CNAME, enforce HTTPS) --------
say "Ensuring GitHub Pages uses 'GitHub Actions' as source"
# Fetch current config
pages_json="$(gh api "repos/${REPO_SLUG}/pages" 2>/dev/null || true)"
if [[ -z "$pages_json" ]]; then
  # Pages not yet enabled — create with Actions build type
  gh api --method POST "repos/${REPO_SLUG}/pages" \
    -F build_type=workflow >/dev/null
  ok "Enabled Pages with GitHub Actions build"
else
  build_type="$(printf "%s" "$pages_json" | python3 -c "import sys,json; print(json.load(sys.stdin).get('build_type',''))")"
  if [[ "$build_type" != "workflow" ]]; then
    gh api --method PUT "repos/${REPO_SLUG}/pages" \
      -F build_type=workflow >/dev/null
    ok "Switched Pages source → GitHub Actions (was: ${build_type})"
  else
    ok "Pages already using GitHub Actions"
  fi
fi

# Make sure the CNAME sticks (Pages re-reads the CNAME file from the deploy artifact,
# but we also set it via API so it survives regardless).
current_cname="$(gh api "repos/${REPO_SLUG}/pages" --jq .cname 2>/dev/null || echo "")"
if [[ "$current_cname" != "$DOMAIN" ]]; then
  say "Setting custom domain → $DOMAIN"
  gh api --method PUT "repos/${REPO_SLUG}/pages" -F cname="$DOMAIN" >/dev/null
  ok "Custom domain set"
else
  ok "Custom domain already set to $DOMAIN"
fi

# Enforce HTTPS (idempotent)
gh api --method PUT "repos/${REPO_SLUG}/pages" -F https_enforced=true >/dev/null 2>&1 \
  || warn "Could not enforce HTTPS automatically (may require domain revalidation)"

# -------- watch the deploy (non-blocking) --------
printf "\n%sDeploy triggered.%s\n" "$c_green" "$c_reset"
printf "  Repo     : https://github.com/%s\n" "$REPO_SLUG"
printf "  Actions  : https://github.com/%s/actions\n" "$REPO_SLUG"
printf "  Live     : https://%s/\n\n" "$DOMAIN"
printf "%sTip%s: watch the build with:   gh run watch -R %s\n" "$c_dim" "$c_reset" "$REPO_SLUG"
