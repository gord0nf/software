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

command_exists() {
  local command=$1
  if command -v $command &>/dev/null; then
    return 0
  fi
  return 1
}

deprioritize_paths() {
  local pattern=$1
  local pathlines="${2//:/$'\n'}"
  pathlines=$(
    echo -n "$pathlines" |
      awk "/$pattern/{buf = buf \$0 RS;next} {print} END{printf \"%s\",buf}"
  )
  # echo "$pathlines"
  echo "${pathlines//$'\n'/:}"
}
