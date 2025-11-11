#!/usr/bin/env python3
"""
Generate a temporary wallet icon for the expense tracker app.
This creates a simple, functional icon that can be refined later.
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_wallet_icon():
    """Create a simple wallet icon with modern minimalist design"""

    # Icon size
    size = 1024

    # Colors (matching minimalist theme)
    background_color = "#1A1A1A"  # Dark gray (minimalist theme)
    wallet_color = "#FFFFFF"      # White wallet shape
    accent_color = "#4A4A4A"      # Medium gray for details

    # Create image with background
    img = Image.new('RGB', (size, size), background_color)
    draw = ImageDraw.Draw(img)

    # Calculate dimensions for wallet shape
    padding = size * 0.20  # 20% padding
    wallet_width = size - (2 * padding)
    wallet_height = wallet_width * 0.65  # Wallet aspect ratio

    # Center the wallet
    x = padding
    y = (size - wallet_height) / 2

    # Draw wallet body (rounded rectangle)
    wallet_radius = size * 0.08
    draw.rounded_rectangle(
        [x, y, x + wallet_width, y + wallet_height],
        radius=wallet_radius,
        fill=wallet_color
    )

    # Draw wallet fold line (top third)
    fold_y = y + (wallet_height * 0.30)
    fold_padding = size * 0.03
    draw.line(
        [x + fold_padding, fold_y, x + wallet_width - fold_padding, fold_y],
        fill=accent_color,
        width=int(size * 0.015)
    )

    # Draw card slots (3 small rectangles)
    card_width = wallet_width * 0.25
    card_height = wallet_height * 0.08
    card_spacing = wallet_width * 0.05
    card_start_x = x + (wallet_width - (3 * card_width + 2 * card_spacing)) / 2
    card_y = y + wallet_height * 0.45

    for i in range(3):
        card_x = card_start_x + (i * (card_width + card_spacing))
        draw.rounded_rectangle(
            [card_x, card_y, card_x + card_width, card_y + card_height],
            radius=size * 0.01,
            fill=accent_color
        )

    # Draw currency symbol (₫) below cards
    try:
        # Try to use a system font
        font_size = int(size * 0.25)
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)

        # Draw ₫ symbol
        symbol = "₫"

        # Get text bounding box for centering
        bbox = draw.textbbox((0, 0), symbol, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]

        text_x = (size - text_width) / 2
        text_y = y + wallet_height * 0.68

        draw.text(
            (text_x, text_y),
            symbol,
            fill=accent_color,
            font=font
        )
    except Exception as e:
        print(f"Note: Could not add currency symbol: {e}")

    # Save the icon
    output_path = os.path.join(
        os.path.dirname(os.path.dirname(__file__)),
        'assets', 'icons', 'app_icon.png'
    )

    img.save(output_path, 'PNG')
    print(f"✅ Icon created: {output_path}")
    print(f"   Size: {size}x{size} pixels")
    print(f"   This is a temporary icon - you can refine it later!")

    return output_path

if __name__ == '__main__':
    create_wallet_icon()
