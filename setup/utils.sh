is_windows() {
  if grep -qEi "(Microsoft|WSL|MSYS)" /proc/version &>/dev/null; then
    return 0
  else
    return 1
  fi
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
    echo "$(wslpath "$target_switch" "$path")"
  elif command_exists cygpath; then
    echo "$(cygpath "$target_switch" "$path")"
  else
    echo "$path"
  fi
}
