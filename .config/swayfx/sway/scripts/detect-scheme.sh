#!/bin/bash
# Detecta si una imagen es mayormente B/N o colorida
# Devuelve "scheme-neutral" para B/N, "scheme-fidelity" para colorido

IMAGE="$1"
[ -z "$IMAGE" ] && echo "scheme-fidelity" && exit 0

SAT=$(convert "$IMAGE" -resize 1x1! -colorspace HSL -channel g -format "%[mean]" info: 2>/dev/null)
SAT=${SAT%.*}

if [ "$SAT" -gt 2000 ] 2>/dev/null; then
  echo "scheme-fidelity"
else
  echo "scheme-neutral"
fi