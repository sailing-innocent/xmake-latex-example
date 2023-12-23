from PIL import Image 
import argparse 

def ppm2png(ppm_file, png_file):
    img = Image.open(ppm_file)
    img.save(png_file)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--ppm", type=str, default="main.ppm")
    parser.add_argument("--png", type=str, default="main.png")
    args = parser.parse_args()
    ppm2png(args.ppm, args.png)