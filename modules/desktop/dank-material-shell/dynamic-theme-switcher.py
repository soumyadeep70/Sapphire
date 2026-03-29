from pydbus import SessionBus
from gi.repository import GLib, Gio
import configparser
from pathlib import Path

color_scheme = None
home = Path.home()

def generate_gtk_settings():
    gtk2_3_settings = {
        "gtk-cursor-theme-name": "Bibata-Modern-Ice",
        "gtk-font-name": "Inter 11",
        "gtk-icon-theme-name": "Papirus-Dark" if color_scheme == "dark" else "Papirus",
        "gtk-theme-name": "Adwaita-dark" if color_scheme == "dark" else "Adwaita",
    }
    gtk4_settings = {
        "gtk-cursor-theme-name": "Bibata-Modern-Ice",
        "gtk-font-name": "Inter 11",
        "gtk-icon-theme-name": "Papirus-Dark" if color_scheme == "dark" else "Papirus",
    }

    gtk2_path = home / ".gtkrc-2.0"
    with open(gtk2_path, "w") as f:
        for k, v in gtk2_3_settings.items():
            f.write(f'{k} = "{v}"\n')

    gtk3_path = home / ".config/gtk-3.0/settings.ini"
    gtk3_path.parent.mkdir(parents=True, exist_ok=True)
    with open(gtk3_path, "w") as f:
        config = configparser.ConfigParser()
        config["Settings"] = gtk2_3_settings
        config.write(f)

    gtk4_path = home / ".config/gtk-4.0/settings.ini"
    gtk4_path.parent.mkdir(parents=True, exist_ok=True)
    with open(gtk4_path, "w") as f:
        config = configparser.ConfigParser()
        config["Settings"] = gtk4_settings
        config.write(f)


def change_theme():
    settings = Gio.Settings.new("org.gnome.desktop.interface")
    settings.set_string("gtk-theme", "Adwaita-dark" if color_scheme == "dark" else "Adwaita")
    generate_gtk_settings()
    print(f"Theme {color_scheme} applied successfully", flush=True)


def on_setting_changed(namespace, key, value):
    global color_scheme

    if key != "color-scheme":
        return

    try:
        value = value.unpack()
    except Exception:
        pass

    value = "dark" if value in (1, "prefer-dark") else "light"
    print(f"Detected theme: {value}", flush=True)
    if value != color_scheme:
        color_scheme = value
        change_theme()


bus = SessionBus()
portal = bus.get("org.freedesktop.portal.Desktop", "/org/freedesktop/portal/desktop")
portal.onSettingChanged = on_setting_changed

appearance = portal.Read("org.freedesktop.appearance", "color-scheme")
color_scheme = "dark" if appearance == 1 else "light"
change_theme()

GLib.MainLoop().run()