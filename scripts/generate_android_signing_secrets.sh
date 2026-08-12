#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repository_root="$(cd "$script_dir/.." && pwd)"
output_dir="$repository_root/.secrets/android-signing"
upload_secrets=true
github_repository="https://github.com/mfalicoff/podpine"

usage() {
  cat <<'EOF'
Generate a persistent Android signing key and its GitHub Actions secret values.

Usage:
  scripts/generate_android_signing_secrets.sh [options]

Options:
  --output DIR          Output directory (default: .secrets/android-signing)
  --upload              Upload the generated values with the GitHub CLI
  --repository OWNER/REPO
                        Repository for --upload (defaults to the current repo)
  -h, --help            Show this help

The script refuses to overwrite an existing output directory. Keep the
generated directory in a secure backup: losing the keystore prevents future
APKs from updating existing direct installations.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)
      if [[ $# -lt 2 ]]; then
        echo "error: --output requires a directory" >&2
        exit 2
      fi
      output_dir="$2"
      shift 2
      ;;
    --upload)
      upload_secrets=true
      shift
      ;;
    --repository)
      if [[ $# -lt 2 ]]; then
        echo "error: --repository requires OWNER/REPO" >&2
        exit 2
      fi
      github_repository="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

for command_name in openssl base64 tr; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "error: required command is unavailable: $command_name" >&2
    exit 1
  fi
done

if [[ -e "$output_dir" ]]; then
  echo "error: refusing to overwrite existing output: $output_dir" >&2
  exit 1
fi

if [[ "$upload_secrets" == true ]] && ! command -v gh >/dev/null 2>&1; then
  echo "error: --upload requires the authenticated GitHub CLI (gh)" >&2
  exit 1
fi

working_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$working_dir"
}
trap cleanup EXIT

keystore_name="podpine-release.p12"
keystore_path="$working_dir/$keystore_name"
secrets_path="$working_dir/github-actions-secrets.env"
key_alias="podpine"
keystore_password="$(openssl rand -hex 32)"
key_password="$keystore_password"
private_key_path="$working_dir/private-key.pem"
certificate_path="$working_dir/certificate.pem"

umask 077
openssl req \
  -x509 \
  -newkey rsa:4096 \
  -sha256 \
  -days 10000 \
  -nodes \
  -subj "/CN=Podpine" \
  -keyout "$private_key_path" \
  -out "$certificate_path"
openssl pkcs12 \
  -export \
  -out "$keystore_path" \
  -inkey "$private_key_path" \
  -in "$certificate_path" \
  -name "$key_alias" \
  -passout "pass:$keystore_password"

keystore_base64="$(base64 < "$keystore_path" | tr -d '\r\n')"

{
  printf 'PODPINE_ANDROID_KEYSTORE_BASE64=%s\n' "$keystore_base64"
  printf 'PODPINE_ANDROID_KEYSTORE_PASSWORD=%s\n' "$keystore_password"
  printf 'PODPINE_ANDROID_KEY_ALIAS=%s\n' "$key_alias"
  printf 'PODPINE_ANDROID_KEY_PASSWORD=%s\n' "$key_password"
} > "$secrets_path"

openssl x509 \
  -in "$certificate_path" \
  -noout \
  -subject \
  -issuer \
  -dates \
  -fingerprint \
  -sha256 > "$working_dir/certificate-details.txt"
rm -f "$private_key_path" "$certificate_path"

chmod 600 "$keystore_path" "$secrets_path" "$working_dir/certificate-details.txt"
mkdir -p "$(dirname "$output_dir")"
mv "$working_dir" "$output_dir"
trap - EXIT

if [[ "$upload_secrets" == true ]]; then
  repository_arguments=()
  if [[ -n "$github_repository" ]]; then
    repository_arguments=(--repo "$github_repository")
  fi

  printf '%s' "$keystore_base64" |
    gh secret set PODPINE_ANDROID_KEYSTORE_BASE64 "${repository_arguments[@]}"
  printf '%s' "$keystore_password" |
    gh secret set PODPINE_ANDROID_KEYSTORE_PASSWORD "${repository_arguments[@]}"
  printf '%s' "$key_alias" |
    gh secret set PODPINE_ANDROID_KEY_ALIAS "${repository_arguments[@]}"
  printf '%s' "$key_password" |
    gh secret set PODPINE_ANDROID_KEY_PASSWORD "${repository_arguments[@]}"

  echo "Uploaded the four Android signing secrets to GitHub."
fi

echo "Generated persistent Android signing credentials in: $output_dir"
echo "Secret values are stored in: $output_dir/github-actions-secrets.env"
echo "Back up this directory securely before installing its first APK."
