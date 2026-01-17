# GNOME Circle to Lens

Circle-to-Search style capture for GNOME on Wayland that uploads the selected region and opens Google Lens for visual search.

It uses GNOME's xdg-desktop-portal picker (Wayland-friendly), copies the image to your clipboard, uploads it to a temporary host, and opens Google Lens in your default browser.

## Demo

[![Watch the video]](https://github.com/nishantaMishra/gnome-circle-to-lens/blob/main/example.mp4)

<video controls width="720">
	<source src="example.mp4" type="video/mp4">
	Your browser does not support the video tag. <a href="example.mp4">Watch the demo</a>.
</video>

> Tip: Set a keyboard shortcut (e.g., Super+Z) for instant Circle-to-Search on Linux!

## Install
From this repository, run the installer wrapper:

```bash
bash gnome-circle-to-lens.sh
```

What the installer does:
- Installs dependencies via `apt`
- Creates two executables in `~/bin`:
	- `portal-screenshot.py` (invokes the GNOME portal and returns the image path)
	- `gnome-circle-to-lens` (uploads the image and opens Lens)
- Ensures `~/bin` is on your `PATH` by appending to `~/.bashrc`/`~/.zshrc`

## Usage
After installation, run:

```bash
gnome-circle-to-lens
```

Tip: Bind it to a keyboard shortcut for a Circle-to-Search feel.

## Keyboard Shortcut (GNOME)
1. Open Settings → Keyboard → Keyboard Shortcuts.
2. Click “Custom Shortcuts” → “Add Shortcut”.
3. Name: "Circle to Lens". Command: `gnome-circle-to-lens`.
4. Set a convenient shortcut (e.g., Super+Z).


## Uninstall
Remove the installed commands:

```bash
rm -f "$HOME/bin/gnome-circle-to-lens" "$HOME/bin/portal-screenshot.py"
```

Optionally remove the PATH line added by the installer from `~/.bashrc` and/or `~/.zshrc` (look for a comment “Added by GNOME Circle to Lens installer”). You can also remove the packages if you installed them solely for this tool.

## Security & Privacy
- The screenshot is uploaded to a third-party temporary hosting service (`uguu.se`) and then accessed by Google Lens. Treat captured content accordingly.
- The temporary local file is deleted after upload.
