#!/bin/bash

config_dir=$1
install_dir=$2
force=false
if [[ "$3" == '--force' ]]; then
  force=true
fi

THING=neovim
UTILS="$(dirname "${BASH_SOURCE[0]}")/../utils.sh"
if ! source "$UTILS"; then
  echo "fatal: couldn't source $UTILS" >&2
  exit 1
fi

get_download_url() {
  local version=$1
  local os=
  local arch=
  local ext=
  case "$(get_os)" in
  windows)
    os=win
    ext=zip
    ;;
  mac)
    os=macos
    ext=tar.gz
    ;;
  linux)
    os=linux
    ext=tar.gz
    ;;
  esac
  case "$(get_arch)" in
  arm) arch=-arm64 ;;
  *)
    if [[ $os == win ]]; then
      arch=64
    else
      arch=-x86_64
    fi
    ;;
  esac

  echo "https://github.com/neovim/neovim/releases/download/$version/nvim-$os$arch.$ext"
}

install_win32_make() {
  local install_dir=$1
  local url='https://sourceforge.net/projects/gnuwin32/files/make/3.81/make-3.81-bin.zip/download'
  local tmpdir=$(mktemp -d)

  download_and_extract "$url" "$tmpdir" zip || return 1
  mv "$tmpdir/bin"/* "$install_dir"
  rm -fr "$tmpdir"
}

configure() {
  local default_nvim_dirs=(
    "$HOME/.config/nvim"
    "$HOME/AppData/Local/nvim"
  )

  # create link from default nvim dir(s) to config
  for nvim_dir in "${default_nvim_dirs[@]}"; do
    if [[ -d "$(dirname "$nvim_dir")" ]]; then
      log "creating directory link from '$nvim_dir' to config"
      make_directory_link "$config_dir" "$nvim_dir" $force
    fi
  done
}

if ! $force && command_exists nvim; then
  log 'already installed'
else
  log 'getting version'
  version=$(get_latest_github_tag 'neovim/neovim')
  url=$(get_download_url "$version")

  log 'installing'
  atomic_download_and_extract "$url" "$install_dir" '' $force || fatal 'install failed'
  register neovim "$version" "$install_dir/bin"
fi

# since some neovim stuff needs make, so if on windows, get it
if [[ $(get_os) == "windows" ]] && ! command_exists make; then
  log 'installing win32 make'
  install_win32_make "$install_dir/bin" ||
    warn "win32 make install failed (it's not really required tho, it's just that some plugins need it)"
fi

configure
