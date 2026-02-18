#!/usr/bin/env zsh
# utils/mp4-metadata-fixed.zsh - Copy metadata from original to untrunc fixed MP4 files
#
# For fixed_*.mp4 or *_fixed.mp4 files, copies creation date and timestamps from the
# corresponding original file. Does not rename or delete anything.
#
# Usage:
#   mp4-metadata-fixed <folder> [options]
#
# Options:
#   -n, --dry-run   Show what would be done without making changes
#   -v, --verbose   Debug logs (folder, glob matches, paths)
#   -h, --help      Show this help
#
# Examples:
#   mp4-metadata-fixed ~/Videos/air65
#   mp4-metadata-fixed ~/Videos/air65 -n

mp4-metadata-fixed() {
  local folder dry_run=false verbose=false
  local -a args

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n|--dry-run)
        dry_run=true
        shift
        ;;
      -v|--verbose)
        verbose=true
        shift
        ;;
      -h|--help)
        cat << 'EOF'
mp4-metadata-fixed - Copy metadata from original to untrunc fixed MP4 files

Usage:
  mp4-metadata-fixed <folder> [options]

Options:
  -n, --dry-run   Show what would be done without making changes
  -v, --verbose   Debug logs (folder, glob matches, paths)
  -h, --help      Show this help

For fixed_*.mp4 or *_fixed.mp4 files, copies creation date and timestamps
from the corresponding original. Does not rename or delete anything.
EOF
        return 0
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

  folder="${args[1]:-}"
  if [[ -z "$folder" ]]; then
    echo "Error: folder path required" >&2
    echo "Usage: mp4-metadata-fixed <folder> [options]" >&2
    return 1
  fi

  if [[ ! -d "$folder" ]]; then
    echo "Error: folder does not exist: $folder" >&2
    return 1
  fi

  folder="$(cd "$folder" && pwd)"
  [[ $verbose == true ]] && echo "[DEBUG] folder: $folder" >&2

  local fixed_file original found=0
  local -a fixed_files
  fixed_files=("$folder"/fixed_*.mp4(N) "$folder"/*_fixed.mp4(N))
  [[ $verbose == true ]] && echo "[DEBUG] glob matches (${#fixed_files[@]}): ${fixed_files[*]}" >&2

  for fixed_file in $fixed_files; do
    [[ ! -f "$fixed_file" ]] && { [[ $verbose == true ]] && echo "[DEBUG] skip (not file): $fixed_file" >&2; continue }
    found=1
    if [[ "$fixed_file" == */fixed_*.mp4 ]]; then
      original="$folder/${${fixed_file:t}#fixed_}"
      [[ $verbose == true ]] && echo "[DEBUG] pattern fixed_*: original=$original" >&2
    else
      original="$folder/${${fixed_file:t}%_fixed.mp4}"
      [[ $verbose == true ]] && echo "[DEBUG] pattern *_fixed: original=$original" >&2
    fi
    [[ $verbose == true ]] && echo "[DEBUG] original exists: $([[ -f "$original" ]] && echo yes || echo no)" >&2
    if [[ -f "$original" ]]; then
      if [[ $dry_run == true ]]; then
        echo "Would copy metadata: $(basename "$original") -> $(basename "$fixed_file")"
      else
        touch -r "$original" "$fixed_file" 2>/dev/null
        if command -v SetFile &>/dev/null; then
          local date_str setfile_date
          date_str=$(stat -f "%SB" "$original" 2>/dev/null)
          if [[ -n "$date_str" ]]; then
            setfile_date=$(date -j -f "%b %d %H:%M:%S %Y" "$date_str" "+%m/%d/%Y %H:%M:%S" 2>/dev/null)
            [[ -n "$setfile_date" ]] && SetFile -d "$setfile_date" "$fixed_file" 2>/dev/null
          fi
        fi
        echo "Copied metadata: $(basename "$original") -> $(basename "$fixed_file")"
      fi
    else
      echo "Original not found for $(basename "$fixed_file"): $(basename "$original")" >&2
    fi
  done

  [[ $found -eq 0 ]] && echo "No fixed files found (looking for fixed_*.mp4 or *_fixed.mp4)" >&2
  return 0
}
