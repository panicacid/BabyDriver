#!/bin/bash

# Script is called by my PiJuice HAT when power is lost to the UPS HAT if no WiFi connection is available when the script runs it will do everything apart from upload
# the upload will happen the next time it loses power and internet is available
#
# Credit to ElKentaro for the Upload2Wigle script available here https://github.com/elkentaro/upload2wigle
# Paths are relative to my Pi setup please feel free to either create the directory structure as per the below or amend them accordingly
# To cheat and make the directories that I use below run the following:
# sudo mkdir /home/pi/wardriving
# sudo mkdir /home/pi/wardriving/processed
# sudo mkdir /home/pi/wardriving/2wigle
# sudo mkdir /home/pi/wardriving/2wigle/uploaded
#

# First thing we'll do is stop kismet
sudo systemctl stop kismet

# Next we'll process our kismet files (clean up DBs and get the data out of the DBs ready for Wigle)

FILES="/home/pi/wardriving/*.kismet"
for f in $FILES
do
        kismetdb_clean -i "$f"
        kismetdb_to_wiglecsv -i "$f" -o "$f".csv

        sudo mv "$f" /home/pi/wardriving/processed/

done
# Now let's move our csv files into our 2wigle folder

sudo mv /home/pi/wardriving/*.csv /home/pi/wardriving/2wigle/

# Time to upload them to Wigle!

FILES2GO="/home/pi/wardriving/2wigle/*.csv"

for f in $FILES2GO

do
APIName=**APINAMEHERE**
APIToken=**APITOKENHERE**
curl -X POST "https://api.wigle.net/api/v2/file/upload" -H "accept: application/json" -H "Content-Type: multipart/form-data" -F "file=@$f;type=text/csv" -F "donate=on" -i -H 'Accept:application/json' -u $APIName:$APIToken --basic && mv $f /home/pi/wardriving/2wigle/uploaded
done

# Finished uploading time to shutdown!

sudo shutdown now
