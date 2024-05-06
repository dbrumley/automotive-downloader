#!/bin/bash

# Create a directory yyyy-mm-dd
DATE_DIR=$(date -Idate)
echo "Saving downloads in ${DATE_DIR}"
mkdir ${DATE_DIR}

echo "Downloading files from Bosch"
wget --input-file bosch-files.txt --force-directories --progress=bar:noscroll --timestamping --directory-prefix=${DATE_DIR}

# This is downloading the
# - toyota NAVI 2022 package.
#    see https://www.denso.com/global/en/opensource/ivi/toyota/navi_2022model/
# - Subaru 2021 entertainment
#   see https://www.denso.com/global/en/opensource/ivi/subaru/
# - Honda
#   see https://www.denso.com/global/en/opensource/ivi/honda/
# - Toyota from my rental car 07/2023
#   https://www.denso-ten.com/support/source/oem/21/
echo "Downloading files from Denso"
wget --input-file denso-files.txt --force-directories --progress=bar:noscroll --timestamping --directory-prefix=${DATE_DIR}

#echo "Downloading files from Toyota"
#wget --input-file toyota-files.txt --force-directories --progress=bar:noscroll --timestamping --directory-prefix=${DATE_DIR}

echo "Downloading files from Honda"
wget --input-file honda-files.txt --force-directories --progress=bar:noscroll --timestamping --directory-prefix=${DATE_DIR}

echo "Downloading files from Ford"
wget --input-file ford-files.txt --force-directories --progress=bar:noscroll --timestamping --directory-prefix=${DATE_DIR}

echo "Downloading files from Mercedes"
wget --input-file mercedes-files.txt --force-directories --progress=bar:noscroll --timestamping --directory-prefix=${DATE_DIR}

echo "Downloading files from Hitachi Construction"
wget --input-file hitachi-construction-files.txt --force-directories --progress=bar:noscroll --timestamping --directory-prefix=${DATE_DIR}

echo "Downloading files from Hyundai"
wget --input-file hyundai-files.txt --force-directories --progress=bar:noscroll --timestamping --directory-prefix=${DATE_DIR}

