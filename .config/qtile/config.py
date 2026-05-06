"""My Qtile configuration."""

import re
import subprocess
from pathlib import Path
from typing import Any

from libqtile import bar, hook, layout, qtile, widget  # type: ignore
from libqtile.config import Click, Drag, Group, Key, Match, Screen  # type: ignore
from libqtile.dgroups import simple_key_binder  # type: ignore
from libqtile.lazy import lazy  # type: ignore

mod = "mod4"
my_term = "ghostty"
my_browser = "firefox"

keys = [
    Key(
        [mod, "control"],
        "i",
        lazy.spawn(
            f"{my_term} -e bash -c '{str(Path('~/.local/bin/init').expanduser())} || bash'"
        ),
        desc="Run init script in terminal",
    ),
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
    Key(
        [mod, "control"],
        "o",
        lazy.next_screen(),
        desc="Navigate to next screen",
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
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    # Lock screen
    Key(
        [mod, "shift"],
        "x",
        lazy.spawn(
            str(Path("~/.local/bin/betterlockscreen").expanduser())
            + " -l dimblur -u "
            + str(
                Path(
                    "~/.local/share/backgrounds/pexels-eberhardgross-12365567.jpg"
                ).expanduser()
            )
        ),
        desc="Lock screen and update wallpaper",
    ),
    Key(
        [mod],
        "x",
        lazy.spawn(
            str(Path("~/.local/bin/betterlockscreen").expanduser()) + " -l dimblur"
        ),
        desc="Lock screen",
    ),
    # --------------------------------------------------------
    # Personal key bindings
    Key(
        [mod, "shift"], "e", lazy.spawn("emacsclient -c -a emacs"), desc="Launch Emacs"
    ),
    Key([mod, "shift"], "d", lazy.spawn("emacs --daemon"), desc="Launch Emacs server"),
    Key([mod, "shift"], "Return", lazy.spawn(my_term), desc="Launch my terminal"),
    Key([mod, "shift"], "b", lazy.spawn(my_browser), desc="Launch my browser"),
    Key([mod, "shift"], "r", lazy.reload_config(), desc="Restart Qtile"),
    Key([mod, "shift"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawn("rofi -show run"), desc="Run Rofi"),
    Key([mod], "a", lazy.spawn(str(Path("~/.local/bin/rofi-main").expanduser()))),
    Key(
        [mod],
        "s",
        lazy.spawn("rofi -show p -modi p:~/.local/bin/rofi-power-menu"),
    ),
    # Brightness
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl set 10%-")),
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl set +10%")),
    # Screenshot
    Key([mod], "p", lazy.spawn("flameshot gui"), desc="Screenshot with Flameshot"),
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
    layout.MonadTall(name="\uf0db", **layout_theme),
    layout.Columns(name="\uf009", **layout_theme),
    layout.Max(name="\uf2d0", **layout_theme),
    layout.Floating(name="\uf24d", **layout_theme),
    layout.Matrix(name="\uf00a", **layout_theme),
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
    Group("Other", layout="monadtall"),
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
                lazy.window.togroup(group.name),
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
    "font": "JetBrainsMono Nerd Font",
    "fontsize": 14,
    "padding": 4,
    "background": my_colors["bg"],
    "foreground": my_colors["fg"],
}
extension_defaults = widget_defaults.copy()


def init_widgets_list(hide_sys_tray: bool = False) -> list[Any]:
    """Create my widgets for the top toolbar.

    :returns: List of widgets
    """
    widgets_list = [
        widget.GroupBox(
            margin_y=3,
            margin_x=4,
            padding_y=5,
            padding_x=5,
            borderwidth=3,
            active=my_colors["fg"],
            inactive=my_colors["grey"],
            highlight_method="block",
            highlight_color=my_colors["dark-grey"],
            block_highlight_text_color=my_colors["dark-grey"],
            this_current_screen_border=my_colors["blue"],
            this_screen_border=my_colors["dark-blue"],
            other_current_screen_border=my_colors["magenta"],
            urgent_border=my_colors["red"],
            rounded=False,
        ),
        widget.Sep(linewidth=1, padding=10, foreground=my_colors["grey"]),
        widget.CurrentLayout(
            foreground=my_colors["cyan"],
            padding=8,
        ),
        widget.Sep(linewidth=1, padding=10, foreground=my_colors["grey"]),
        widget.WindowCount(
            fmt="\uf2d2 {}",
            foreground=my_colors["violet"],
        ),
        widget.Sep(linewidth=1, padding=10, foreground=my_colors["grey"]),
        widget.WindowName(
            foreground=my_colors["fg"],
            padding=10,
            max_chars=50,
        ),
    ]
    if not hide_sys_tray:
        widgets_list += [
            widget.Systray(padding=8),
            widget.Spacer(length=10),
        ]
    widgets_list += [
        widget.Sep(linewidth=1, padding=10, foreground=my_colors["grey"]),
        widget.TextBox(
            "\uf028",
            foreground=my_colors["green"],
            padding=6,
        ),
        widget.PulseVolume(
            foreground=my_colors["green"],
            padding=4,
        ),
        widget.Sep(linewidth=1, padding=10, foreground=my_colors["grey"]),
        widget.TextBox(
            "\uf0eb",
            foreground=my_colors["yellow"],
            padding=6,
        ),
        widget.Backlight(
            backlight_name="intel_backlight",
            foreground=my_colors["yellow"],
            padding=4,
        ),
        widget.Sep(linewidth=1, padding=10, foreground=my_colors["grey"]),
        widget.TextBox(
            "\uf244",
            foreground=my_colors["teal"],
            padding=6,
        ),
        widget.Battery(
            foreground=my_colors["teal"],
            format="{percent:2.0%} {hour:d}:{min:02d}",
            low_foreground=my_colors["red"],
            low_percentage=0.15,
            padding=4,
        ),
        widget.Sep(linewidth=1, padding=10, foreground=my_colors["grey"]),
        widget.TextBox(
            "\uf2db",
            foreground=my_colors["orange"],
            padding=6,
        ),
        widget.CPU(
            foreground=my_colors["orange"],
            format="{load_percent}%",
            mouse_callbacks={"Button1": lambda: qtile.spawn(my_term + " -e htop")},
            padding=4,
        ),
        widget.Sep(linewidth=1, padding=10, foreground=my_colors["grey"]),
        widget.TextBox(
            "\uf085",
            foreground=my_colors["magenta"],
            padding=6,
        ),
        widget.Memory(
            foreground=my_colors["magenta"],
            format="{MemUsed:.1f}{mm}/{MemTotal:.1f}{mm}",
            measure_mem="G",
            padding=4,
        ),
        widget.Sep(linewidth=1, padding=10, foreground=my_colors["grey"]),
        widget.TextBox(
            "\uf073",
            foreground=my_colors["blue"],
            padding=6,
        ),
        widget.Clock(
            foreground=my_colors["blue"],
            format="%a %b %d  %H:%M",
            padding=4,
        ),
        widget.Spacer(length=4),
    ]
    return widgets_list


screens = [
    Screen(
        top=bar.Bar(
            widgets=init_widgets_list(),
            opacity=0.95,
            size=24,
            margin=[4, 8, 0, 8],
        )
    ),
    Screen(
        top=bar.Bar(
            widgets=init_widgets_list(hide_sys_tray=True),
            opacity=0.95,
            size=24,
            margin=[4, 8, 0, 8],
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

dgroups_app_rules: list[Any] = []
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


@hook.subscribe.startup  # type: ignore
def startup() -> None:
    """Execute some applications at startup of qtile."""
    subprocess.Popen(  # pylint: disable=consider-using-with
        [Path("~/.config/qtile/startup.sh").expanduser()]
    )


# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None
