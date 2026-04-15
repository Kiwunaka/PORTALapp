from __future__ import annotations

from io import BytesIO
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
ICON_CANVAS_SIZE = 1024
ICON_PADDING_RATIO = 0.14


def _prepare_icon_canvas(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    alpha_bbox = rgba.getchannel("A").getbbox()
    if alpha_bbox is None:
        raise SystemExit("Windows branding source icon has no visible alpha content to crop.")

    cropped = rgba.crop(alpha_bbox)
    source_size = max(cropped.width, cropped.height)
    target_size = max(1, int(round(ICON_CANVAS_SIZE * (1.0 - (ICON_PADDING_RATIO * 2.0)))))
    scale = min(target_size / cropped.width, target_size / cropped.height)
    resized_size = (
        max(1, int(round(cropped.width * scale))),
        max(1, int(round(cropped.height * scale))),
    )
    resized = cropped.resize(resized_size, Image.Resampling.LANCZOS)

    canvas = Image.new("RGBA", (ICON_CANVAS_SIZE, ICON_CANVAS_SIZE), (0, 0, 0, 0))
    origin = (
        (ICON_CANVAS_SIZE - resized.width) // 2,
        (ICON_CANVAS_SIZE - resized.height) // 2,
    )
    canvas.alpha_composite(resized, dest=origin)
    return canvas


def main() -> int:
    windows_dir = Path(__file__).resolve().parent
    app_root = windows_dir.parent
    source_icon = app_root / "assets" / "images" / "source" / "ic_launcher_foreground.png"
    target_icon = windows_dir / "runner" / "resources" / "app_icon.ico"

    if not source_icon.exists():
        raise SystemExit(f"Windows branding source icon is missing: {source_icon}")

    target_icon.parent.mkdir(parents=True, exist_ok=True)
    with Image.open(source_icon) as image:
        icon_canvas = _prepare_icon_canvas(image)
        rendered = BytesIO()
        icon_canvas.save(rendered, format="ICO", sizes=ICON_SIZES)
        rendered_bytes = rendered.getvalue()

    current_bytes = target_icon.read_bytes() if target_icon.exists() else None
    if current_bytes == rendered_bytes:
        print(f"Windows icon already up to date at {target_icon}")
        return 0

    target_icon.write_bytes(rendered_bytes)

    print(f"Refreshed Windows icon from {source_icon} -> {target_icon}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
