#!/bin/bash

echo "Building module..."


version_line=$(less metadata.json | grep "\"version\":" | cut -d':' -f2)
version_old=${version_line:2:-2}

echo "------------------------------------"
echo "alte version: $version_old"

version_new=$(echo $version_old | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if((length($NF+1)>length($NF)) AND length($NF+1)>2)$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(100^length($NF))); print}')

echo "neue version: $version_new"
echo "------------------------------------"

search_string="\"version\": \"$version_old\","
replace_String="\"version\": \"$version_new\","

sed -i "s/$search_string/$replace_String/g" metadata.json

puppet module build




