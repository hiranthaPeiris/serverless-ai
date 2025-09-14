#!/bin/bash
set -e

# Check if destination directory and files are provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <file1> [<file2> ...]"
    exit 1
fi

# Get destination directory
destination="_build"
#  # Removes $1 from the list, so now $@ starts with the second arg
# shift

if [ ! -d "$destination" ]; then
    echo "Destination directory '$destination' does not exist. creating one..."
    mkdir "$destination"
fi

# Copy files to destination directory
rm -Rf "$destination"/* # clear the build dir

for file in "$@"; do
    cp -v "$file" "$destination"
done

# check for pipfile
if [ -f Pipfile ]; then
    echo "Pipfile found"
    cp -v Pipfile "$destination"
    #Install requirements with pipenv
    pip3 install -r <(pipenv requirements) --target "$destination/"
    echo "Requirements installed successfully"

elif [ -f requirements.txt ]; then
    echo "requirements.txt found. Copying to $destination..."
    cp -v requirements.txt "$destination"

    echo "Installing requirements from requirements.txt..."
    pip3 install -r requirements.txt --target "$destination/"
    echo "Requirements installed successfully from requirements.txt."

else
    echo "No Pipfile or requirements.txt found. Skipping Python dependency installation."
fi

# zip the build dir to upload
echo "Zipping build dir"
cd _build && zip -r ../_build.zip ./*
echo "Zipping Done"

#Remove _build dir
cd .. && rm -Rf "$destination"

echo "Build Successful"
