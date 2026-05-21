#!/usr/bin/env bash
# bulk_export_projects_docker.sh - Bulk export Dradis projects from a Docker deployment.
#
# Run this on the Docker host.
#
# Usage:
#   ./bulk_export_projects_docker.sh --output /tmp/dradis_exports [--ids 1,4,7]
#
# The script always targets the 'app' container. If yours is named differently,
# edit CONTAINER below.

set -euo pipefail

CONTAINER="app"
OUTPUT_DIR=""
IDS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)    OUTPUT_DIR="$2"; shift 2 ;;
    --ids)       IDS="$2";        shift 2 ;;
    --container) CONTAINER="$2";  shift 2 ;;
    *) echo "Unknown argument: $1"; exit 1 ;;
  esac
done

if [[ -z "$OUTPUT_DIR" ]]; then
  echo "Usage: $0 --output <dir> [--ids 1,2,3] [--container <name>]"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

# ---------------------------------------------------------------------------
# Fetch project list from the container
# ID and name separated by | to avoid clashing with colons in names.
# We write a small Ruby script to a tempfile inside the container so we don't
# have to fight shell quoting of the inline -e string.
# ---------------------------------------------------------------------------
TMPSCRIPT=$(mktemp /tmp/dradis_list_XXXXXX.rb)

if [[ -n "$IDS" ]]; then
  cat > "$TMPSCRIPT" <<RUBY
ids = [${IDS}]
Project.kept.where(id: ids).each { |p| puts "#{p.id}|#{p.name}" }
RUBY
else
  cat > "$TMPSCRIPT" <<RUBY
Project.kept.each { |p| puts "#{p.id}|#{p.name}" }
RUBY
fi

docker cp "$TMPSCRIPT" "${CONTAINER}:/tmp/dradis_list.rb"
rm -f "$TMPSCRIPT"

echo "Fetching project list from container '${CONTAINER}'..."
# Suppress the git warnings on stderr; only capture stdout
PROJECT_LIST=$(docker exec "$CONTAINER" \
  bash -c "RAILS_ENV=production bundle exec rails runner /tmp/dradis_list.rb" 2>/dev/null)

docker exec "$CONTAINER" rm -f /tmp/dradis_list.rb 2>/dev/null || true

if [[ -z "$PROJECT_LIST" ]]; then
  echo "No projects found."
  exit 1
fi

PROJECT_COUNT=$(echo "$PROJECT_LIST" | wc -l | tr -d ' ')
echo "Found ${PROJECT_COUNT} project(s). Starting export..."
echo ""

EXPORTED=()
FAILED=()

while IFS='|' read -r PROJECT_ID PROJECT_NAME; do
  [[ -z "$PROJECT_ID" ]] && continue

  SAFE_NAME=$(echo "$PROJECT_NAME" | tr -cs 'A-Za-z0-9_-' '_' | tr -s '_' | tr '[:upper:]' '[:lower:]' | sed 's/^_//;s/_$//')
  DEST_NAME="project_${PROJECT_ID}_${SAFE_NAME}.zip"
  DEST_PATH="${OUTPUT_DIR}/${DEST_NAME}"

  # Capture stdout+stderr; strip ANSI escape codes that docker exec can inject.
  THOR_OUTPUT=$(docker exec -e "PROJECT_ID=${PROJECT_ID}" "$CONTAINER" \
    bash -c "RAILS_ENV=production bundle exec thor dradis:plugins:projects:export:package" 2>&1 \
    | sed 's/\x1b\[[0-9;]*m//g')

  # The path appears on the line after "Project package created at:" (tab-indented).
  # grep -A1 grabs that next line, then we strip all whitespace to get the bare path.
  CONTAINER_PATH=$(echo "$THOR_OUTPUT" \
    | grep -A1 'Project package created at:' \
    | grep '\.zip' \
    | tr -d '[:space:]' \
    || true)

  if [[ -z "$CONTAINER_PATH" ]]; then
    echo "  [FAIL] project ${PROJECT_ID}: ${PROJECT_NAME}"
    echo "         (no export path in thor output; run manually to debug)"
    FAILED+=("${PROJECT_ID}: ${PROJECT_NAME}")
    continue
  fi

  if docker cp "${CONTAINER}:${CONTAINER_PATH}" "${DEST_PATH}" 2>/dev/null; then
    docker exec "$CONTAINER" rm -f "$CONTAINER_PATH" 2>/dev/null || true
    echo "  [OK]   project ${PROJECT_ID}: ${PROJECT_NAME}  ->  ${DEST_NAME}"
    EXPORTED+=("$DEST_PATH")
  else
    echo "  [FAIL] project ${PROJECT_ID}: ${PROJECT_NAME} (docker cp failed)"
    FAILED+=("${PROJECT_ID}: ${PROJECT_NAME}")
  fi

done <<< "$PROJECT_LIST"

# ---------------------------------------------------------------------------
# Bundle into one archive
# ---------------------------------------------------------------------------
if [[ ${#EXPORTED[@]} -gt 0 ]]; then
  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
  BUNDLE="${OUTPUT_DIR}/bulk_export_${TIMESTAMP}.zip"
  # zip wants bare filenames; cd into the output dir
  (cd "$OUTPUT_DIR" && zip -q "$BUNDLE" "${EXPORTED[@]##*/}")
  echo ""
  echo "Bundle: ${BUNDLE}"
fi

echo ""
echo "Done. ${#EXPORTED[@]} exported, ${#FAILED[@]} failed."
for f in "${FAILED[@]:-}"; do [[ -n "$f" ]] && echo "  FAILED: $f"; done

[[ ${#FAILED[@]} -eq 0 ]]
