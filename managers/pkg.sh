MANAGER=pkg
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

manager_can_use() {
  command_exists pkg || {
    err "manager($MANAGER): requires pkg, but not found"
    return 1
  }
}

manager_preinstall() {
  pkg update
}
