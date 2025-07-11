import xml.etree.ElementTree as ET
import struct
import zlib
import re

def parse_svg_color(color_str):
    """Parse SVG color string to RGB tuple"""
    if color_str.startswith('#'):
        hex_color = color_str[1:]
        if len(hex_color) == 3:
            hex_color = ''.join([c*2 for c in hex_color])
        return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
    elif color_str.startswith('rgb'):
        # Extract numbers from rgb(r,g,b) format
        numbers = re.findall(r'\d+', color_str)
        return tuple(int(n) for n in numbers[:3])
    else:
        # Handle named colors
        color_map = {
            'white': (255, 255, 255),
            'black': (0, 0, 0),
            'red': (255, 0, 0),
            'green': (0, 255, 0),
            'blue': (0, 0, 255),
        }
        return color_map.get(color_str.lower(), (0, 0, 0))

def create_png_from_svg_data(size):
    """Create PNG data based on the SVG design"""
    pixels = []
    center_x, center_y = size // 2, size // 2
    
    for y in range(size):
        for x in range(size):
            dx = x - center_x
            dy = y - center_y
            dist = (dx * dx + dy * dy) ** 0.5
            
            # Background circle (orange #FF6B35)
            if dist < size * 0.47:
                # Chef hat area (white)
                if y < size * 0.35 and abs(dx) < size * 0.31:
                    if y > size * 0.25 and abs(dx) < size * 0.31:  # Hat band
                        pixels.append((255, 255, 255))
                    elif dist < size * 0.23:  # Hat top (elliptical)
                        hat_y = y - size * 0.27
                        if (dx * dx) / (size * 0.31) ** 2 + (hat_y * hat_y) / (size * 0.12) ** 2 < 1:
                            pixels.append((255, 255, 255))
                        else:
                            pixels.append((255, 107, 53))
                    else:
                        pixels.append((255, 255, 255))
                # Cooking pot area (dark gray #4A4A4A)
                elif y > size * 0.5 and y < size * 0.78:
                    pot_y = y - size * 0.625
                    if (dx * dx) / (size * 0.35) ** 2 + (pot_y * pot_y) / (size * 0.16) ** 2 < 1:
                        pixels.append((74, 74, 74))
                    else:
                        pixels.append((255, 107, 53))
                # Steam area (light gray)
                elif y < size * 0.55 and y > size * 0.39:
                    if abs(dx - size * 0.09) < size * 0.02 or abs(dx) < size * 0.02 or abs(dx + size * 0.09) < size * 0.02:
                        if (y + x) % 8 < 4:  # Simple wavy pattern
                            pixels.append((224, 224, 224))
                        else:
                            pixels.append((255, 107, 53))
                    else:
                        pixels.append((255, 107, 53))
                # Food items (colorful dots)
                elif y > size * 0.6 and y < size * 0.7:
                    if abs(dx - size * 0.06) < size * 0.03 and abs(dy - size * 0.02) < size * 0.03:
                        pixels.append((255, 68, 68))  # Red food
                    elif abs(dx + size * 0.06) < size * 0.025 and abs(dy - size * 0.01) < size * 0.025:
                        pixels.append((68, 255, 68))  # Green food
                    elif abs(dx) < size * 0.027 and abs(dy - size * 0.04) < size * 0.027:
                        pixels.append((255, 170, 68))  # Orange food
                    else:
                        pixels.append((74, 74, 74))  # Pot color
                # Utensils area
                elif x > size * 0.62 and x < size * 0.68 and y > size * 0.55 and y < size * 0.7:
                    pixels.append((139, 69, 19))  # Brown handle
                elif x > size * 0.61 and x < size * 0.69 and y > size * 0.52 and y < size * 0.56:
                    pixels.append((192, 192, 192))  # Silver utensil
                else:
                    pixels.append((255, 107, 53))  # Orange background
            else:
                pixels.append((0, 0, 0))  # Black background outside circle
    
    return pixels

def create_simple_png(width, height, pixels):
    """Create a simple PNG file from pixel data"""
    def write_png_chunk(chunk_type, data):
        chunk_data = chunk_type + data
        crc = zlib.crc32(chunk_data) & 0xffffffff
        return struct.pack('>I', len(data)) + chunk_data + struct.pack('>I', crc)
    
    # PNG signature
    png_signature = b'\x89PNG\r\n\x1a\n'
    
    # IHDR chunk
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)  # RGB format
    ihdr_chunk = write_png_chunk(b'IHDR', ihdr_data)
    
    # Image data
    raw_data = b''
    for y in range(height):
        raw_data += b'\x00'  # Filter type 0 (None)
        for x in range(width):
            pixel = pixels[y * width + x]
            raw_data += struct.pack('BBB', pixel[0], pixel[1], pixel[2])
    
    # Compress image data
    compressed_data = zlib.compress(raw_data)
    idat_chunk = write_png_chunk(b'IDAT', compressed_data)
    
    # IEND chunk
    iend_chunk = write_png_chunk(b'IEND', b'')
    
    return png_signature + ihdr_chunk + idat_chunk + iend_chunk

def convert_svg_to_png():
    """Convert the SVG to a high-resolution PNG"""
    size = 1024  # High resolution for better quality
    pixels = create_png_from_svg_data(size)
    png_data = create_simple_png(size, size, pixels)
    
    with open('assets/app_icon.png', 'wb') as f:
        f.write(png_data)
    
    print(f'Created assets/app_icon.png ({size}x{size})')

if __name__ == '__main__':
    convert_svg_to_png()
    print('SVG to PNG conversion completed!')