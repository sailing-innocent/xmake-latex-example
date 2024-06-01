import os 
import argparse 

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--drawio", type=str, default="main.drawio")
    parser.add_argument("--png", type=str, default="main.png")
    args = parser.parse_args()
    os.system(f"draw.io -x -f png -o {args.png} {args.drawio}")
    