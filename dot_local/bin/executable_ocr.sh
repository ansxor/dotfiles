#!/bin/bash
# Dependencies: tesseract-ocr imagemagick wl-clipboard hyprshot

die() {
  notify-send "$1"
  exit 1
}
cleanup() {
  [[ -n $1 ]] && rm -r "$1"
}

SCR_IMG=$(mktemp -d) || die "failed to create tmpdir"

# shellcheck disable=SC2064
trap "cleanup '$SCR_IMG'" EXIT

hyprshot -m region -f scr.png --silent -o $SCR_IMG
mogrify -modulate 100,0 -resize 400% "$SCR_IMG/scr.png"
tesseract "$SCR_IMG/scr.png" "$SCR_IMG/scr" &>/dev/null
wl-copy <"$SCR_IMG/scr.txt"
notify-send "Text extracted from image"
exit
