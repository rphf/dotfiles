#!/usr/bin/env zsh
# utils/mp4-rename.zsh - Rename MP4 and TS video files to DD-MM-YYYY_NNN_SLUG format based on creation date
#
# Usage:
#   mp4rename <folder> [slug] [options]
#   mp4rename <folder> [options] [--] [slug]
#
# Options:
#   -d, --delete-images   Delete .jpg, .jpeg, .png files in the folder
#   -n, --dry-run        Show what would be done without making changes
#   -h, --help           Show this help
#
# Examples:
#   mp4rename ~/Videos/air65                    # slug defaults to "air65"
#   mp4rename ~/Videos/air65 vacation           # custom slug "vacation"
#   mp4rename ~/Videos/air65 -d                 # also delete images
#   mp4rename ~/Videos/air65 -n vacation        # dry-run with custom slug

mp4rename() {
  local folder slug delete_images=false dry_run=false
  local -a args

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--delete-images)
        delete_images=true
        shift
        ;;
      -n|--dry-run)
        dry_run=true
        shift
        ;;
      -h|--help)
        cat << 'EOF'
mp4rename - Rename MP4 and TS video files to DD-MM-YYYY_NNN_SLUG format

Usage:
  mp4rename <folder> [slug] [options]
  mp4rename <folder> [options] [--] [slug]

Options:
  -d, --delete-images   Delete .jpg, .jpeg, .png files in the folder
  -n, --dry-run         Show what would be done without making changes
  -h, --help            Show this help

The format is: DD-MM-YYYY_NNN_SLUG.<ext>  (.mp4 or .ts)
  - DD-MM-YYYY: creation date from file metadata (or filesystem)
  - NNN: 3-digit counter (001, 002...) for files with same date
  - SLUG: custom string or parent folder name

Examples:
  mp4rename ~/Videos/air65
  mp4rename ~/Videos/air65 vacation -d
  mp4rename ~/Videos/air65 -n
EOF
        return 0
        ;;
      --)
        shift
        args+=("$@")
        break
        ;;
      -*)
        echo "Unknown option: $1" >&2
        return 1
        ;;
      *)
        args+=("$1")
        shift
        ;;
    esac
  done

  # First arg is folder, second (optional) is slug
  if [[ ${#args[@]} -lt 1 ]]; then
    echo "Error: folder path required" >&2
    echo "Usage: mp4rename <folder> [slug] [options]" >&2
    return 1
  fi

  folder="${args[1]}"
  slug="${args[2]:-}"

  # Resolve to absolute path and validate
  if [[ ! -d "$folder" ]]; then
    echo "Error: folder does not exist: $folder" >&2
    return 1
  fi

  folder="$(cd "$folder" && pwd)"
  [[ -z "$slug" ]] && slug="${folder:t}"

  # Sanitize slug: replace spaces and special chars with hyphens
  slug="${slug//[^a-zA-Z0-9._-]/_}"

  # Get creation date from a file (prefer exiftool for media metadata, fallback to stat)
  _mp4rename_get_date() {
    local file="$1"
    local date_str

    if command -v exiftool &>/dev/null; then
      date_str=$(exiftool -CreateDate -d "%Y-%m-%d" -s3 "$file" 2>/dev/null)
      if [[ -n "$date_str" ]]; then
        # exiftool returns YYYY-MM-DD
        echo "${date_str}" | awk -F'-' '{printf "%02d-%02d-%04d", $3, $2, $1}'
        return
      fi
    fi

    # Fallback: macOS stat birth time
    if [[ "$(uname)" == "Darwin" ]]; then
      date_str=$(stat -f "%SB" "$file" 2>/dev/null)
      if [[ -n "$date_str" ]]; then
        date -j -f "%b %d %H:%M:%S %Y" "$date_str" "+%d-%m-%Y" 2>/dev/null
      fi
    else
      # Linux: stat --format=%w (birth time, may not be supported on all filesystems)
      date_str=$(stat -c "%w" "$file" 2>/dev/null)
      [[ -n "$date_str" ]] && date -d "$date_str" "+%d-%m-%Y" 2>/dev/null
    fi
  }

  # Collect .mp4 and .ts video files with their creation date and birth timestamp
  local -a video_files
  local -A file_dates
  local f date_key ts

  for f in "$folder"/*.mp4(N) "$folder"/*.ts(N); do
    date_key=$(_mp4rename_get_date "$f")
    [[ -z "$date_key" ]] && date_key="00-00-0000"
    file_dates[$f]="$date_key"
    video_files+=("$f")
  done

  if [[ ${#video_files[@]} -eq 0 ]]; then
    echo "No .mp4 or .ts video files found in $folder"
    return 0
  fi

  # Sort by creation timestamp (birth time) for deterministic order
  local -a with_ts
  for f in $video_files; do
    if [[ "$(uname)" == "Darwin" ]]; then
      ts=$(stat -f "%B" "$f" 2>/dev/null || echo 0)
    else
      ts=$(stat -c "%W" "$f" 2>/dev/null || stat -c "%Y" "$f" 2>/dev/null || echo 0)
    fi
    with_ts+=("${ts}_${f}")
  done
  with_ts=(${(o)with_ts})
  video_files=()
  for w in $with_ts; do
    video_files+=("${w#*_}")
  done

  # Build date -> count map for NNN
  local -A date_count
  local -a renames
  local new_name date_part num ext

  for f in $video_files; do
    date_part="${file_dates[$f]:-}"
    [[ -z "$date_part" ]] && date_part="00-00-0000"
    date_count[$date_part]=$((${date_count[$date_part]:-0} + 1))
    num=$date_count[$date_part]
    ext="${f:e}"
    new_name="${date_part}_$(printf "%03d" $num)_${slug}.${ext}"
    new_name="$folder/$new_name"

    if [[ "$f" != "$new_name" ]]; then
      renames+=("$f|$new_name")
    fi
  done

  # Perform renames
  if [[ $dry_run == true ]]; then
    echo "Dry run - would rename:"
    for r in $renames; do
      local old="${r%%|*}" new="${r#*|}"
      echo "  $(basename "$old") -> $(basename "$new")"
    done
  else
    for r in $renames; do
      local old="${r%%|*}" new="${r#*|}"
      if [[ -e "$new" && "$old" != "$new" ]]; then
        echo "Warning: target exists, skipping: $(basename "$new")" >&2
      else
        mv "$old" "$new" && echo "Renamed: $(basename "$old") -> $(basename "$new")"
      fi
    done
  fi

  # Optionally delete images
  if [[ $delete_images == true ]]; then
    local -a images
    for f in "$folder"/*.jpg(N) "$folder"/*.jpeg(N) "$folder"/*.png(N); do
      images+=("$f")
    done
    if [[ ${#images[@]} -gt 0 ]]; then
      if [[ $dry_run == true ]]; then
        echo "Dry run - would delete:"
        for img in $images; do
          echo "  $(basename "$img")"
        done
      else
        for img in $images; do
          rm "$img" && echo "Deleted: $(basename "$img")"
        done
      fi
    fi
  fi

  return 0
}
