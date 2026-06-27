#!/bin/bash

swaymsg -q exec "$*"
sleep 0.5
swaymsg -t command 'floating enable, resize set 50% 60%, move position center'
