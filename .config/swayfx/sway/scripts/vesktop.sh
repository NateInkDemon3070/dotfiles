#!/bin/bash
BUS_FILE="/tmp/sway-dbus-address"
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ] && [ -f "$BUS_FILE" ]; then
  export DBUS_SESSION_BUS_ADDRESS="$(cat "$BUS_FILE")"
fi
exec vesktop "$@"
