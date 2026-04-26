SOFTWARE_SRC=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# alias for register.sh
REGISTER_SH="$SOFTWARE_SRC/register.sh"
if ! [[ -f "$REGISTER_SH" ]]; then
  echo "fatal: no script at $REGISTER_SH"
  exit 1
fi
register() { "$REGISTER_SH" "$@"; }

# logging functions
. "$SOFTWARE_SRC/log.sh"

# returns 'windows' | 'linux' | 'mac'
get_os() {
  if grep -qEi "(Microsoft|WSL|MSYS)" /proc/version &>/dev/null; then
    echo windows
  else
    case "$OSTYPE" in
    darwin*) echo mac ;;
    solaris* | linux* | bsd* | freebsd*) echo linux ;;
    msys* | cygwin* | win32*) echo windows ;;
    *)
      echo 'could not determine os. please define OSTYPE' >&2
      exit 1
      ;;
    esac
  fi
}

# returns 'amd/x64' | 'x32' | 'arm' | 'arm64'
get_arch() {
  local arch=
  if command_exists uname; then
    case "$(uname -m | tr '[:upper:]' '[:lower:]')" in
    x86_64) arch=amd/x64 ;;
    armv*) arch=arm ;;
    arm64 | aarch64) arch=arm64 ;;
    esac
  fi
  if [[ -z "$arch" ]] && command_exists arch; then
    case "$(arch)" in
    x86_64*) arch=amd/x64 ;;
    i*86) arch=x32 ;;
    arm*) arch=arm ;;
    esac
  fi
  if [[ -z "$arch" ]]; then
    echo 'could not determine arch.' >&2
    exit 1
  fi

  if [ "${arch}" = "arm64" ] && command_exists getconf && [ "$(getconf LONG_BIT)" -eq 32 ]; then
    arch=arm
  fi
  echo "$arch"
}

is_android() {
  [[ "$PREFIX" == *com.termux* ]] || command_exists termux-setup-storage
}

command_exists() {
  local command=$1
  if command -v $command &>/dev/null; then
    return 0
  fi
  return 1
}

convert_path_if_needed() {
  local target_switch=$1
  local path=$2
  if command_exists wslpath; then
    echo "$(wslpath $target_switch "$path")"
  elif command_exists cygpath; then
    echo "$(cygpath $target_switch "$path")"
  else
    echo "$path"
  fi
}

make_directory_link() {
  local actual=$1
  local link=$2
  local force=false
  if [[ "$1" == true ]]; then
    force=true
  fi

  if [[ -e "$link" ]]; then
    if ! $force; then
      echo "mklink: something's already at link '$link'"
      read -p "mklink: want to replace it? (y/n) [n] " yn
      case $yn in
      [Yy]*) ;;
      *) exit 1 ;;
      esac
    fi

    rm -fr "$link"
  fi

  if [[ $(get_os) != 'windows' ]]; then
    ln -s "$actual" "$link"
  else
    actual=$(convert_path_if_needed --windows "$actual")
    link=$(convert_path_if_needed --windows "$link")
    local cmd="cmd /C'mklink /j ""$link"" ""$actual""'"
    printf 'mklink: '
    eval "$cmd"
  fi
}

download() {
  local url=$1
  local tmp=$(mktemp)
  curl --ssl-revoke-best-effort --fail -L -o "$tmp" "$url"
  echo "$tmp"
}

# returns with 0 if success, 1 if download failed, 2 if extract failed
download_and_extract() {
  local url=$1
  local outdir=$2
  local archive_type=$3 # "zip" | "tar"; optional, falls back to url filename

  local tmp=$(download "$url") || return 1

  if [[ "$archive_type" == '' ]]; then
    case "$url" in
    *.zip) archive_type=zip ;;
    *.tar | *.tar.gz | *.tar.xz) archive_type=tar ;;
    *)
      echo 'extract: could not determine archive type from url' >&2
      return 2
      ;;
    esac
  fi

  case "$archive_type" in
  zip)
    if ! unzip "$tmp" -d "$outdir"; then
      return 2
    fi
    ;;
  tar)
    if ! tar -xf "$tmp" -C "$outdir"; then
      return 2
    fi
    ;;
  *)
    echo 'extract: invalid archive_type' >&2
    return 2
    ;;
  esac

  rm -f "$tmp"

  # if archive contained one root dir, mv contents to outdir and delete the empty root
  items=$(ls "$outdir")
  rootdir="$outdir/${items[0]}"
  if (("${#items[@]}" == 1)) && [[ -d "$rootdir" ]]; then
    mv "$rootdir"/* "$rootdir"/.* "$outdir"
    rmdir "$rootdir"
  fi
}

atomic_download_and_extract() {
  local url=$1
  local outdir=$2
  local tmpoutdir="$(dirname "$outdir")/unfinished_$(basename "$outdir")"
  local archive_type=$3 # "zip" | "tar"; optional, falls back to url filename
  local force=false
  if [[ "$4" == true ]]; then
    force=true
  fi

  if [[ -e "$outdir" ]] && ! $force; then
    echo "extract: something's already at outdir '$outdir'"
    read -p "extract: want to replace it? (y/n) [n] " yn
    case $yn in
    [Yy]*) ;;
    *) exit 1 ;;
    esac
  fi

  download_and_extract "$url" "$tmpoutdir" "$archive_type" || {
    local exitstatus=$?
    if [[ -e "$tmpoutdir" ]]; then
      rm -fr "$tmpoutdir"
    fi
    return $exitstatus
  }

  if [[ -e "$outdir" ]]; then
    rm -fr "$outdir"
  fi
  mv "$tmpoutdir" "$outdir"
}

get_latest_github_tag() {
  local repo=$1
  curl "https://api.github.com/repos/$repo/releases/latest" |
    grep -E -o '.*"tag_name".*:.+' |
    sed 's/^.*:\s*"\(.*\)".*$/\1/'
}
