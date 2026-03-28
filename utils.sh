# returns 'windows' | 'linux' | 'mac'
get_os() {
  if grep -qEi "(Microsoft|WSL|MSYS)" /proc/version &>/dev/null; then
    echo 'windows'
  elif [[ "$OSTYPE" == "linux-gnu"* || "$OSTYPE" == "freebsd"* ]]; then
    echo 'linux'
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo 'mac'
  elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo 'windows'
  else
    echo 'could not determine os. please define $OSTYPE' >&2
    exit 1
  fi
}

# returns 'amd/x64' | 'x32' | 'arm'
get_arch() {
  archs=($(uname -m) $(arch))
  for arch in "${archs[@]}"; do
    if [[ $arch == x86_64* ]]; then
      echo 'amd/x64'
    elif [[ $arch == i*86 ]]; then
      echo 'x32'
    elif [[ $arch == arm* ]]; then
      echo 'arm'
    else
      continue
    fi
    return
  done
  echo 'could not determine sys architecture' >&2
  exit 1
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
  if [[ $(get_os) != 'windows' ]]; then
    ln -s "$actual" "$link"
  else
    link=$(convert_path_if_needed --windows "$link")
    actual=$(convert_path_if_needed --windows "$actual")
    command="cmd /C'mklink /j ""$link"" ""$actual""'"
    printf 'mklink: '
    eval "$command"
  fi
}

# returns with 0 if success, 1 if download failed, 2 if extract failed
download_and_extract() {
  local url=$1
  local outdir=$2
  local tmp=$(mktemp)

  if ! curl --fail -L -o "$tmp" "$url"; then
    return 1
  fi

  if [[ $url == *.zip ]]; then
    if ! unzip "$tmp" -d "$install_dir"; then
      return 2
    fi
  elif [[ $url == *.tar.gz ]]; then
    if ! tar -zxf "$tmp" -C "$install_dir"; then
      return 2
    fi
  fi
  rm -f "$tmp"
}
