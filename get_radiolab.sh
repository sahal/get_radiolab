#! /bin/bash
# ./get_radiolab.sh [continue]
# by Sahal Ansari (github@sahal.info)
# uses bash, wget, sed, and grep to download the radiolab archive.
# DOES NOT download latest podcasts (subscribe: radiolab.org/series/podcasts/)

function ccache {

if [ -e ./rlabrawmp3 ] || [ -e ./rlabmp3 ]; then
echo "It looks like you've run this script before. Would you like delete all log files and start again?"
select yn in "Yes" "No"; do
        case $yn in
        Yes ) break;;
        No ) echo "Okay. I will now exit."; exit
        esac
done
rm ./rlabrawmp3 ./rlabmp3
fi

}

function eplist {
echo "Downloading list of Radiolab Episodes ... "
wget --output-file=wget_log -O - --quiet http://www.radiolab.org/archive/ | grep read\-more | \
sed -e s/.*href\=\"// -e s/\".*// > rlabdesc
# optionally use list_urls.sed instead of the above sed line
# http://sed.sourceforge.net/grabbag/scripts/list_urls.sed
#/full/path/to/list_urls.sed
echo "                                          done."
}

function mp3list {
echo "Getting list of mp3s ... (This will take a long time)"
wget --output-file=wget_log -O - --quiet --input-file rlabdesc | tee -a -i rlabrawmp3 | \
grep data-download | \
sed -e s/.*\download=\"// -e s/\"\)\;// -e s/^\ .*\"// -e s/\".*// | \
grep [^abc]\.mp3$ >> rlabmp3
echo "                         done."
}

function download {
echo "Would you like to start downloading the entire Radiolab archive?"
select yn in "Yes" "No"; do
        case $yn in
        Yes ) break;;
        No ) echo "Okay, a list of Radiolab episode mp3s are in ./rlabmp3"; exit 1;;
        esac
done
wget --output-file=wget_log --progress=bar --input-file rlabmp3 -nc -nv
}

case "$1" in
continue )
download ;;

* )
ccache
eplist
mp3list
download
;;
esac
