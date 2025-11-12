#!/bin/bash
# ==========================================================
#  upload_attachment.sh
#  Uploads a file (e.g., CSV) to BioStar 2 via /api/attachments
#  Usage: ./upload_attachment.sh <file_path>
#  Note: Expects $SESSION_ID to be set in your terminal session
# ==========================================================

# --- Input argument ---
FILE_PATH="$1"

# --- Basic validation ---
if [[ -z "$FILE_PATH" ]]; then
    echo "Usage: $0 <file_path>"
    echo "Note: Make sure \$SESSION_ID is already set in your shell!"
    exit 1
fi

if [[ -z "$SESSION_ID" ]]; then
    echo "Error: SESSION_ID is not set!"
    echo "Please log in first, e.g.:"
    echo '  SESSION_ID=$(./biostar_login.sh admin Pass.1234 | grep "Session ID" | awk "{print \$3}")'
    exit 1
fi

if [[ ! -f "$FILE_PATH" ]]; then
    echo "Error: File '$FILE_PATH' not found!"
    exit 1
fi

# --- Perform file upload ---
echo "Uploading '$FILE_PATH' to BioStar attachments API..."
curl -k --location "https://127.0.0.1/api/attachments" \
  --header "bs-session-id: $SESSION_ID" \
  --form "file=@\"$FILE_PATH\""

echo -e "\nUpload complete."
