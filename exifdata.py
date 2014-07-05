#!/usr/bin/python
import argparse
import exifread
import os
import csv
# Open image file for reading (binary mode)


parser = argparse.ArgumentParser(
    description="Return exif details of a set of photographs.")
parser.add_argument('input',
                    help="input folder name")
args = parser.parse_args()

files = [f for f in os.listdir(args.input) if os.path.isfile(os.path.join(args.input, f))]

c = open("exif.csv", "wb")
csvwrite = csv.writer(c)
csvwrite.writerow(["Date","ExposureTime","FNumber","FocalLength","ISO"])
for file in files:
    f = open(os.path.join(args.input, file), 'rb')

    # Return Exif tags
    tags = exifread.process_file(f)
    csvwrite.writerow([
        tags["EXIF DateTimeDigitized"],
        tags["EXIF ExposureTime"],
        tags["EXIF FNumber"],
        tags["EXIF FocalLength"],
        tags["EXIF ISOSpeedRatings"]])
    f.close()

c.close()
