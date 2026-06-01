#!/usr/bin/env bash
#
# Create or update the Semaphore `tvos-ci` secret used by
# .semaphore/semaphore.yml and .semaphore/promote-app-store.yml.
#
# Sharing model:
#   - `tvos-ci` holds ONLY the app-specific values that nothing else provides
#     (login/analytics/feature-flag keys used by the UI tests and CI.swift).
#   - The App Store Connect API key and the signing certificate are SHARED with
#     brunstadtv-app and are NOT duplicated here:
#       * ASC key  -> secret defining BCCMEDIA_APP_STORE_CONNECT_KEY_ID
#                     (brunstadtv-app's `bccmedia-testflight-api`)
#       * Cert     -> secret defining CERTIFICATE_P12_BASE64
#                     (brunstadtv-app's `ios-signing-certs`)
#     The pipeline attaches those secrets directly; this script only verifies
#     they exist and reports them. It never modifies them.
#   - `tvos-ci` is OUR secret: created if missing, UPDATED (replaced) if present.
#   - Values are sourced from the environment / an optional scripts/.env.semaphore
#     before falling back to an interactive prompt.
#
# Prereqs:
#   - `sem` CLI signed in to the BCC Semaphore org with rights to manage secrets.
#
# Usage:
#   scripts/setup-semaphore-secrets.sh           # create/update tvos-ci
#   scripts/setup-semaphore-secrets.sh --force   # don't prompt before replacing
#   scripts/setup-semaphore-secrets.sh --print   # show the plan, change nothing
#
# Optional: put values in an untracked scripts/.env.semaphore (KEY=VALUE per
# line) and they are picked up automatically. Do NOT commit that file.
#
# Note: written for macOS stock Bash 3.2 — no associative arrays.
set -euo pipefail

SECRET_NAME="tvos-ci"

# App-specific env vars that only `tvos-ci` provides (UI-test env + CI.swift
# injection). These mirror the per-repo secrets/vars of the old GitHub workflow.
PLAIN_VARS=(
  LOGIN_API_KEY
  AUTOLOGIN_HOST
  RUDDER_WRITE_KEY
  RUDDER_DATAPLANE_URL
  NPAW_ACCOUNT_CODE
  UNLEASH_URL
  UNLEASH_CLIENT_KEY
  SENTRY_DSN
)

# Shared capabilities expected to already exist as their own secrets. Each entry
# is "marker-env-var<TAB>human description"; the secret that defines the marker
# var is attached to the deploy/promote jobs instead of copying anything.
SHARED_MARKERS=(
  "BCCMEDIA_APP_STORE_CONNECT_KEY_ID|App Store Connect API key"
  "CERTIFICATE_P12_BASE64|signing certificate"
)

FORCE=0
PRINT_ONLY=0
for arg in "$@"; do
  case "$arg" in
    --force|--yes) FORCE=1 ;;
    --print|--dry-run) PRINT_ONLY=1 ;;
    -h|--help) sed -n '2,34p' "$0"; exit 0 ;;
    *) echo "error: unknown argument '$arg'" >&2; exit 2 ;;
  esac
done

command -v sem >/dev/null 2>&1 || { echo "error: 'sem' CLI not found in PATH" >&2; exit 1; }
command -v base64 >/dev/null 2>&1 || { echo "error: 'base64' not found in PATH" >&2; exit 1; }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Pull in any locally-stored values (untracked) — reuse values you already have.
ENV_FILE="$REPO_ROOT/scripts/.env.semaphore"
if [ -f "$ENV_FILE" ]; then
  echo "==> Sourcing values from $ENV_FILE"
  set -a; . "$ENV_FILE"; set +a
fi

# --- map every env var already defined by another secret (for reuse) ---------
# Stored as newline-separated "var secret" lines (both are space-free). First
# definer wins.
echo "==> Scanning existing Semaphore secrets..."
PROVIDED_MAP=""
EXISTING_SECRETS=$(sem get secrets 2>/dev/null | awk 'NR>1 {print $1}' || true)
for s in $EXISTING_SECRETS; do
  [ "$s" = "$SECRET_NAME" ] && continue   # never reuse from the secret we manage
  names=$(sem get secret "$s" -o yaml 2>/dev/null \
    | awk '/^[[:space:]]*-[[:space:]]*name:/ {print $3}' || true)
  for n in $names; do
    if ! printf '%s' "$PROVIDED_MAP" | grep -q "^${n} "; then
      PROVIDED_MAP="${PROVIDED_MAP}${n} ${s}
