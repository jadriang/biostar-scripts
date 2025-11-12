#!/bin/bash
# ==========================================================
#  login.sh
#  Logs in to BioStar 2 and retrieves a bs-session-id token.
#  Usage: ./login.sh <username> <password>
# ==========================================================

USERNAME="$1"
PASSWORD="$2"

if [[ -z "$USERNAME" || -z "$PASSWORD" ]]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

echo "Logging in as $USERNAME..."
RESPONSE=$(curl -sk --location "https://127.0.0.1/api/login" \
  --header "Content-Type: application/json" \
  --data "{\"User\":{\"login_id\":\"$USERNAME\",\"password\":\"$PASSWORD\"}}" \
  --include)

SESSION_ID=$(echo "$RESPONSE" | grep -i "bs-session-id:" | awk '{print $2}' | tr -d '\r')

if [[ -n "$SESSION_ID" ]]; then
    echo "Login successful."
    echo "Session ID: $SESSION_ID"
    export SESSION_ID
    echo "Session ID stored in environment (usable in this terminal)."
else
    echo "Login failed or session ID not found."
    echo "Raw response:"
    echo "$RESPONSE"
    exit 1
fi
