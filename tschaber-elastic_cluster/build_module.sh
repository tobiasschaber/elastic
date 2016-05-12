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

echo "uploading..."
# will upload the module to puppet forge
# this requires the auth cookie, which was exported with the firefox "export cookies" plugin (https://addons.mozilla.org/en-US/firefox/addon/export-cookies/)
# and stored under /home/tobias/work/cookies.txt
curl --cookie /home/tobias/work/cookies.txt --form authenticity_token=5dc5e94f123c50227d21814a45f8af12 --form "utf-8=&#x2713;" --form tarball=@pkg/tschaber-elastic_cluster-$version_new.tar.gz https://forge.puppetlabs.com/upload


echo "LATEST VERSION ONLINE:"
curl -s https://forgeapi.puppetlabs.com/v3/modules/tschaber-elastic_cluster | grep "\"version\":" -m 1
