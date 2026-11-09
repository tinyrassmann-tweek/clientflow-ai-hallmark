#!/usr/bin/env bash
# ClientFlow AI: owner-run Cloud Shell deployment from the locked 2026-11-09 build.
# No credentials are stored in this script or in GitHub.
set -Eeuo pipefail

fail() { printf '\nERROR: %s\n' "$*" >&2; exit 1; }
info() { printf '\n==> %s\n' "$*"; }
for tool in gcloud git unzip curl node npm; do
  command -v "$tool" >/dev/null 2>&1 || fail "Missing $tool in Cloud Shell."
done

CF_PROJECT="${CF_PROJECT:-clientflow-ai-v5}"
CF_OWNER_EMAIL="${CF_OWNER_EMAIL:-}"
CF_FIREBASE_API_KEY="${CF_FIREBASE_API_KEY:-}"
CF_REGION="${CF_REGION:-us-east1}"
CF_SERVICE_NAME="${CF_SERVICE_NAME:-}"

[ "$CF_PROJECT" = "clientflow-ai-v5" ] || fail "This launch is locked to project clientflow-ai-v5."
[ -n "$CF_OWNER_EMAIL" ] || read -r -p "Verified Firebase owner email: " CF_OWNER_EMAIL
if [ -z "$CF_FIREBASE_API_KEY" ]; then
  read -r -s -p "Firebase web API key (not an admin key): " CF_FIREBASE_API_KEY
  printf '\n'
fi
[ -n "$CF_PROJECT" ] || fail "Cloud project ID is required."
[ -n "$CF_OWNER_EMAIL" ] || fail "Firebase owner email is required."
[ -n "$CF_FIREBASE_API_KEY" ] || fail "Firebase web API key is required."
export CF_PROJECT CF_OWNER_EMAIL CF_FIREBASE_API_KEY CF_REGION

info "Checking authenticated Cloud Shell identity and existing project"
gcloud auth list --filter='status:ACTIVE' --format='value(account)'
gcloud projects describe "$CF_PROJECT" --format='value(projectId)' >/dev/null ||
  fail "Cannot access project $CF_PROJECT; check your Cloud Shell login."
gcloud config set project "$CF_PROJECT" >/dev/null

printf '\nProject: %s\nRegion: %s\nOwner: %s\n' "$CF_PROJECT" "$CF_REGION" "$CF_OWNER_EMAIL"
printf '%s\n' "Cloud Run, Firestore, Cloud Build and Secret Manager may incur charges."
read -r -p "Type DEPLOY to authorize billable cloud setup: " CONFIRM
[ "$CONFIRM" = "DEPLOY" ] || fail "Deployment cancelled before any provisioning."

info "Downloading the locked public source archive"
WORKDIR="$(mktemp -d)"
git clone --depth 1 --branch main   https://github.com/tinyrassmann-tweek/clientflow-ai-hallmark.git "$WORKDIR/repo"
[ "$(git -C "$WORKDIR/repo" rev-parse --short=7 HEAD)" = "55840dc" ] ||
  fail "The locked main commit has changed. Review the repository before deploying."
ARCHIVE="$WORKDIR/repo/deliverables/ClientFlow-AI-Complete-Build.zip"
[ -s "$ARCHIVE" ] || fail "Complete build ZIP missing."
mkdir -p "$WORKDIR/source"
unzip -q "$ARCHIVE" -d "$WORKDIR/source"
DEPLOY_SCRIPT="$(find "$WORKDIR/source" -type f -path '*/scripts/deploy-google.sh' -print -quit)"
[ -n "$DEPLOY_SCRIPT" ] || fail "deploy-google.sh is absent inside the archive."
APP_ROOT="$(dirname "$(dirname "$DEPLOY_SCRIPT")")"
for file in package.json Dockerfile src/core.mjs scripts/deploy-google.sh; do
  [ -f "$APP_ROOT/$file" ] || fail "Missing $file in extracted build."
done

info "Running source tests and build"
cd "$APP_ROOT"
node --version
npm test
npm run build

info "Running the repository's Google Cloud deployment script"
bash scripts/deploy-google.sh

info "Locating Cloud Run service"
gcloud run services list --region "$CF_REGION"   --format='table(metadata.name,status.url)'
if [ -z "$CF_SERVICE_NAME" ]; then
  CF_SERVICE_NAME="$(gcloud run services list --region "$CF_REGION"     --format='value(metadata.name)' | grep -i 'clientflow' | head -n 1 || true)"
fi
[ -n "$CF_SERVICE_NAME" ] || read -r -p "Cloud Run service name from the table above: " CF_SERVICE_NAME
[ -n "$CF_SERVICE_NAME" ] || fail "No service selected; deployment needs manual verification."
SERVICE_URL="$(gcloud run services describe "$CF_SERVICE_NAME"   --region "$CF_REGION" --format='value(status.url)')"
[ -n "$SERVICE_URL" ] || fail "Cloud Run has not returned a service URL."

info "Checking public landing and demo URLs"
for path in / '/app?demo=1'; do
  HTTP_CODE="$(curl -sS -L -o /dev/null -w '%{http_code}' "$SERVICE_URL$path")"
  printf '%s -> HTTP %s\n' "$SERVICE_URL$path" "$HTTP_CODE"
  [ "$HTTP_CODE" = 200 ] || fail "Unexpected HTTP status on $path. Investigate before launch."
done

info "Optional OpenAI secret binding"
if ! gcloud secrets describe OPENAI_API_KEY --project "$CF_PROJECT" >/dev/null 2>&1; then
  read -r -s -p "Paste OpenAI API key to create Secret Manager entry, or Enter to skip: " AI_KEY
  printf '\n'
  if [ -n "$AI_KEY" ]; then
    printf '%s' "$AI_KEY" | gcloud secrets create OPENAI_API_KEY       --project "$CF_PROJECT" --replication-policy=automatic --data-file=-
    unset AI_KEY
  fi
fi
if gcloud secrets describe OPENAI_API_KEY --project "$CF_PROJECT" >/dev/null 2>&1; then
  RUNTIME_SA="$(gcloud run services describe "$CF_SERVICE_NAME"     --region "$CF_REGION" --format='value(spec.template.spec.serviceAccountName)')"
  [ -n "$RUNTIME_SA" ] || fail "No explicit runtime service account. Configure a dedicated service account before secret binding."
  gcloud secrets add-iam-policy-binding OPENAI_API_KEY     --project "$CF_PROJECT" --member="serviceAccount:$RUNTIME_SA"     --role='roles/secretmanager.secretAccessor' >/dev/null
  gcloud run services update "$CF_SERVICE_NAME"     --project "$CF_PROJECT" --region "$CF_REGION"     --update-secrets='OPENAI_API_KEY=OPENAI_API_KEY:latest' >/dev/null
  info "Secret bound. Live AI output still requires a successful authenticated generation test."
else
  info "OpenAI key not supplied. Template drafting remains available; live AI is off."
fi

printf '\nCLOUD RUN HTTP SMOKE TEST PASSED\n%s\n' "$SERVICE_URL"
printf '%s\n' "Still required: Firebase email sign-in and authorized-domain tests;"
printf '%s\n' "Stripe signature-verified webhooks, entitlements and seat-enforcement tests;"
printf '%s\n' "a real AI draft test; custom-domain HTTPS and DNS checks."
printf '%s\n' "Do not claim paid-license activation based on Stripe links alone."
