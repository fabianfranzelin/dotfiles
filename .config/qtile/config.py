# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

"""My Qtile configuration."""


import subprocess
from pathlib import Path

from libqtile import bar, hook, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.dgroups import simple_key_binder
from libqtile.lazy import lazy

mod = "mod4"
my_term = "terminator"
my_browser = "firefox"

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
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
        [mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"
    ),
    Key(
        [mod, "shift"],
        "l",
        lazy.layout.shuffle_right(),
        desc="Move window to the right",
    ),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key(
        [mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"
    ),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
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
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    # --------------------------------------------------------
    # Personal key bindings
    Key(
        [mod, "shift"], "e", lazy.spawn("emacsclient -c -a emacs"), desc="Launch Emacs"
    ),
    Key([mod, "shift"], "Return", lazy.spawn(my_term), desc="Launch my terminal"),
    Key([mod, "shift"], "b", lazy.spawn(my_browser), desc="Launch my browser"),
    Key([mod, "shift"], "r", lazy.restart(), desc="Restart Qtile"),
    Key([mod, "shift"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawn("rofi -show run"), desc="Run Rofi"),
    Key([mod], "s", lazy.spawn(str(Path("~/.local/bin/rofi-shutdown").expanduser()))),
]

# --------------------------------------------------------

layout_theme = {
    "border_width": 1,
    "margin": 0,
    "border_focus": "e1acff",
    "border_normal": "1D2330",
}

layouts = [
    layout.MonadTall(**layout_theme),
    layout.Columns(**layout_theme),
    layout.Max(**layout_theme),
    layout.Floating(),
]

# --------------------------------------------------------

groups = [
    Group("Emacs", layout="monadtall"),
    Group("Code", layout="monadtall"),
    Group("Stuff", layout="monadtall"),
]


# Allow MODKEY+[0 through 9] to bind to groups, see
# https://docs.qtile.org/en/stable/manual/config/groups.html MOD4 +
# index Number : Switch to Group[index] MOD4 + shift + index Number :
# Send active window to another Group
dgroups_key_binder = simple_key_binder(mod)

# --------------------------------------------------------

# Based on the Emacs Doom vibrant theme
# https://github.com/doomemacs/themes/blob/master/themes/doom-vibrant-theme.el
my_colors = {
    "bg": "#282c34",
    "fg": "#bfbfbf",
    "dark-grey": "#1c1f24",
    "grey": "#5e5e5e",
    "red": "#ff6655" "red",
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

widget_defaults = dict(
    font="Ubuntu Bold",
    fontsize=14,
    padding=2,
    background=my_colors["bg"],
    foreground=my_colors["fg"],
)
extension_defaults = widget_defaults.copy()


def init_widgets_list():
    """Create my widgets for the top toolbar.

    :returns: List of widgets
    """
    widgets_list = [
        widget.GroupBox(
            font="Ubuntu Mono",
            margin_y=3,
            margin_x=0,
            padding_y=5,
            padding_x=5,
            borderwidth=3,
            active=my_colors["cyan"],
            inactive=my_colors["violet"],
            highlight_method="line",
            highlight_color=my_colors["dark-grey"],
        ),
        widget.Sep(linewidth=0, padding=6),
        widget.CurrentLayoutIcon(
            custom_icon_paths=[Path("~/.config/qtile/icons").expanduser()],
            padding=0,
            scale=0.7,
        ),
        widget.Sep(linewidth=0, padding=6),
        widget.WindowCount(fmt="#{}", font="Ubuntu Mono", foreground=my_colors["cyan"]),
        widget.Sep(linewidth=0, padding=6),
        widget.WindowName(
            font="Ubuntu Mono",
            foreground=my_colors["green"],
            padding=10,
        ),
        widget.Systray(padding=5),
        widget.Sep(linewidth=0, padding=6),
        widget.TextBox(
            text=" ",
            background=my_colors["violet"],
        ),
        widget.CPU(
            foreground=my_colors["dark-grey"],
            background=my_colors["violet"],
            mouse_callbacks={"Button1": lambda: qtile.cmd_spawn(my_term + " -e htop")},
        ),
        widget.TextBox(
            text=" ",
            background=my_colors["cyan"],
        ),
        widget.Memory(
            foreground=my_colors["dark-grey"],
            background=my_colors["cyan"],
            mouse_callbacks={"Button1": lambda: qtile.cmd_spawn(my_term + " -e htop")},
            fmt="Mem: {}",
            padding=5,
        ),
        widget.TextBox(
            text=" ",
            background=my_colors["violet"],
        ),
        widget.Clock(
            foreground=my_colors["dark-grey"],
            background=my_colors["violet"],
            format="%A, %B %d - %H:%M ",
        ),
    ]
    return widgets_list


screens = [
    Screen(top=bar.Bar(widgets=init_widgets_list(), opacity=1.0, size=20)),
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

dgroups_app_rules = []  # type: list
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
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        Match(wm_class="pinentry-gtk-2"),
        Match(wm_class="Matplotlib"),
        Match(wm_class="file_progress"),
        Match(wm_class="notification"),
        Match(wm_class="toolbar"),
        Match(wm_class="splash"),
        Match(wm_class="dialog"),
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


@hook.subscribe.startup_once
def startup_once():
    """Execute some applications at startup once when machine is booted."""
    subprocess.Popen(  # pylint: disable=consider-using-with
        [Path("~/.config/qtile/autostart.sh").expanduser()]
    )


@hook.subscribe.startup
def startup():
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
