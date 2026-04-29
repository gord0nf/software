#!/bin/bash

# registers a software thing in software.csv.
# usage: ./register.sh <thing> <version> ...bin_paths
# note: $thing could contain chars that sed recognizes, which would mess it all up

thing=$1
version=$2
shift
shift
bin_paths=("$@")

SOFTWARE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SOFTWARE_CSV="$SOFTWARE_ROOT/software.csv"
THING=register

. "$SOFTWARE_ROOT/utils.sh"

if ! [[ -f "$SOFTWARE_CSV" ]]; then
  echo 'software,version,paths' >"$SOFTWARE_CSV"
fi

# remove existing registration(s)
sed -i "/^$thing,/d" "$SOFTWARE_CSV"

bin_paths_arr=
for path in "${bin_paths[@]}"; do
  bin_paths_arr+="$(convert_path_if_needed --windows "$path")|"
done
if [[ "$bin_paths_arr" != '' ]]; then
  bin_paths_arr="${bin_paths_arr::-1}"
fi

log "registering $thing"
echo "$thing,$version,$bin_paths_arr" >>"$SOFTWARE_CSV"
