#!/usr/bin/env zsh
# utils/untrunc.zsh - Repair corrupted MP4 files using untrunc (via Docker)
#
# untrunc uses a working reference file to fix a corrupted one with the same codec.
#
# Usage:
#   untrunc <reference.mp4> <corrupted.mp4> [options]
#   untrunc --build   Build/rebuild the Docker image
#
# Options:
#   -b, --build       Build or rebuild the untrunc Docker image
#   -h, --help        Show this help
#
# Examples:
#   cd ~/Videos/air65
#   untrunc 14-02-2026_005_air65.mp4 14-02-2026_007_air65.mp4
#   untrunc --build
#
# The repaired file is written to the current directory (fixed_<corrupted_name>).

untrunc() {
  local build=false
  local -a args

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -b|--build)
        build=true
        shift
        ;;
      -h|--help)
        cat << 'EOF'
untrunc - Repair corrupted MP4 files using untrunc (via Docker)

Usage:
  untrunc <reference.mp4> <corrupted.mp4> [options]
  untrunc --build   Build/rebuild the Docker image

Options:
  -b, --build   Build or rebuild the untrunc Docker image
  -h, --help    Show this help

The reference file should be a working MP4 from the same source/codec.
The corrupted file will be repaired; output is written as fixed_<corrupted_name>
in the current directory.

Requires Docker. Run from the folder containing your MP4 files.
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

  if [[ $build == true ]]; then
    echo "Building untrunc Docker image..."
    docker build -t untrunc:local - <<'DOCKERFILE'
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates build-essential pkg-config yasm \
    libavformat-dev libavcodec-dev libavutil-dev \
 && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/anthwlock/untrunc.git /opt/untrunc
WORKDIR /opt/untrunc
RUN make -j

ENTRYPOINT ["/opt/untrunc/untrunc"]
DOCKERFILE
    return $?
  fi

  if [[ ${#args[@]} -lt 2 ]]; then
    echo "Error: need reference and corrupted file" >&2
    echo "Usage: untrunc <reference.mp4> <corrupted.mp4>" >&2
    echo "       untrunc --build  to build the image first" >&2
    return 1
  fi

  local reference="$args[1]"
  local corrupted="$args[2]"

  if [[ ! -f "$reference" ]]; then
    echo "Error: reference file not found: $reference" >&2
    return 1
  fi
  if [[ ! -f "$corrupted" ]]; then
    echo "Error: corrupted file not found: $corrupted" >&2
    return 1
  fi

  if ! docker image inspect untrunc:local &>/dev/null; then
    echo "untrunc image not found. Run 'untrunc --build' first." >&2
    return 1
  fi

  echo "Repairing $corrupted using $reference as reference..."
  docker run -v "$PWD":/work -w /work untrunc:local "$reference" "$corrupted"
}
