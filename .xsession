#!/bin/sh

# Set default keyboard layout to german and replace caps lock by
# control
setxkbmap -layout de -option ctrl:nocaps

# Ensure the desktop identity is qtile, not the inherited ubuntu:GNOME
# from the display manager. Qtile >= 0.37 exports these into the
# systemd/DBus activation environment; leaving them as GNOME causes
# xdg-desktop-portal to try activating the (broken) GNOME portal impl,
# which deadlocks GTK apps (e.g. Ghostty) for ~120s on launch.
export XDG_CURRENT_DESKTOP=qtile
export XDG_SESSION_DESKTOP=qtile
unset GNOME_DESKTOP_SESSION_ID GNOME_SHELL_SESSION_MODE

# Fixing the shell env above is not enough: xdg-desktop-portal (and
# its backends) are DBus/systemd-activated, so they inherit the
# *systemd user manager* environment, which GDM populated with
# XDG_CURRENT_DESKTOP=ubuntu:GNOME and GNOME_* before .xsession ran.
# Propagate the qtile identity into systemd and the DBus activation
# environment, drop the stale GNOME_* leftovers, and stop any portal
# instances that were already activated with the wrong env so they
# get respawned cleanly (and pick up ~/.config/xdg-desktop-portal/
# qtile-portals.conf, which routes portals to the gtk backend and
# Secret to gnome-keyring).
if command -v systemctl >/dev/null 2>&1; then
    systemctl --user import-environment \
        XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP
    systemctl --user unset-environment \
        GNOME_DESKTOP_SESSION_ID GNOME_SHELL_SESSION_MODE
    systemctl --user stop \
        xdg-desktop-portal-gnome.service \
        xdg-desktop-portal-gtk.service \
        xdg-desktop-portal.service 2>/dev/null || true
fi
if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment --systemd \
        XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP
fi

# Start Qtile
~/.local/bin/startqtile

# Start xcfe
# /usr/bin/startxfce4
