#!/usr/bin/env bash
set -euo pipefail

OUT="assets/agentic-ai-workers-highlight.mp4"
POSTER="assets/agentic-ai-workers-poster.png"
FRAMES="assets/agentic-video-frames"
SLIDES="assets/agentic-video-slides"
TRANSCRIPT="assets/agentic-ai-workers-narration.tsv"
LIST="/tmp/agentic-video-concat.txt"
NODE="${NODE:-node}"

mkdir -p assets
mkdir -p "$FRAMES"

"$NODE" tools/render_agentic_frames.mjs

slides=()
while IFS= read -r slide; do
  slides+=("$slide")
done < <(find "$SLIDES" -maxdepth 1 -type f -name '*.svg' | sort)

: > "$LIST"
for slide in "${slides[@]}"; do
  base="$(basename "$slide" .svg)"
  frame="$PWD/$FRAMES/$base.png"
  duration="$(awk -F '\t' -v key="$base" 'NR > 1 && $1 == key { print $2; found=1 } END { if (!found) print "" }' "$TRANSCRIPT")"

  if [ -z "$duration" ]; then
    duration="5.0"
  fi

  printf "file '%s'\n" "$frame" >> "$LIST"
  printf "duration %s\n" "$duration" >> "$LIST"
done

last_slide="${slides[$((${#slides[@]} - 1))]}"
last_base="$(basename "$last_slide" .svg)"
printf "file '%s'\n" "$PWD/$FRAMES/$last_base.png" >> "$LIST"

ffmpeg -y -f concat -safe 0 -i "$LIST" \
  -vf "scale=1920:1080,setsar=1,fps=30,format=yuv420p" \
  -movflags +faststart "$OUT"

first_slide="${slides[0]}"
first_base="$(basename "$first_slide" .svg)"
ffmpeg -y -i "$FRAMES/$first_base.png" -frames:v 1 -update 1 "$POSTER"
