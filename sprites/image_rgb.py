import sys
from PIL import Image

coe_hdr = '''memory_initialization_radix=2;
memory_initialization_vector=
'''

def get_bin_string(x):
    raw = bin(x)[2:]
    return "0"*(8 - len(raw)) + raw


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: {0} <image to convert>".format(sys.argv[0]))
    else:
        fname = sys.argv[1]
        img = Image.open(fname)
        cimg = img.convert("P")
        
        raw_palette = cimg.getpalette()
        palette = []
        for i in range(0, len(raw_palette), 3):
            palette.append(tuple(raw_palette[i:i+3]))
        # print(palette, len(palette))

        with open(f"{sys.argv[1][:sys.argv[1].index('.')]}_color_map_red.coe", "w") as f:
            f.write(coe_hdr)
            for i in range(256):
                f.write(get_bin_string(palette[i][0]) + ",\n")
        
        with open(f"{sys.argv[1][:sys.argv[1].index('.')]}_color_map_green.coe", "w") as f:
            f.write(coe_hdr)
            for i in range(256):
                f.write(get_bin_string(palette[i][1]) + ",\n")
        
        with open(f"{sys.argv[1][:sys.argv[1].index('.')]}_color_map_blue.coe", "w") as f:
            f.write(coe_hdr)
            for i in range(256):
                f.write(get_bin_string(palette[i][2]) + ",\n")
        
        (w, h) = cimg.size
        with open(f"{sys.argv[1][:sys.argv[1].index('.')]}_image.coe", "w") as f:
            f.write(coe_hdr)
            for y in range(h):
                for x in range(w):
                    f.write(get_bin_string(cimg.getpixel((x, y))) + ",\n")
                    