"
    fi
  done
done

# echo the secret that provides $1, or empty
provided_by() {
  printf '%s' "$PROVIDED_MAP" | awk -v k="$1" '$1==k {print $2; exit}'
}

# --- verify the shared secrets exist; build the pipeline attach list ---------
ATTACH_LIST="$SECRET_NAME"
echo "==> Shared secrets (reused, never duplicated):"
for entry in "${SHARED_MARKERS[@]}"; do
  marker="${entry%%|*}"; desc="${entry#*|}"
  owner="$(provided_by "$marker")"
  if [ -n "$owner" ]; then
    echo "  $desc: '$owner' (defines $marker)"
    ATTACH_LIST="$ATTACH_LIST $owner"
  else
    echo "  $desc: MISSING — no secret defines $marker." >&2
    echo "    The deploy/promote jobs will fail until that shared secret exists." >&2
  fi
done

SECRET_EXISTS=0
if printf '%s\n' "$EXISTING_SECRETS" | grep -qx "$SECRET_NAME"; then
  SECRET_EXISTS=1
  echo "==> '$SECRET_NAME' already exists; it currently defines:"
  sem get secret "$SECRET_NAME" -o yaml 2>/dev/null \
    | awk '/^[[:space:]]*-[[:space:]]*name:/ {print "      - " $3}' || true
fi

# --- resolve the app-specific values: env -> reuse -> prompt -----------------
CREATE_ARGS=()
NEEDED_NAMES=()
echo "==> Resolving '$SECRET_NAME' values:"
for var in "${PLAIN_VARS[@]}"; do
  eval "cur=\"\${$var:-}\""
  owner="$(provided_by "$var")"
  if [ -n "$owner" ]; then
    echo "  $var: REUSE from existing secret '$owner' (not duplicated)"
    case " $ATTACH_LIST " in *" $owner "*) ;; *) ATTACH_LIST="$ATTACH_LIST $owner" ;; esac
    continue
  fi
  NEEDED_NAMES+=("$var")
  if [ -n "$cur" ]; then
    CREATE_ARGS+=( -e "$var=$cur" ); echo "  $var: from environment"; continue
  fi
  if [ "$PRINT_ONLY" -eq 1 ]; then echo "  $var: (would prompt)"; continue; fi
  read -r -p "  enter value for $var: " val
  CREATE_ARGS+=( -e "$var=$val" )
done

if [ "${#CREATE_ARGS[@]}" -eq 0 ]; then
  echo
  echo "Nothing to put in '$SECRET_NAME' — every required value is provided elsewhere."
  echo "Pipeline 'secrets:' for the deploy job: $ATTACH_LIST"
  exit 0
fi

if [ "$PRINT_ONLY" -eq 1 ]; then
  echo
  if [ "$SECRET_EXISTS" -eq 1 ]; then verb="REPLACE"; else verb="CREATE"; fi
  echo "Would $verb '$SECRET_NAME' with: ${NEEDED_NAMES[*]:-}"
  echo "Pipeline 'secrets:' for the deploy job: $ATTACH_LIST"
  exit 0
fi

# --- create or update --------------------------------------------------------
if [ "$SECRET_EXISTS" -eq 1 ]; then
  if [ "$FORCE" -eq 0 ] && [ -t 0 ]; then
    echo
    echo "About to REPLACE '$SECRET_NAME' with: ${NEEDED_NAMES[*]:-}"
    read -r -p "Proceed? [y/N] " ans
    case "$ans" in y|Y|yes|YES) ;; *) echo "Aborted."; exit 0 ;; esac
  fi
  echo "==> Replacing existing '$SECRET_NAME'..."
  sem delete secret "$SECRET_NAME" 2>/dev/null || true
else
  echo "==> Creating '$SECRET_NAME'..."
fi

sem create secret "$SECRET_NAME" "${CREATE_ARGS[@]}"

echo "==> Done. '$SECRET_NAME' now defines:"
sem get secret "$SECRET_NAME" -o yaml 2>/dev/null \
  | awk '/^[[:space:]]*-[[:space:]]*name:/ {print "      - " $3}' || sem get secrets "$SECRET_NAME"

echo
echo "Pipeline deploy job should attach:"
echo "        secrets:"
for s in $ATTACH_LIST; do echo "          - name: $s"; done
