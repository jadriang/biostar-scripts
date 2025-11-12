#!/bin/bash
# ==========================================================
#  upload_face.sh
#  Uploads a user's face image (Base64) to BioStar via PUT
#  Usage: ./upload_face.sh <image_file> <user_id>
#  Note: Expects $SESSION_ID to be set in the terminal session
# ==========================================================

IMG_FILE="$1"
USER_ID="$2"

# --- Basic validation ---
if [[ -z "$IMG_FILE" || -z "$USER_ID" ]]; then
    echo "Usage: $0 <image_file> <user_id>"
    echo "Note: Make sure \$SESSION_ID is already set in your shell!"
    exit 1
fi

if [[ -z "$SESSION_ID" ]]; then
    echo "Error: SESSION_ID is not set!"
    echo "Please log in first, e.g.:"
    echo '  SESSION_ID=$(./biostar_login.sh admin Pass.1234 | grep "Session ID" | awk "{print \$3}")'
    exit 1
fi

if [[ ! -f "$IMG_FILE" ]]; then
    echo "Error: File '$IMG_FILE' not found!"
    exit 1
fi

# --- Create temporary JSON file ---
TMP_FILE=$(mktemp body.XXXX.json)

echo "Building JSON body..."
echo -n '{
    "User": {
        "credentials": {
            "visualFaces": [
                {
                    "template_ex_normalized_image": "'$(base64 -w 0 "$IMG_FILE")'",
                    "templates": [
                        {
                            "credential_bin_type": "5",
                            "template_ex": "AAABAAEAKgHyAaUA1wBj8vP2XEpVQSt0dQAA..."
                        },
                        {
                            "credential_bin_type": "9",
                            "template_ex": "AAABAAEAVgHZAa8A4wAAAAAAWFVLREUAAA..."
                        }
                    ]
                }
            ]
        }
    }
}' > "$TMP_FILE"
# echo -n '{
#     "User": {
#         "credentials": {
#             "visualFaces": [
#                 {
#                     "template_ex_normalized_image": "'$(base64 -w 0 "$IMG_FILE")'",
#                     "templates": [
#                         {
#                             "credential_bin_type": "5",
#                             "template_ex": "AAABAAEAKgHyAaUA1wBj8vP2XEpVQSt0dQAA..."
#                         },
#                         {
#                             "credential_bin_type": "9",
#                             "template_ex": "AAABAAEAVgHZAa8A4wAAAAAAWFVLREUAAA..."
#                         }
#                     ]
#                 },
#                 {
#                     "template_ex_normalized_image": "'$(base64 -w 0 "$IMG_FILE")'",
#                     "templates": [
#                         {
#                             "credential_bin_type": "5",
#                             "template_ex": "AAABAAEAgwFoAbgA6gBl8vryXUdWNip7hwA..."
#                         }
#                     ]
#                 }
#             ]
#         }
#     }
# }' > "$TMP_FILE"

# --- Perform PUT request ---
echo "Uploading face image for BioStar user ID: $USER_ID ..."
curl --location --request PUT "https://127.0.0.1/api/users/$USER_ID" \
  --header "bs-session-id: $SESSION_ID" \
  --header "Content-Type: application/json" \
  --data @"$TMP_FILE" \
  --insecure

# --- Clean up ---
rm -f "$TMP_FILE"
echo -e "\nDone. Temporary file removed."
