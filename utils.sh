SOFTWARE_SRC=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
GLOBAL_ENV="$HOME/.env"

# logging functions
! [[ -z "$THING" ]] && source "$SOFTWARE_SRC/log.sh"

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

is_debian() {
  [ -f /etc/os-release ] || return 1
  . /etc/os-release
  [[ "$ID" == "debian" || "$ID_LIKE" == *"debian"* ]]
}

command_exists() {
  command -v "$1" &>/dev/null
}

check_executable() {
  [[ -x "$1" || -x "$1.exe" ]] && {
    "$1" --help &>/dev/null || "$1.exe" --help &>/dev/null
  }
}

# git bash on windows is iffy about detecting junctions as existing using just [ -e ... ]
item_exists() {
  [[ -e "$1" ]] || ls "$1" &>/dev/null
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

prompt_yn() {
  read -n 1 -p "$1" yn
  echo
  case $yn in
  [Yy]*) return 0 ;;
  *) return 1 ;;
  esac
}

make_directory_link() {
  local actual=$(convert_path_if_needed --unix "$1")
  local link=$(convert_path_if_needed --unix "$2")
  FORCE="${FORCE:-false}"

  if item_exists "$link"; then
    if ! $FORCE; then
      echo "mklink: something's already at link '$link'"
      prompt_yn "mklink: want to replace it? (y/n) [n] " || exit 1
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
  local tmp=$(mktemp)
  curl --ssl-revoke-best-effort --fail -L -o "$tmp" "$1" &&
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

  # remove nested root dirs until the outdir is the root dir
  while true; do
    items=$(ls -A "$outdir")
    rootdir="$outdir/${items[0]}"
    if (("${#items[@]}" == 1)) && [[ -d "$rootdir" ]]; then
      mv "$rootdir"/* "$rootdir"/.* "$outdir" &>/dev/null
      rmdir "$rootdir"
    else
      break
    fi
  done
}

atomic_download_and_extract() {
  local url=$1
  local outdir=$2
  local tmpoutdir="$(dirname "$outdir")/unfinished_$(basename "$outdir")"
  local archive_type=$3 # "zip" | "tar"; optional, falls back to url filename
  FORCE="${FORCE:-false}"

  if item_exists "$outdir" && ! $FORCE; then
    echo "extract: something's already at outdir '$outdir'"
    prompt_yn "extract: want to replace it? (y/n) [n] " || exit 1
  fi

  mkdir -p "$tmpoutdir"
  download_and_extract "$url" "$tmpoutdir" "$archive_type" || {
    local exitstatus=$?
    if item_exists "$tmpoutdir"; then
      rm -fr "$tmpoutdir"
    fi
    return $exitstatus
  }

  if item_exists "$outdir"; then
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

# interface for variables in global .env (with special += syntax for appending)
set_global_env() {
  local name=$1
  local value=$2
  [[ -f "$GLOBAL_ENV" ]] || touch "$GLOBAL_ENV"

  if [[ "$3" == "-a"* ]]; then
    export "$name"="${!name}$value"
    existing_line=$(grep -oE -m 1 "^$name\\+=.*$" "$GLOBAL_ENV") &&
      sed -i "/^$name+=/d" "$GLOBAL_ENV"
    [[ "$existing_line" =~ \"(.*)\" ]] && existing_line=${BASH_REMATCH[1]}
    echo "$name+=\"${existing_line#*=}$value\"" >>"$GLOBAL_ENV"
  elif [[ "$2" == '-u'* ]]; then
    export "$name"=
    sed -i "/^$name=/d" "$GLOBAL_ENV"
  else
    export "$name"="$value"
    sed -i "/^$name=/d" "$GLOBAL_ENV"
    echo "$name=\"$value\"" >>"$GLOBAL_ENV"
  fi
}

add_global_path() {
  local p=$(convert_path_if_needed --unix "$1") # global PATH stored in unix format
  [[ "$2" == '--force' || -d "$p" ]] || return  # ensure existence

  local global_PATH=$(sed -n 's/^PATH+=\(.*\)/\1/p' "$GLOBAL_ENV" 2>/dev/null)
  [[ "$global_PATH" =~ \"(.*)\" ]] && global_PATH=${BASH_REMATCH[1]}
  if [[ ":$global_PATH:" != *":$p:"* ]]; then
    set_global_env PATH ":$p" -append
  fi
}

register() {
  for target_bin in "$@"; do
    if [[ -f "$target_bin" || -f "$target_bin.exe" ]]; then
      local bin_dir=$(dirname "$target_bin")
      case $(get_os) in
      windows) add_global_path "$bin_dir" ;;
      *)
        [[ $EUID -eq 0 ]] && symlink_dir='/usr/local/bin/' || symlink_dir="$HOME/.local/bin"
        mkdir -p "$symlink_dir" && add_global_path "$symlink_dir" # just in case
        symlink="$symlink_dir/$(basename "$target_bin")"
        rm -f "$symlink"
        ln --symbolic "$target_bin" "$symlink"
        ;;
      esac
    fi
  done
}

# credit: https://github.com/mrbaseman/parse_yaml/
function parse_yaml_noctx {
  unset i
  unset fs
  local prefix=$2
  local separator=${3:-_}

  local indexfix=-1
  # Detect awk flavor
  if awk --version 2>&1 | grep -q "GNU Awk"; then
    # GNU Awk detected
    indexfix=-1
  elif awk -Wv 2>&1 | grep -q "mawk"; then
    # mawk detected
    indexfix=0
  fi

  local s='[[:space:]]*' sm='[ \t]*' w='[a-zA-Z0-9_.]*' fs=${fs:-$(echo @ | tr @ '\034')} i=${i:-  }

  ###############################################################################
  # cat:   read the yaml file (or stdin) into the stream
  # awk 1: process multi-line text
  # sed 1: remove comments and empty lines
  # sed 2: process lists
  # sed 3: process dictionaries
  # sed 4: rearrange anchors
  # sed 5: remove '---'/'...'/quotes, add file separator to create fields for awk 2
  # awk 2: convert the formatted data to variable assignments
  ###############################################################################

  echo | cat ${1:--} - |
    awk -F$fs "{multi=0;
        if(match(\$0,/$sm\|$sm$/)){multi=1; sub(/$sm\|$sm$/,\"\");}
        if(match(\$0,/$sm>$sm$/)){multi=2; sub(/$sm>$sm$/,\"\");}
        while(multi>0){
            str=\$0; gsub(/^$sm/,\"\", str);
            indent=index(\$0,str);
            indentstr=substr(\$0, 0, indent+$indexfix) \"$i\";
            obuf=\$0;
            getline;
            while(index(\$0,indentstr)){
                obuf=obuf substr(\$0, length(indentstr)+1);
                if (multi==1){obuf=obuf \"\\\\n\";}
                if (multi==2){
                    if(match(\$0,/^$sm$/))
                        obuf=obuf \"\\\\n\";
                        else obuf=obuf \" \";
                }
                getline;
            }
            sub(/$sm$/,\"\",obuf);
            print obuf;
            multi=0;
            if(match(\$0,/$sm\|$sm$/)){multi=1; sub(/$sm\|$sm$/,\"\");}
            if(match(\$0,/$sm>$sm$/)){multi=2; sub(/$sm>$sm$/,\"\");}
        }
    print}" |
    sed -e "s|^\($s\)?|\1-|" \
      -ne "s|^\($s\)-$s\($w\)$s:$s\(.*\)|\1-\n\1 \2: \3|" \
      -ne "s|^$s#.*||;s|$s#[^\"']*$||;s|^\([^\"'#]*\)#.*|\1|;t 1" \
      -ne "t" \
      -ne ":1" \
      -ne "s|^$s\$||;t 2" \
      -ne "p" \
      -ne ":2" \
      -ne "d" |
    sed -ne "s|,$s\]|]|g" \
      -e ":1" \
      -e "s|^\($s\)\($w\)$s:$s\(&$w\)$s\[$s\(.*\)$s,$s\(.*\)$s\]|\1\2: \3[\4]\n\1$i- \5|;t 1" \
      -e "s|^\($s\)\($w\)$s:$s\(&$w\)$s\[$s\(.*\)$s\]|\1\2: \3\n\1$i- \4|;" \
      -e ":2" \
      -e "s|^\($s\)\($w\)$s:$s\[$s\(.*\)$s,$s\(.*\)$s\]|\1\2: [\3]\n\1$i- \4|;t 2" \
      -e "s|^\($s\)\($w\)$s:$s\[$s\(.*\)$s\]|\1\2:\n\1$i- \3|;" \
      -e ":3" \
      -e "s|^\($s\)-$s\[$s\(.*\)$s,$s\(.*\)$s\]|\1- [\2]\n\1$i- \3|;t 3" \
      -e "s|^\($s\)-$s\[$s\(.*\)$s\]|\1-\n\1$i- \2|;p" |
    sed -ne "s|,$s}|}|g" \
      -e ":1" \
      -e "s|^\($s\)-$s{$s\(.*\)$s,$s\($w\)$s:$s\(.*\)$s}|\1- {\2}\n\1$i\3: \4|;t 1" \
      -e "s|^\($s\)-$s{$s\(.*\)$s}|\1-\n\1$i\2|;" \
      -e ":2" \
      -e "s|^\($s\)\($w\)$s:$s\(&$w\)$s{$s\(.*\)$s,$s\($w\)$s:$s\(.*\)$s}|\1\2: \3 {\4}\n\1$i\5: \6|;t 2" \
      -e "s|^\($s\)\($w\)$s:$s\(&$w\)$s{$s\(.*\)$s}|\1\2: \3\n\1$i\4|;" \
      -e ":3" \
      -e "s|^\($s\)\($w\)$s:$s{$s\(.*\)$s,$s\($w\)$s:$s\(.*\)$s}|\1\2: {\3}\n\1$i\4: \5|;t 3" \
      -e "s|^\($s\)\($w\)$s:$s{$s\(.*\)$s}|\1\2:\n\1$i\3|;p" |
    sed -e "s|^\($s\)\($w\)$s:$s\(&$w\)\(.*\)|\1\2:\4\n\3|" \
      -e "s|^\($s\)-$s\(&$w\)\(.*\)|\1- \3\n\2|" |
    sed -ne "s|^\($s\):|\1|" \
      -e "s|^\($s\)\(---\)\($s\)||" \
      -e "s|^\($s\)\(\.\.\.\)\($s\)||" \
      -e "s|^\($s\)-${s}[\"']\(.*\)[\"']$s\$|\1$fs$fs\2|p;t" \
      -e "s|^\($s\)\($w\)$s:${s}[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p;t" \
      -e "s|^\($s\)-$s\(.*\)$s\$|\1$fs$fs\2|" \
      -e "s|^\($s\)\($w\)$s:${s}[\"']\?\(.*\)$s\$|\1$fs\2$fs\3|" \
      -e "s|^\($s\)[\"']\?\([^&][^$fs]\+\)[\"']$s\$|\1$fs$fs$fs\2|" \
      -e "s|^\($s\)[\"']\?\([^&][^$fs]\+\)$s\$|\1$fs$fs$fs\2|" \
      -e "s|^\($s\)\($w\)$s:${s}[\"']\(.*\)$s\$|\1$fs\2$fs\3|" \
      -e "s|^\($s\)[\"']\([^&][^$fs]*\)[\"']$s\$|\1$fs$fs$fs\2|" \
      -e "s|^\($s\)[\"']\([^&][^$fs]*\)$s\$|\1$fs$fs$fs\2|" \
      -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|" \
      -e "s|^\($s\)\([^&][^$fs]*\)[\"']$s\$|\1$fs$fs$fs\2|" \
      -e "s|^\($s\)\([^&][^$fs]*\)$s\$|\1$fs$fs$fs\2|" \
      -e "s|$s\$||p" |
    awk -F$fs "{
        gsub(/\t/,\"        \",\$1);
        if(NF>3){if(value!=\"\"){value = value \" \";}value = value  \$4;}
        else {
            if(match(\$1,/^&/)){anchor[substr(\$1,2)]=full_vn;getline};
            indent = length(\$1)/length(\"$i\");
            vname[indent] = \$2;
            value= \$3;
            for (i in vname) {if (i > indent) {delete vname[i]; idx[i]=0}}
            if(length(\$2)== 0){  vname[indent]= ++idx[indent] };
            vn=\"\"; for (i=0; i<indent; i++) { vn=(vn)(vname[i])(\"$separator\")}
            vn=\"$prefix\" vn;
            full_vn=vn vname[indent];
            if(vn==\"$prefix\")vn=\"$prefix$separator\";
            if(vn==\"_\")vn=\"__\";
        }
        gsub(/\./,\"$separator\",full_vn);
	gsub(/\\\\\"/,\"\\\"\",value);
	gsub(/'/,\"'\\\"'\\\"'\",value);
        assignment[full_vn]=value;
        if(!match(assignment[vn], full_vn))assignment[vn]=assignment[vn] \" \" full_vn;
        if(match(value,/^\*/)){
            ref=anchor[substr(value,2)];
            if(length(ref)==0){
                printf(\"%s='%s'\n\", full_vn, value);
            } else {
                for(val in assignment){
                    if((length(ref)>0)&&index(val, ref)==1){
                        tmpval=assignment[val];
                        sub(ref,full_vn,val);
                        if(match(val,\"$separator\$\")){
                            gsub(ref,full_vn,tmpval);
                        } else if (length(tmpval) > 0) {
                            printf(\"%s='%s'\n\", val, tmpval);
                        }
                        assignment[val]=tmpval;
                    }
                }
            }
        } else if (length(value) > 0) {
            printf(\"%s='%s'\n\", full_vn, value);
        }
    }END{
        for(val in assignment){
            if(match(val,\"$separator\$\"))
                printf(\"%s='%s'\n\", val, assignment[val]);
        }
    }"
}

# parse_yaml that is aware of existing array context
function parse_yaml {
  local prefix=$2
  local separator=${3:-_}
  local array_var_regex="^$prefix(.+)$separator([0-9]+)$"

  local output=$(parse_yaml_noctx "$@")

  while IFS='=' read -r var value; do
    if [[ $var =~ $array_var_regex ]]; then
      local list_name="${BASH_REMATCH[1]}"
      local curr_idx="${BASH_REMATCH[2]}"

      local start_idx=1
      while [[ -v "$prefix$list_name$separator$start_idx" ]]; do
        ((start_idx++))
      done

      if [[ $start_idx -gt 1 ]]; then
        local new_idx=$((start_idx + curr_idx - 1))
        var="$prefix$list_name$separator$new_idx"
      fi

    fi
    echo "$var=$value"
  done <<<"$output"
}

# list all keys of yml array. parse_yaml() already kinda does this but if you load multiple ymls, the base variable gets overridden.
yaml_array_keys() {
  local prefix=$1
  local keys=()
  local i=1
  while [[ -v "$prefix$i" ]]; do
    keys+=("$prefix$i")
    ((i++))
  done
  echo "${keys[@]}"
}
