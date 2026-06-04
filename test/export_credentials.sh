#!/bin/bash
# Exports temporary AWS credentials to a JSON file for Postman.
# Usage: ./export_credentials.sh [profile-name]
# Requires an active AWS SSO session.

PROFILE="${1:-default}"
OUTPUT_FILE="credentials.json"

echo "Exporting credentials for profile: $PROFILE"
aws configure export-credentials --profile "$PROFILE" --format process | \
  python3 -c "
import sys, json
creds = json.load(sys.stdin)
postman_vars = {
    'aws_access_key_id': creds['AccessKeyId'],
    'aws_secret_access_key': creds['SecretAccessKey'],
    'aws_session_token': creds['SessionToken'],
    'expires': creds['Expiration']
}
print(json.dumps(postman_vars, indent=2))
" > "$OUTPUT_FILE"

echo "Credentials saved to $OUTPUT_FILE"
echo "Expires: $(python3 -c "import json; print(json.load(open('$OUTPUT_FILE'))['expires'])")"
echo ""
echo "Copy these values to your Postman environment variables:"
cat "$OUTPUT_FILE"
