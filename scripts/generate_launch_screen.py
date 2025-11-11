#!/usr/bin/env python3
"""
Generate a simple launch screen image for iOS.
Shows the wallet icon centered on a solid background.
"""

from PIL import Image, ImageDraw
import os

def create_launch_screen():
    """Create simple launch screen with centered icon"""

    # Launch screen dimensions (we'll create @1x, @2x, @3x)
    # Using a square base that works well centered
    base_size = 400  # Base size for @1x

    # Colors matching the app theme
    background_color = "#1A1A1A"  # Dark gray (minimalist theme)

    # Load the app icon
    icon_path = os.path.join(
        os.path.dirname(os.path.dirname(__file__)),
        'assets', 'icons', 'app_icon.png'
    )

    if not os.path.exists(icon_path):
        print(f"❌ Error: App icon not found at {icon_path}")
        return

    # Load icon and resize to appropriate size
    icon = Image.open(icon_path)
    icon_size = int(base_size * 0.5)  # Icon takes 50% of screen width
    icon = icon.resize((icon_size, icon_size), Image.Resampling.LANCZOS)

    # Create launch screens for different resolutions
    scales = {
        '1x': 1,
        '2x': 2,
        '3x': 3
    }

    output_dir = os.path.join(
        os.path.dirname(os.path.dirname(__file__)),
        'ios', 'Runner', 'Assets.xcassets', 'LaunchImage.imageset'
    )

    for scale_name, scale_factor in scales.items():
        # Calculate dimensions for this scale
        width = base_size * scale_factor
        height = base_size * scale_factor
        icon_scaled_size = icon_size * scale_factor

        # Create image with background
        img = Image.new('RGB', (width, height), background_color)

        # Scale the icon for this resolution
        icon_scaled = icon.resize(
            (icon_scaled_size, icon_scaled_size),
            Image.Resampling.LANCZOS
        )

        # Center the icon
        x = (width - icon_scaled_size) // 2
        y = (height - icon_scaled_size) // 2

        # Paste icon onto background
        img.paste(icon_scaled, (x, y))

        # Save with appropriate filename
        if scale_name == '1x':
            filename = 'LaunchImage.png'
        else:
            filename = f'LaunchImage@{scale_name}.png'

        output_path = os.path.join(output_dir, filename)
        img.save(output_path, 'PNG')
        print(f"✅ Created: {filename} ({width}x{height})")

    print(f"\n✅ Launch screen images created successfully!")
    print(f"   Location: {output_dir}")
    print(f"   Design: Wallet icon centered on dark background")

if __name__ == '__main__':
    create_launch_screen()
