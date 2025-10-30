"""My Qtile configuration."""

import re
import subprocess
from pathlib import Path
from typing import Any, List

from libqtile import bar, hook, layout, qtile, widget  # type: ignore
from libqtile.config import Click, Drag, Group, Key, Match, Screen  # type: ignore
from libqtile.dgroups import simple_key_binder  # type: ignore
from libqtile.lazy import lazy  # type: ignore

mod = "mod4"
my_term = "terminator"
my_browser = "firefox"

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "j", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "k", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "i", lazy.layout.up(), desc="Move focus up"),
    Key(
        [mod],
        "o",
        lazy.layout.next(),
        desc="Navigate to next window in current stack pane",
    ),
    Key([mod], "n", lazy.layout.normalize(), desc="normalize window size ratios"),
    Key(
        [mod],
        "m",
        lazy.layout.maximize(),
        desc="toggle window between minimum and maximum sizes",
    ),
    Key([mod, "shift"], "f", lazy.window.toggle_floating(), desc="toggle floating"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="toggle fullscreen"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    Key([mod], "Tab", lazy.group.next_window()),
    Key([mod, "shift"], "Tab", lazy.group.prev_window()),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key(
        [mod, "shift"], "j", lazy.layout.shuffle_left(), desc="Move window to the left"
    ),
    Key(
        [mod, "shift"],
        "l",
        lazy.layout.shuffle_right(),
        desc="Move window to the right",
    ),
    Key([mod, "shift"], "k", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "i", lazy.layout.shuffle_up(), desc="Move window up"),
    # Move around workspaces
    Key(
        [mod, "control"],
        "l",
        lazy.screen.next_group(skip_empty=False),
        desc="Navigate to next group",
    ),
    Key(
        [mod, "control"],
        "j",
        lazy.screen.prev_group(skip_empty=False),
        desc="Navigate to previous group",
    ),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "control"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    # Toggle between different layouts as defined below
    Key([mod, "control"], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    # --------------------------------------------------------
    # Personal key bindings
    Key(
        [mod, "shift"], "e", lazy.spawn("emacsclient -c -a emacs"), desc="Launch Emacs"
    ),
    Key([mod, "shift"], "d", lazy.spawn("emacs --daemon"), desc="Launch Emacs server"),
    Key([mod, "shift"], "Return", lazy.spawn(my_term), desc="Launch my terminal"),
    Key([mod, "shift"], "b", lazy.spawn(my_browser), desc="Launch my browser"),
    Key([mod, "shift"], "r", lazy.restart(), desc="Restart Qtile"),
    Key([mod, "shift"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawn("rofi -show run"), desc="Run Rofi"),
    Key([mod], "a", lazy.spawn(str(Path("~/.local/bin/rofi-main").expanduser()))),
    Key(
        [mod],
        "s",
        lazy.spawn(
            str(Path("rofi -show p -modi p:~/.local/bin/rofi-power-menu").expanduser())
        ),
    ),
    # Groups
    Key([mod, "control"], "Left", lazy.screen.prev_group()),
    Key([mod, "control"], "Right", lazy.screen.next_group()),
    # Brightness
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl set 10%-")),
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl set +10%")),
    # Audio
    Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")),
    Key(
        [],
        "XF86AudioLowerVolume",
        lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%"),
    ),
    Key(
        [],
        "XF86AudioRaiseVolume",
        lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%"),
    ),
]

# --------------------------------------------------------

layout_theme = {
    "border_width": 1,
    "margin": 5,
    "border_focus": "e1acff",
    "border_normal": "1D2330",
}

layouts = [
    layout.MonadTall(**layout_theme),
    layout.Columns(**layout_theme),
    layout.Max(**layout_theme),
    layout.Floating(),
    layout.Matrix(),
]

# --------------------------------------------------------

groups = [
    Group("Dev", layout="monadtall"),
    Group(
        "Com",
        layout="monadtall",
        matches=[
            Match(
                title=re.compile(
                    r"^(Microsoft\ Teams|Outlook\ \(PWA\)|Chat \| Microsoft Teams classic)$"
                )
            )
        ],
    ),
    Group(
        "Remote",
        layout="monadtall",
        matches=[Match(title=re.compile(r"^(FE\-V\-013VV_S|Citrix Workspace)$"))],
    ),
]

# Allow MODKEY+[0 through 9] to bind to groups, see
# https://docs.qtile.org/en/stable/manual/config/groups.html MOD4 +
# index Number : Switch to Group[index] MOD4 + shift + index Number :
# Send active window to another Group
dgroups_key_binder = simple_key_binder(mod)

for i, group in enumerate(groups):
    keys.extend(
        [
            Key(
                [mod, "shift"],
                f"{i}",
                lazy.window.togroup(group),
                desc=f"Move active window to group {group}",
            ),
        ]
    )
# --------------------------------------------------------

# Based on the Emacs Doom vibrant theme
# https://github.com/doomemacs/themes/blob/master/themes/doom-vibrant-theme.el
my_colors = {
    "bg": "#282c34",
    "fg": "#bfbfbf",
    "dark-grey": "#1c1f24",
    "grey": "#5e5e5e",
    "red": "#ff6655",
    "orange": "#dd8844",
    "green": "#99bb66",
    "teal": "#44b9b1",
    "yellow": "#ECBE7B",
    "blue": "#51afef",
    "dark-blue": "#2257A0",
    "magenta": "#c678dd",
    "violet": "#a9a1e1",
    "cyan": "#46D9FF",
    "dark-cyan": "#5699AF",
}

widget_defaults = {
    "font": "Ubuntu Mono",
    "fontsize": 14,
    "padding": 2,
    "background": my_colors["bg"],
    "foreground": my_colors["fg"],
}
extension_defaults = widget_defaults.copy()


def lower_left_triangle(bg_color: str, fg_color: str) -> Any:
    """Add a left triangle symbol from unicode.

    :param bg_color: background color
    :param fg_color: foreground color

    :returns: Textbox
    """
    return widget.TextBox(
        text="\u25e2",
        padding=0,
        fontsize=35,
        background=bg_color,
        foreground=fg_color,
    )


def init_widgets_list(hide_sys_tray: bool = False) -> List[Any]:
    """Create my widgets for the top toolbar.

    :returns: List of widgets
    """
    widgets_list = [
        widget.GroupBox(
            margin_y=3,
            margin_x=0,
            padding_y=5,
            padding_x=5,
            borderwidth=3,
            active=my_colors["fg"],
            inactive=my_colors["grey"],
            highlight_method="block",
            highlight_color=my_colors["dark-grey"],
        ),
        widget.Sep(linewidth=0, padding=6),
        widget.CurrentLayout(
            custom_icon_paths=[Path("~/.config/qtile/icons").expanduser()],
            padding=0,
            scale=0.7,
        ),
        widget.Sep(linewidth=0, padding=6),
        widget.WindowCount(fmt="#{}", font="Ubuntu Mono", foreground=my_colors["fg"]),
        widget.Sep(linewidth=0, padding=6),
        widget.WindowName(
            foreground=my_colors["fg"],
            padding=10,
        ),
    ]
    if not hide_sys_tray:
        widgets_list += [
            widget.Systray(padding=5),
        ]
    widgets_list += [
        widget.Sep(linewidth=0, padding=6),
        widget.TextBox("V:", background=my_colors["bg"], foreground=my_colors["fg"]),
        widget.PulseVolume(),
        widget.TextBox("B:", background=my_colors["bg"], foreground=my_colors["fg"]),
        widget.Backlight(backlight_name="intel_backlight"),
        widget.BatteryIcon(),
        widget.Battery(),
        widget.TextBox(text="|", background=my_colors["bg"]),
        widget.CPU(
            foreground=my_colors["fg"],
            background=my_colors["bg"],
            mouse_callbacks={"Button1": lambda: qtile.cmd_spawn(my_term + " -e htop")},
        ),
        widget.TextBox("|", background=my_colors["bg"]),
        widget.Clock(
            foreground=my_colors["fg"],
            background=my_colors["bg"],
            format="%A, %B %d - %H:%M ",
        ),
    ]
    return widgets_list


screens = [
    Screen(
        top=bar.Bar(
            widgets=init_widgets_list(),
            opacity=1.0,
            size=20,
        )
    ),
    Screen(
        top=bar.Bar(
            widgets=init_widgets_list(hide_sys_tray=True),
            opacity=1.0,
            size=20,
        )
    ),
]

# Drag floating layouts.
mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_app_rules: List[Any] = []
follow_mouse_focus = False
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of
        # an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(wm_class="evolution-alarm-notify"),  # evolution notifier
        Match(wm_class="Evolution-alarm-notify"),  # evolution notifier
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        Match(wm_class="r_x11"),  # plots with R
        Match(wm_class="pinentry-gtk-2"),
        Match(wm_class="Matplotlib"),  # plots with Python
        Match(wm_class="file_progress"),
        Match(title="Execute File"),
        Match(title="Open"),
        Match(title="Confirm File Replacing"),
        Match(title="about"),
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True


@hook.subscribe.startup_once  # type: ignore
def startup_once() -> None:
    """Execute some applications at startup once when machine is booted."""
    subprocess.Popen(  # pylint: disable=consider-using-with
        [Path("~/.config/qtile/autostart.sh").expanduser()]
    )


@hook.subscribe.startup  # type: ignore
def startup() -> None:
    """Execute some applications at startup of qtile."""
    subprocess.Popen(  # pylint: disable=consider-using-with
        [Path("~/.config/qtile/startup.sh").expanduser()]
    )


# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
