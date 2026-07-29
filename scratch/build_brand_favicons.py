import os
from PIL import Image, ImageDraw

def render_stageup_icon(size):
    # High-resolution rendering canvas (4x supersampled for crisp anti-aliasing)
    supersample = 4
    canvas_size = size * supersample
    scale = canvas_size / 100.0

    img = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 1. Gradient background (Orange #F97316 to #C2410C)
    radius = int(26 * scale)
    base_box = [(0, 0), (canvas_size, canvas_size)]

    # Draw rounded squircle
    draw.rounded_rectangle(base_box, radius=radius, fill=(234, 88, 12, 255))

    # Gradient highlight on top-half
    gradient_overlay = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    g_draw = ImageDraw.Draw(gradient_overlay)
    for y in range(canvas_size):
        alpha = int(60 * (1.0 - (y / float(canvas_size))))
        g_draw.line([(0, y), (canvas_size, y)], fill=(249, 115, 22, alpha))

    # Mask gradient to rounded squircle
    mask = Image.new("L", (canvas_size, canvas_size), 0)
    m_draw = ImageDraw.Draw(mask)
    m_draw.rounded_rectangle(base_box, radius=radius, fill=255)
    img.paste(gradient_overlay, (0, 0), mask)

    # 2. Inner border highlight ring
    b_margin = int(2 * scale)
    b_radius = int(24 * scale)
    b_box = [(b_margin, b_margin), (canvas_size - b_margin, canvas_size - b_margin)]
    draw.rounded_rectangle(b_box, radius=b_radius, outline=(255, 255, 255, 75), width=max(2, int(3 * scale)))

    # 3. Bold, crisp, high-contrast white lightning bolt
    bolt_points_100 = [
        (62, 12),
        (34, 48),
        (52, 48),
        (38, 88),
        (68, 44),
        (48, 44)
    ]
    scaled_bolt = [(x * scale, y * scale) for x, y in bolt_points_100]
    draw.polygon(scaled_bolt, fill=(255, 255, 255, 255))

    # Downsample back to target size with Lanczos anti-aliasing
    final_img = img.resize((size, size), Image.Resampling.LANCZOS)
    return final_img

def main():
    print("Generating updated StageUp brand favicons and app icons...")

    # Define all target files and sizes
    targets = [
        ("public/icon.png", 512),
        ("public/android-chrome-512.png", 512),
        ("public/android-chrome-192.png", 192),
        ("public/apple-touch-icon.png", 180),
    ]

    for filepath, size in targets:
        icon = render_stageup_icon(size)
        icon.save(filepath, "PNG")
        print(f"Saved {filepath} ({size}x{size})")

    # Generate multi-size favicon.ico
    ico_sizes = [16, 32, 48, 64]
    ico_images = [render_stageup_icon(s) for s in ico_sizes]
    ico_images[0].save(
        "public/favicon.ico",
        format="ICO",
        sizes=[(s, s) for s in ico_sizes],
        append_images=ico_images[1:]
    )
    print("Saved public/favicon.ico (Multi-size 16x16, 32x32, 48x48, 64x64)")

    # Update public/favicon.svg and logo SVGs
    svg_content = '''<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="stageup-fav-grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#F97316" />
      <stop offset="50%" stop-color="#EA580C" />
      <stop offset="100%" stop-color="#C2410C" />
    </linearGradient>
  </defs>
  <rect width="100" height="100" rx="26" fill="url(#stageup-fav-grad)"/>
  <rect width="96" height="96" x="2" y="2" rx="24" fill="none" stroke="rgba(255, 255, 255, 0.25)" stroke-width="3"/>
  <polygon points="62,12 34,48 52,48 38,88 68,44 48,44" fill="#FFFFFF"/>
</svg>
'''
    svg_files = [
        "public/favicon.svg",
        "public/icon.svg",
        "public/logo-primary.svg",
        "public/logo-light.svg",
        "public/logo-monochrome.svg"
    ]
    for fpath in svg_files:
        with open(fpath, "w", encoding="utf-8") as f:
            f.write(svg_content)
        print(f"Updated {fpath}")

    print("All favicon and logo assets updated successfully!")

if __name__ == "__main__":
    main()
