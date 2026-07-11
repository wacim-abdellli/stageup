import os
from PIL import Image, ImageDraw

def generate_logo(size):
    # Create image with transparent background
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    scale = size / 64.0
    
    # Draw indigo rounded rectangle
    # rx = 16. Box covers 0,0 to size,size
    r = int(16 * scale)
    draw.rounded_rectangle([(0, 0), (size, size)], radius=r, fill=(79, 70, 229, 255))
    
    # Draw lower-left circle: cx=17, cy=45, r=5.5
    cx1, cy1 = 17 * scale, 45 * scale
    r1 = 5.5 * scale
    draw.ellipse([cx1 - r1, cy1 - r1, cx1 + r1, cy1 + r1], fill=(255, 255, 255, 255))
    
    # Draw upper-right circle: cx=47, cy=19, r=5.5
    cx2, cy2 = 47 * scale, 19 * scale
    r2 = 5.5 * scale
    draw.ellipse([cx2 - r2, cy2 - r2, cx2 + r2, cy2 + r2], fill=(255, 255, 255, 255))
    
    # Draw ascending arc: Q bezier from (21.5, 42.5) to (42.5, 22.5) with control (34, 37)
    # Stroke width = 4.5
    p0 = (21.5 * scale, 42.5 * scale)
    p1 = (34.0 * scale, 37.0 * scale)
    p2 = (42.5 * scale, 22.5 * scale)
    
    stroke_radius = (4.5 * scale) / 2.0
    
    # Draw bezier by stamp-drawing circles along the path
    steps = 200
    for i in range(steps + 1):
        t = i / float(steps)
        # Quadratic bezier formula: B(t) = (1-t)^2*P0 + 2(1-t)*t*P1 + t^2*P2
        x = (1 - t)**2 * p0[0] + 2 * (1 - t) * t * p1[0] + t**2 * p2[0]
        y = (1 - t)**2 * p0[1] + 2 * (1 - t) * t * p1[1] + t**2 * p2[1]
        
        # Stamp a circle
        draw.ellipse([x - stroke_radius, y - stroke_radius, x + stroke_radius, y + stroke_radius], fill=(255, 255, 255, 255))
        
    return img

def main():
    print("Generating StageUp branding assets...")
    
    # 1. Generate 512x512 PWA App Icon
    icon_512 = generate_logo(512)
    icon_512.save("public/icon.png", "PNG")
    print("Saved public/icon.png (512x512)")
    
    # 2. Generate Favicon sizes
    sizes = [16, 32, 48]
    images = []
    for s in sizes:
        images.append(generate_logo(s))
        
    # Save as multi-resolution ICO
    images[0].save(
        "public/favicon.ico",
        format="ICO",
        sizes=[(16, 16), (32, 32), (48, 48)],
        append_images=images[1:]
    )
    print("Saved public/favicon.ico (Multi-size 16x16, 32x32, 48x48)")
    
    print("Asset generation complete!")

if __name__ == "__main__":
    main()
