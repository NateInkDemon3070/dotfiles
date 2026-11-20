#!/bin/bash
while true; do
  if playerctl --player=mpd status >/dev/null 2>&1; then
    playerctl --player=mpd metadata >/dev/null 2>&1
  fi
  sleep 10
done
