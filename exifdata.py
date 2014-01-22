import exifread
# Open image file for reading (binary mode)

i = 1
with open("~/timelapse/files.txt", "r") as fn:
    for line in fn:
        f = open("/home/tejovanth/timelapse/src/"+line[:-1], 'rb')

        # Return Exif tags
        tags = exifread.process_file(f)
        print str(i) + ", " + str(tags["EXIF ExposureTime"]) + ", "
        i += 1
        f.close()
