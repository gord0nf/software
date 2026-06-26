#!/bin/bash

install_dir=$1
FORCE="${FORCE:-false}"

THING=ytdlp
source "$(dirname "${BASH_SOURCE[0]}")/../../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

get_download_url() {
  local ext=
  case "$(get_os)" in
  mac) ext=_macos ;;
  linux) ;;
  windows) ext=.exe ;;
  *) fatal 'os not supported' ;;
  esac

  echo "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp$ext"
}

binary="$install_dir/yt-dlp"

if ! $FORCE && command_exists yt-dlp; then
  log 'already installed'
elif ! $FORCE && check_executable "$binary"; then
  log 'already installed, just not registered'
  log 'registering'
  register "$binary"
else
  log 'downloading'
  url=$(get_download_url)
  tmp=$(download "$url") || fatal 'download failed'

  mkdir -p "$install_dir"
  mv "$tmp" "$binary"
  chmod +x "$binary"
  [[ "$tmp" == *.exe ]] && mv "$binary" "$binary.exe"
  rm -f "$tmp"

  register "$binary"
fi
