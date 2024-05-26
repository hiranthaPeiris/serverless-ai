#!/bin/bash
set -e

# Check if destination directory and files are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <destination_directory> <file1> [<file2> ...]"
    exit 1
fi

# Get destination directory
destination="$1"
shift

if [ ! -d "$destination" ]; then
    echo "Destination directory '$destination' does not exist. creating one..."
    mkdir "$destination"
fi

# Copy files to destination directory
for file in "$@"; do
    cp -v "$file" "$destination"
done

#copy pipfile
cp -v Pipfile "$destination"
echo "Files copied successfully to $destination"

#Install requirements with pipenv
pip3 install -r <(pipenv requirements) --target "$destination/"
echo "Requirements installed successfully"

# zip the build dir to upload 
echo "Zipping build dir"
cd _build && zip -r ../_build.zip ./*
echo "Zipping Done"

#Remove _build dir
cd .. && rm -Rf "$destination"

echo "Build Successful"


