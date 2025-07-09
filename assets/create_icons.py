import os
from PIL import Image, ImageDraw

def create_food_icon(size):
    """Create a food-themed app icon"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Scale factor for different sizes
    scale = size / 512
    
    # Background circle
    margin = int(16 * scale)
    draw.ellipse([margin, margin, size-margin, size-margin], 
                fill=(255, 107, 53), outline=(229, 90, 43), width=int(8*scale))
    
    # Chef hat
    hat_center_x = size // 2
    hat_center_y = int(180 * scale)
    hat_width = int(160 * scale)
    hat_height = int(60 * scale)
    
    # Hat top (ellipse)
    draw.ellipse([hat_center_x - hat_width//2, hat_center_y - hat_height//2,
                  hat_center_x + hat_width//2, hat_center_y + hat_height//2],
                 fill=(255, 255, 255))
    
    # Hat band
    band_y = int(180 * scale)
    draw.rectangle([hat_center_x - hat_width//2, band_y,
                    hat_center_x + hat_width//2, band_y + int(40 * scale)],
                   fill=(255, 255, 255))
    
    # Hat band shadow
    draw.rectangle([hat_center_x - hat_width//2, band_y + int(40 * scale),
                    hat_center_x + hat_width//2, band_y + int(48 * scale)],
                   fill=(224, 224, 224))
    
    # Cooking pot
    pot_center_x = size // 2
    pot_center_y = int(320 * scale)
    pot_width = int(180 * scale)
    pot_height = int(160 * scale)
    
    draw.ellipse([pot_center_x - pot_width//2, pot_center_y - pot_height//2,
                  pot_center_x + pot_width//2, pot_center_y + pot_height//2],
                 fill=(74, 74, 74))
    
    # Pot rim
    draw.ellipse([pot_center_x - pot_width//2, pot_center_y - pot_height//2 - int(10 * scale),
                  pot_center_x + pot_width//2, pot_center_y - pot_height//2 + int(20 * scale)],
                 fill=(90, 90, 90))
    
    # Steam lines (simplified)
    steam_color = (224, 224, 224)
    steam_width = max(1, int(4 * scale))
    
    for i, x_offset in enumerate([-26, 0, 26]):
        x = pot_center_x + int(x_offset * scale)
        y_start = pot_center_y - int(40 * scale)
        y_end = pot_center_y - int(120 * scale)
        
        # Simple wavy line approximation
        for j in range(0, int(80 * scale), int(8 * scale)):
            y = y_start - j
            x_wave = x + int(10 * scale * (1 if j % int(16 * scale) < int(8 * scale) else -1))
            if y > y_end:
                draw.ellipse([x_wave - steam_width, y - steam_width,
                             x_wave + steam_width, y + steam_width],
                            fill=steam_color)
    
    # Food items in pot
    food_items = [
        (int(-16 * scale), int(10 * scale), int(8 * scale), (255, 68, 68)),  # Red
        (int(16 * scale), int(5 * scale), int(6 * scale), (68, 255, 68)),   # Green
        (int(4 * scale), int(20 * scale), int(7 * scale), (255, 170, 68))   # Orange
    ]
    
    for x_offset, y_offset, radius, color in food_items:
        x = pot_center_x + x_offset
        y = pot_center_y + y_offset
        draw.ellipse([x - radius, y - radius, x + radius, y + radius], fill=color)
    
    return img

def create_all_android_icons():
    """Create Android app icons in all required sizes"""
    android_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192
    }
    
    for folder, size in android_sizes.items():
        icon = create_food_icon(size)
        folder_path = f'android/app/src/main/res/{folder}'
        os.makedirs(folder_path, exist_ok=True)
        icon.save(f'{folder_path}/ic_launcher.png')
        print(f'Created {folder}/ic_launcher.png ({size}x{size})')

def create_all_ios_icons():
    """Create iOS app icons in all required sizes"""
    ios_icons = {
        'Icon-App-20x20@1x.png': 20,
        'Icon-App-20x20@2x.png': 40,
        'Icon-App-20x20@3x.png': 60,
        'Icon-App-29x29@1x.png': 29,
        'Icon-App-29x29@2x.png': 58,
        'Icon-App-29x29@3x.png': 87,
        'Icon-App-40x40@1x.png': 40,
        'Icon-App-40x40@2x.png': 80,
        'Icon-App-40x40@3x.png': 120,
        'Icon-App-60x60@2x.png': 120,
        'Icon-App-60x60@3x.png': 180,
        'Icon-App-76x76@1x.png': 76,
        'Icon-App-76x76@2x.png': 152,
        'Icon-App-83.5x83.5@2x.png': 167,
        'Icon-App-1024x1024@1x.png': 1024
    }
    
    folder_path = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    for filename, size in ios_icons.items():
        icon = create_food_icon(size)
        icon.save(f'{folder_path}/{filename}')
        print(f'Created {filename} ({size}x{size})')

def create_all_web_icons():
    """Create web app icons"""
    web_icons = {
        'Icon-192.png': 192,
        'Icon-512.png': 512,
        'Icon-maskable-192.png': 192,
        'Icon-maskable-512.png': 512
    }
    
    folder_path = 'web/icons'
    for filename, size in web_icons.items():
        icon = create_food_icon(size)
        icon.save(f'{folder_path}/{filename}')
        print(f'Created {filename} ({size}x{size})')

if __name__ == '__main__':
    print('Creating food-themed app icons...')
    create_all_android_icons()
    create_all_ios_icons()
    create_all_web_icons()
    print('All icons created successfully!')