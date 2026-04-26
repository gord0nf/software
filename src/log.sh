if [[ -z "$THING" ]]; then
  echo 'THING must be defined to use log.sh' >&2
  exit 1
fi

if [[ -z "$PREFIX_FORMAT" ]]; then
  PREFIX_FORMAT='[%s]'
fi
PREFIX=$(printf "\033[38;5;%dm$THING\033[0m" $(shuf -i 67-231 -n 1)) # random 256 color
PREFIX=$(printf -- "$PREFIX_FORMAT" "$PREFIX")

log() {
  printf "$PREFIX %s\n" "$*" >&2
}

log_result() {
  printf "$PREFIX$(
    [ $? -eq 0 ] &&
      echo " \033[32m%s success" ||
      echo " \033[31m%s failed"
  )\033[0m\n" "$*" >&2
}

warn() {
  printf "$PREFIX \033[33mwarning: %s\033[0m\n" "$*" >&2
}

err() {
  printf "$PREFIX \033[31m%s\033[0m\n" "$*" >&2
}

fatal() {
  err "fatal: $*"
  exit 1
}
