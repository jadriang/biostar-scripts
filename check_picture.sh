#!/bin/bash
# ==========================================================
#  check_picture.sh
#  Checks a face image against BioStar's /api/users/check/upload_picture API
#  Usage: ./check_picture.sh <image_file>
#  Note: Requires $SESSION_ID to be set in your shell (via login.sh)
# ==========================================================

# --- Input argument ---
IMG_FILE="$1"

# --- Basic validation ---
if [[ -z "$IMG_FILE" ]]; then
    echo "Usage: $0 <image_file>"
    echo "Note: Make sure \$SESSION_ID is already set in your shell!"
    exit 1
fi

if [[ ! -f "$IMG_FILE" ]]; then
    echo "Error: File '$IMG_FILE' not found!"
    exit 1
fi

if [[ -z "$SESSION_ID" ]]; then
    echo "Error: SESSION_ID not set!"
    echo "Please log in first using:"
    echo '  source ./login.sh admin Pass.1234'
    exit 1
fi

# --- Build JSON payload ---
TMP_FILE=$(mktemp check_picture.XXXX.json)
echo "Building JSON request..."
echo -n "{\"template_ex_picture\": \"$(base64 -w 0 "$IMG_FILE")\"}" > "$TMP_FILE"

# --- Perform PUT request ---
echo "Checking picture '$IMG_FILE'..."
curl -k --location --request PUT "https://127.0.0.1/api/users/check/upload_picture" \
  --header "bs-session-id: $SESSION_ID" \
  --header "Content-Type: application/json" \
  --data @"$TMP_FILE" \
  | jq .   # Optional: pretty-print JSON if jq is installed

# --- Clean up ---
rm -f "$TMP_FILE"
echo -e "\nPicture check complete. Temporary file removed."
