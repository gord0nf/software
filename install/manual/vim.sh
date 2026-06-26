#!/bin/bash

install_dir=$1
FORCE="${FORCE:-false}"

THING=vim
source "$(dirname "${BASH_SOURCE[0]}")/../../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

get_windows_version() {
  get_latest_github_tag 'vim/vim-win32-installer'
}

get_windows_download_url() {
  local tag=$1
  local arch=
  case $(get_arch) in
  amd/x64) arch=x64 ;;
  x32) arch=x86 ;;
  *) fatal 'arch not supported' ;;
  esac
  echo "https://github.com/vim/vim-win32-installer/releases/download/$tag/gvim_${tag:1}_$arch.zip"
}

binary="$install_dir/vim"

if ! $FORCE && command_exists vim; then
  log 'already installed'
elif ! $FORCE && check_executable "$binary"; then
  log 'already installed, just not registered'
  log 'registering'
  register "$binary"
else
  case $(get_os) in
  windows)
    log 'getting version'
    version=$(get_windows_version)

    log 'installing'
    url=$(get_windows_download_url "$version")
    atomic_download_and_extract "$url" "$install_dir" '' || fatal 'install failed'
    register "$binary"
    ;;

  linux) # TODO: actually test this... or find somewhere reliable that has the binaries!
    for dep in git make; do
      command_exists $dep || fatal "requires $dep, but not found"
    done
    mkdir -p "$install_dir" && cd "$install_dir"
    git clone https://github.com/vim/vim.git
    cd vim/src
    make
    register "$install_dir/some/path/after/making/vim"
    ;;

  mac) fatal 'mac not supported yet' ;;
  esac
fi
