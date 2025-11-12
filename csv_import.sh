#!/bin/bash
# ==========================================================
#  csv_import.sh
#  Imports users from a CSV file to BioStar 2 via /api/users/csv_import
#  Usage: ./csv_import.sh <csv_file>
#  Note: Requires $SESSION_ID to be set in your shell (via login.sh)
# ==========================================================

# --- Input argument ---
CSV_FILE="$1"

# --- Basic validation ---
if [[ -z "$CSV_FILE" ]]; then
    echo "Usage: $0 <csv_file>"
    echo "Note: Make sure \$SESSION_ID is already set in your shell!"
    exit 1
fi

if [[ ! -f "$CSV_FILE" ]]; then
    echo "Error: File '$CSV_FILE' not found!"
    exit 1
fi

if [[ -z "$SESSION_ID" ]]; then
    echo "Error: SESSION_ID not set!"
    echo "Please log in first using:"
    echo '  source ./login.sh admin Pass.1234'
    exit 1
fi

# --- Create temporary JSON body ---
TMP_FILE=$(mktemp csv_import.XXXX.json)
CSV_NAME=$(basename "$CSV_FILE")

echo "Building JSON body..."
cat > "$TMP_FILE" <<EOF
{
    "File": {
        "uri": "$CSV_NAME",
        "fileName": "$CSV_NAME"
    },
    "CsvOption": {
        "start_line": 2,
        "import_option": 1
    },
    "Query": {
        "headers": [
            "user_id",
            "name",
            "department",
            "user_title",
            "phone",
            "email",
            "user_group",
            "start_datetime",
            "expiry_datetime",
            "csn",
            "",
            "",
            "",
            "qr",
            "26 bit SIA Standard-H10301",
            "HID 37 bit-H10302",
            "",
            "",
            "",
            "Purpose",
            "License Plate Number",
            "Hello",
            "Hair Color",
            "Hair Color 2",
            "",
            "",
            ""
        ],
        "columns": [
            "user_id",
            "name",
            "department",
            "user_title",
            "phone",
            "email",
            "user_group",
            "start_datetime",
            "expiry_datetime",
            "csn",
            "mobile_start_datetime",
            "mobile_expiry_datetime",
            "csn_mobile",
            "qr",
            "26 bit SIA Standard-H10301",
            "HID 37 bit-H10302",
            "HID 37 bit-H10304",
            "HID Corporate 1000",
            "HID Corporate 1000 48bit",
            "Purpose",
            "License Plate Number",
            "Hello",
            "Hair Color",
            "Hair Color 2",
            "face_image_file1",
            "face_image_file2",
            "pin"
        ]
    }
}
EOF

# --- Perform API request ---
echo "Importing CSV '$CSV_FILE' to BioStar..."
curl -k --location --request POST "https://127.0.0.1/api/users/csv_import" \
  --header "bs-session-id: $SESSION_ID" \
  --header "Content-Type: application/json" \
  --data @"$TMP_FILE"

# --- Clean up ---
rm -f "$TMP_FILE"
echo -e "\nCSV import complete. Temporary file removed."
