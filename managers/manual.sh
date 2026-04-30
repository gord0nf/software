MANAGER=manual
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

manager_can_use() {
  local deps=(curl unzip tar grep sed awk)
  for dep in "${deps[@]}"; do
    command_exists "$dep" || {
      err "manager($MANAGER): requires $dep, but not found"
      return 1
    }
  done
}
