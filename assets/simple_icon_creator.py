import struct
import zlib

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

def create_food_icon_pixels(size):
    """Create pixel data for a simple food-themed icon"""
    pixels = []
    center_x, center_y = size // 2, size // 2
    
    for y in range(size):
        for x in range(size):
            # Distance from center
            dx = x - center_x
            dy = y - center_y
            dist = (dx * dx + dy * dy) ** 0.5
            
            # Background circle (orange)
            if dist < size * 0.45:
                # Chef hat area (white)
                if y < size * 0.4 and abs(dx) < size * 0.3:
                    pixels.append((255, 255, 255))  # White
                # Cooking pot area (dark gray)
                elif y > size * 0.5 and y < size * 0.8 and abs(dx) < size * 0.35:
                    pixels.append((74, 74, 74))  # Dark gray
                # Steam area (light gray)
                elif y < size * 0.5 and y > size * 0.3 and abs(dx) < size * 0.1:
                    pixels.append((200, 200, 200))  # Light gray
                # Food items (colorful dots)
                elif (abs(dx - size * 0.1) < size * 0.05 and abs(dy - size * 0.1) < size * 0.05):
                    pixels.append((255, 68, 68))  # Red food
                elif (abs(dx + size * 0.1) < size * 0.05 and abs(dy - size * 0.15) < size * 0.05):
                    pixels.append((68, 255, 68))  # Green food
                else:
                    pixels.append((255, 107, 53))  # Orange background
            else:
                pixels.append((0, 0, 0))  # Transparent (black for simplicity)
    
    return pixels

def create_icon_file(filepath, size):
    """Create a PNG icon file"""
    pixels = create_food_icon_pixels(size)
    png_data = create_simple_png(size, size, pixels)
    
    with open(filepath, 'wb') as f:
        f.write(png_data)
    
    print(f'Created {filepath} ({size}x{size})')

# Create a simple 48x48 icon for testing
if __name__ == '__main__':
    create_icon_file('assets/test_icon.png', 48)
    print('Test icon created!')