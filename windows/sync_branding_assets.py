from __future__ import annotations

from pathlib import Path
import sys

try:
    from PIL import Image
except ModuleNotFoundError as exc:  # pragma: no cover - runtime guard
    raise SystemExit(
        "Pillow is required to refresh Windows branding assets. "
        "Install it in the active Python environment before running this script."
    ) from exc


ICON_SIZES = [(16, 16), (20, 20), (24, 24), (32, 32), (40, 40), (48, 48), (64, 64), (128, 128), (256, 256)]


def main() -> int:
    windows_dir = Path(__file__).resolve().parent
    app_root = windows_dir.parent
    external_root = app_root.parent.parent
    source_icon = external_root / "logogo.png"
    target_icon = windows_dir / "runner" / "resources" / "app_icon.ico"

    if not source_icon.exists():
        raise SystemExit(f"Windows branding source icon is missing: {source_icon}")

    target_icon.parent.mkdir(parents=True, exist_ok=True)
    with Image.open(source_icon) as image:
        image.convert("RGBA").save(target_icon, format="ICO", sizes=ICON_SIZES)

    print(f"Refreshed Windows icon from {source_icon} -> {target_icon}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
