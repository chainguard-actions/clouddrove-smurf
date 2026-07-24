#!/bin/sh
# Fake curl for testing smurf latest version install
# Supports both piped form (stdout) and -o FILE form
out=""
next_is_out=0
for arg in "$@"; do
  if [ "$next_is_out" = "1" ]; then
    out="$arg"
    next_is_out=0
    continue
  fi
  case "$arg" in
    --output|-o)
      next_is_out=1
      ;;
    -*)
      case "$arg" in
        *o) next_is_out=1 ;;
      esac
      ;;
  esac
done

case "$*" in
  *clouddrove/smurf/releases/latest*)
    payload='{"tag_name":"v0.0.99","name":"v0.0.99"}'
    if [ -n "$out" ]; then
      printf '%s\n' "$payload" > "$out"
    else
      printf '%s\n' "$payload"
    fi
    exit 0
    ;;
  *clouddrove/smurf/releases/download*smurf*.tar.gz*)
    if [ -n "$out" ]; then
      cp /tmp/smurf-fake.tar.gz "$out"
    else
      cat /tmp/smurf-fake.tar.gz
    fi
    exit 0
    ;;
esac

exec /usr/bin/curl "$@"
