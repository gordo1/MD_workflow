#!/bin/bash

echo "Select analysis tool that you'd like to use by typing the appropriate number (e.g. 1) or \"q\" to quit"
# Create a list of files to display
fileList=$(find ./Analysis/ -maxdepth 1 -type f -name a[0-9]* | sort  -n)
select fileName in $fileList; do
if [ -n fileName ]; then 
	bash ${fileName}
fi 
break
done
