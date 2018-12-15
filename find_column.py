import argparse
import csv

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('file', help='file to look inside')
    parser.add_argument('column', help='name of column')
    args = parser.parse_args()
    file = open(args.file, "r")
    for line in file:
        columns = line.split('|')
        for idx, col in enumerate(columns):
            if col.strip() in args.column:
                print(idx+1)
        break

if __name__== "__main__":
    main()
