#!/usr/bin/env zsh
# utils/ts2mp4.zsh - Convert TS (MPEG Transport Stream) files to MP4 using ffmpeg
#
# Usage:
#   ts2mp4 <folder> [options]     Convert all .ts files in folder
#   ts2mp4 <file.ts> [options]   Convert single file
#
# Options:
#   -n, --dry-run   Show what would be done without making changes
#   -d, --delete    Delete .ts file after successful conversion
#   -f, --fast      Fast remux only (-c copy), no re-encode (may not play in QuickTime)
#   -h, --help      Show this help
#
# Default: re-encodes to H.264 + AAC for QuickTime compatibility.
#
# Examples:
#   ts2mp4 ~/Videos/air65
#   ts2mp4 ~/Videos/air65/recording.ts -d
#   ts2mp4 ~/Videos/air65 -f          # fast copy (if source is already H.264/AAC)

ts2mp4() {
  local dry_run=false delete_ts=false fast_copy=false
  local -a args

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n|--dry-run)
        dry_run=true
        shift
        ;;
      -d|--delete)
        delete_ts=true
        shift
        ;;
      -f|--fast)
        fast_copy=true
        shift
        ;;
      -h|--help)
        cat << 'EOF'
ts2mp4 - Convert TS files to MP4 using ffmpeg

Usage:
  ts2mp4 <folder> [options]     Convert all .ts files in folder
  ts2mp4 <file.ts> [options]    Convert single file

Options:
  -n, --dry-run   Show what would be done without making changes
  -d, --delete    Delete .ts file after successful conversion
  -f, --fast      Fast remux only (-c copy), no re-encode (may not play in QuickTime)
  -h, --help      Show this help

Default: re-encodes to H.264 + AAC for QuickTime compatibility.
Requires ffmpeg.
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

  if [[ ${#args[@]} -lt 1 ]]; then
    echo "Error: folder or file required" >&2
    echo "Usage: ts2mp4 <folder|file.ts> [options]" >&2
    return 1
  fi

  if ! command -v ffmpeg &>/dev/null; then
    echo "Error: ffmpeg not found" >&2
    return 1
  fi

  local target="${args[1]}"
  local -a ts_files

  if [[ -d "$target" ]]; then
    ts_files=("$target"/*.ts(N))
  elif [[ -f "$target" && "$target" == *.ts ]]; then
    ts_files=("$target")
  else
    echo "Error: not a folder or .ts file: $target" >&2
    return 1
  fi

  if [[ ${#ts_files[@]} -eq 0 ]]; then
    echo "No .ts files found"
    return 0
  fi

  local ts_file out_file
  for ts_file in $ts_files; do
    out_file="${ts_file:r}.mp4"

    if [[ -e "$out_file" && "$ts_file" != "$out_file" ]]; then
      echo "Skipping $(basename "$ts_file"): $(basename "$out_file") already exists" >&2
      continue
    fi

    if [[ $dry_run == true ]]; then
      echo "Would convert: $(basename "$ts_file") -> $(basename "$out_file")"
      [[ $delete_ts == true ]] && echo "  (and delete .ts)"
    else
      local ff_cmd
      if [[ $fast_copy == true ]]; then
        ff_cmd=(ffmpeg -y -i "$ts_file" -c copy "$out_file")
      else
        ff_cmd=(ffmpeg -y -i "$ts_file" -c:v libx264 -preset medium -crf 23 -c:a aac -b:a 128k -movflags +faststart "$out_file")
      fi
      if "$ff_cmd[@]"; then
        echo "Converted: $(basename "$ts_file") -> $(basename "$out_file")"
        [[ $delete_ts == true ]] && rm "$ts_file" && echo "  Deleted: $(basename "$ts_file")"
      else
        echo "Failed: $(basename "$ts_file")" >&2
      fi
    fi
  done

  return 0
}
