#!/bin/bash

install_dir=$1
FORCE="${FORCE:-false}"

THING=pwsh
source "$(dirname "${BASH_SOURCE[0]}")/../../utils.sh" || {
  echo "fatal: couldn't source utils" >&2
  exit 1
}

get_download_url() {
  local tag=$1

  local os=
  local arch=
  local ext=
  case "$(get_os)" in
  windows)
    os=win
    ext=zip
    ;;
  mac)
    os=osx
    ext=tar.gz
    ;;
  linux)
    os=linux
    ext=tar.gz
    ;;
  esac
  case "$(get_arch)" in
  amd/x64) arch=x64 ;;
  arm) arch=arm32 ;;
  arm64) arch=arm64 ;;
  x32) arch=x86 ;;
  esac

  echo "https://github.com/PowerShell/PowerShell/releases/download/$tag/PowerShell-${tag:1}-$os-$arch.$ext"
}

win_add_to_sys_path=$'
param ( [string]$newpath )
$scope = [System.EnvironmentVariableTarget]::User
$syspath = [System.Environment]::GetEnvironmentVariable("Path", $scope)
if (("$syspath" -split \';\') -notcontains "$newpath") {
  [System.Environment]::SetEnvironmentVariable("Path", "$syspath;$newpath", $scope)
}'

binary="$install_dir/pwsh"

if ! $FORCE && command_exists pwsh; then
  log 'already installed'
elif check_executable "$binary"; then
  log 'already installed, just not registered'
  log 'registering'
  register "$binary"
else
  log 'getting version'
  version=$(get_latest_github_tag 'PowerShell/PowerShell')
  url=$(get_download_url "$version")

  log 'installing'
  atomic_download_and_extract "$url" "$install_dir" '' || fatal 'install failed'
  register "$binary"

  # if windows, add to system path so it can be detected by some windows things
  if [[ $(get_os) == windows ]]; then
    log 'adding to system path'
    add_syspath=$(mktemp)
    mv "$add_syspath" "$add_syspath.ps1"
    add_syspath="$add_syspath.ps1"
    echo "$win_add_to_sys_path" >"$add_syspath"
    "$install_dir/pwsh" -NoProfile "$add_syspath" "$(convert_path_if_needed --windows "$install_dir")"
    rm -f "$add_syspath"
  fi
fi
