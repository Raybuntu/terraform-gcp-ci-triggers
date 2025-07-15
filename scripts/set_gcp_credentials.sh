export GOOGLE_APPLICATION_CREDENTIALS=$(mktemp /tmp/creds-XXXXXX.json)
pass show gcp-infra/deployment-account-key.json > "$GOOGLE_APPLICATION_CREDENTIALS"
chmod 600 "$GOOGLE_APPLICATION_CREDENTIALS"
trap 'rm -f "$GOOGLE_APPLICATION_CREDENTIALS"' EXIT
echo "Temporary credentials stored in: $GOOGLE_APPLICATION_CREDENTIALS"
