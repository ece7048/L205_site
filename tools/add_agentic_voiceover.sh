#!/usr/bin/env bash
set -euo pipefail

VOICE="${VOICE:-Moira}"
RATE="${RATE:-165}"
VIDEO="assets/agentic-ai-workers-highlight.mp4"
TRANSCRIPT="assets/agentic-ai-workers-narration.tsv"
AUDIO_DIR="assets/agentic-video-audio"
LIST="/tmp/agentic-audio-concat.txt"
VOICEOVER="$AUDIO_DIR/voiceover.wav"
VOICEOVER_RAW="$AUDIO_DIR/voiceover-raw.wav"
OUT="/tmp/agentic-ai-workers-highlight-voiced.mp4"

mkdir -p "$AUDIO_DIR"
: > "$LIST"

tail -n +2 "$TRANSCRIPT" | while IFS=$'\t' read -r slide duration text; do
  raw="$AUDIO_DIR/$slide.aiff"
  wav="$AUDIO_DIR/$slide.wav"

  say -v "$VOICE" -r "$RATE" -o "$raw" -- "$text"

  actual="$(ffprobe -v error -show_entries format=duration -of default=nk=1:nw=1 "$raw")"
  tempo="$(awk -v actual="$actual" -v target="$duration" 'BEGIN {
    if (actual > target * 0.96) {
      value = actual / (target * 0.96);
      if (value < 0.5) value = 0.5;
      if (value > 2.0) value = 2.0;
      printf "%.4f", value;
    } else {
      printf "1.0000";
    }
  }')"

  ffmpeg -y -i "$raw" \
    -af "aresample=48000,atempo=$tempo,apad,atrim=0:$duration,asetpts=N/SR/TB" \
    -ar 48000 -ac 1 "$wav" >/dev/null 2>&1

  printf "file '%s'\n" "$PWD/$wav" >> "$LIST"
done

ffmpeg -y -f concat -safe 0 -i "$LIST" -c copy "$VOICEOVER_RAW"

video_duration="$(ffprobe -v error -show_entries format=duration -of default=nk=1:nw=1 "$VIDEO")"

ffmpeg -y -i "$VOICEOVER_RAW" \
  -af "apad,atrim=0:$video_duration,asetpts=N/SR/TB" \
  -ar 48000 -ac 1 "$VOICEOVER"

ffmpeg -y -i "$VIDEO" -i "$VOICEOVER" \
  -map 0:v:0 -map 1:a:0 \
  -c:v copy -c:a aac -b:a 128k \
  -movflags +faststart "$OUT"

mv "$OUT" "$VIDEO"
