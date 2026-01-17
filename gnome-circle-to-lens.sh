cat > /tmp/install-gnome-circle-to-lens.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# ---- 0) Basic info ----
echo "[*] Installing GNOME Circle to Lens (Wayland/GNOME portal method)"

# ---- 1) Install dependencies (Debian/Kali) ----
echo "[*] Installing dependencies via apt..."
sudo apt update
sudo apt install -y \
  xdg-desktop-portal xdg-desktop-portal-gnome \
  python3 python3-dbus python3-gi gir1.2-glib-2.0 \
  wl-clipboard curl jq xdg-utils

# ---- 2) Create ~/bin ----
BIN_DIR="$HOME/bin"
mkdir -p "$BIN_DIR"

# ---- 3) Write portal-screenshot.py ----
PORTAL_PY="$BIN_DIR/portal-screenshot.py"
cat > "$PORTAL_PY" <<'PYEOF'
#!/usr/bin/env python3
import os
import sys
import urllib.parse

import dbus
import dbus.mainloop.glib
from gi.repository import GLib

def main():
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    bus = dbus.SessionBus()

    portal = bus.get_object(
        "org.freedesktop.portal.Desktop",
        "/org/freedesktop/portal/desktop",
    )

    screenshot_iface = dbus.Interface(portal, "org.freedesktop.portal.Screenshot")

    token = f"gctl{os.getpid()}"
    opts = dbus.Dictionary({
        "interactive": dbus.Boolean(True),
        "handle_token": dbus.String(token),
    }, signature="sv")

    req_path = screenshot_iface.Screenshot("", opts)

    loop = GLib.MainLoop()

    def on_response(response, results):
        if int(response) != 0:
            print("ERROR: screenshot cancelled or failed", file=sys.stderr)
            loop.quit()
            sys.exit(1)

        uri = dict(results).get("uri")
        if not uri:
            print("ERROR: portal did not return a uri", file=sys.stderr)
            loop.quit()
            sys.exit(2)

        parsed = urllib.parse.urlparse(str(uri))
        path = urllib.parse.unquote(parsed.path)
        print(path)
        loop.quit()

    bus.add_signal_receiver(
        on_response,
        dbus_interface="org.freedesktop.portal.Request",
        signal_name="Response",
        path=req_path,
    )

    loop.run()

if __name__ == "__main__":
    main()
PYEOF

# ---- 4) Write gnome-circle-to-lens ----
LENS_SH="$BIN_DIR/gnome-circle-to-lens"
cat > "$LENS_SH" <<'SHEOF'
#!/usr/bin/env bash
set -euo pipefail

img="$("$HOME/bin/portal-screenshot.py")"

# Copy to clipboard (handy fallback)
wl-copy < "$img" || true

# Upload (uguu) and open Lens
url="$(curl -sS -F "files[]=@${img}" https://uguu.se/upload | jq -r '.files[0].url')"

if [[ -z "${url}" || "${url}" == "null" ]]; then
  echo "ERROR: upload failed (no URL returned)." >&2
  exit 1
fi

# Clean up the temporary screenshot file
rm -f "$img"

nohup xdg-open "https://lens.google.com/uploadbyurl?url=${url}" >/dev/null 2>&1 &
SHEOF

# ---- 5) Make executable ----
chmod +x "$PORTAL_PY" "$LENS_SH"

# ---- 6) Ensure ~/bin is on PATH for future shells ----
ensure_path_line='export PATH="$HOME/bin:$PATH"'

add_to_rc_if_missing() {
  local rc="$1"
  if [[ -f "$rc" ]]; then
    if ! grep -Fq "$ensure_path_line" "$rc"; then
      echo "" >> "$rc"
      echo "# Added by GNOME Circle to Lens installer" >> "$rc"
      echo "$ensure_path_line" >> "$rc"
      echo "[*] Added ~/bin to PATH in $rc"
    fi
  fi
}

add_to_rc_if_missing "$HOME/.bashrc"
add_to_rc_if_missing "$HOME/.zshrc"

# ---- 7) PATH for current session (so it works immediately) ----
export PATH="$HOME/bin:$PATH"

echo ""
echo "[✓] Installed successfully."
echo "Next:"
echo "  1) Run: gnome-circle-to-lens"
echo "  2) (Optional) bind it to a GNOME keyboard shortcut (e.g. Super+z) for quick access!"
EOF

bash /tmp/install-gnome-circle-to-lens.sh
