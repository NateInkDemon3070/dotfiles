#!/usr/bin/env python3
import sys
import time

from gi.repository import Gio, GLib

SVC = "org.gnome.keyring"
ROOT = "/org/freedesktop/secrets"
IFACE = "org.gnome.keyring.InternalUnsupportedGuiltRiddenInterface"
COLLECTION = "/org/freedesktop/secrets/collection/Default"


def main():
    bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)

    for _ in range(60):
        try:
            bus.call_sync(
                "org.freedesktop.secrets",
                ROOT,
                "org.freedesktop.Secret.Service",
                "ReadAlias",
                GLib.Variant("(s)", ("default",)),
                GLib.VariantType("(o)"),
                Gio.DBusCallFlags.NONE,
                1000,
                None,
            )
            break
        except GLib.Error:
            time.sleep(0.25)
    else:
        return 1

    opened = bus.call_sync(
        "org.freedesktop.secrets",
        ROOT,
        "org.freedesktop.Secret.Service",
        "OpenSession",
        GLib.Variant("(sv)", ("plain", GLib.Variant("s", ""))),
        GLib.VariantType("(vo)"),
        Gio.DBusCallFlags.NONE,
        -1,
        None,
    )
    _, session = opened.unpack()
    secret = (str(session), b"", b"", "text/plain")

    bus.call_sync(
        SVC,
        ROOT,
        IFACE,
        "UnlockWithMasterPassword",
        GLib.Variant("(o(oayays))", (COLLECTION, secret)),
        None,
        Gio.DBusCallFlags.NONE,
        -1,
        None,
    )
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except GLib.Error as e:
        print("No se pudo desbloquear el llavero:", e.message, file=sys.stderr)
        sys.exit(1)
