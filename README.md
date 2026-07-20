# BioStar 2 API Scripts

A collection of Bash scripts for interacting with the [Suprema BioStar 2](https://bs2api.biostar2.com/) REST API: logging in, importing users from CSV, uploading face images, uploading generic attachments, and checking face images against BioStar's face-detection endpoint.

## Prerequisites

- `curl`
- `jq` (optional — used by `check_picture.sh` to pretty-print the response)
- Network access to a BioStar 2 server. All scripts target `https://127.0.0.1` and use `curl -k`/`--insecure` to accept the server's self-signed certificate. Edit the URL in each script if your BioStar 2 instance runs elsewhere.

Make the scripts executable:

```bash
chmod +x login.sh csv_import.sh upload_attachment.sh upload_face.sh check_picture.sh
```

## Authentication

Every script except `login.sh` requires a `SESSION_ID` environment variable. Get one by sourcing `login.sh` (sourcing, not just running, is what exports `SESSION_ID` into your current shell):

```bash
source ./login.sh admin Pass.1234
echo $SESSION_ID
```

The session ID stays valid for the life of the shell/session it was issued in. If a script reports `SESSION_ID not set!` or `SESSION_ID is not set!`, re-run the `source` command above.

## Scripts

### `login.sh`

Logs in to BioStar 2 and exports the resulting `bs-session-id` as `SESSION_ID`.

```bash
source ./login.sh <username> <password>
```

### `upload_attachment.sh`

Uploads a file (e.g. a CSV) to BioStar's `/api/attachments` endpoint. Do this before `csv_import.sh` so the CSV exists on the server under the name it expects.

```bash
./upload_attachment.sh <file_path>
```

### `csv_import.sh`

Imports users from a CSV file via `/api/users/csv_import`. The CSV must already be uploaded (see `upload_attachment.sh`) with the same filename passed here, since the request references the file by name rather than uploading its contents directly.

```bash
./csv_import.sh <csv_file>
```

### `upload_face.sh`

Uploads a user's face image (base64-encoded) via a `PUT` to `/api/users/<user_id>`, setting it as the user's visual face credential.

```bash
./upload_face.sh <image_file> <user_id>
```

### `check_picture.sh`

Sends a face image (base64-encoded) to `/api/users/check/upload_picture` to validate that BioStar can detect a face in it, without attaching it to a user. Pretty-prints the JSON response via `jq` if installed.

```bash
./check_picture.sh <image_file>
```

## CSV format

`csv_import.sh` imports CSVs with the following columns (see `sample.csv` and `sample2.csv`):

```
user_id,name,phone,email,user_group,start_datetime,expiry_datetime,csn,access_on_card,csn_mobile,face_image_file1,face_image_file2
```

The full set of columns BioStar recognizes (used internally by `csv_import.sh` to build the import request) also includes `department`, `user_title`, `qr`, card-format fields (`26 bit SIA Standard-H10301`, `HID 37 bit-H10302`, etc.), `Purpose`, `License Plate Number`, and `pin`. Any column not present in your CSV can simply be omitted.

## Example workflow

```bash
source ./login.sh admin Pass.1234
echo $SESSION_ID

./upload_attachment.sh users.csv
./csv_import.sh users.csv

./upload_face.sh Jack1.png 102
./check_picture.sh Jack1.png
```

## Support links

- https://bs2api.biostar2.com/
- https://support.supremainc.com/en/support/solutions/articles/24000094390--biostar-2-api-how-to-import-user-data-from-csv
- https://support.supremainc.com/en/support/solutions/articles/24000060688--biostar-2-supports-batch-registration-of-visual-face-using-csv-import
