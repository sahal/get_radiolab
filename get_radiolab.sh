#! /bin/bash
# ./get_radiolab.sh [continue]
# by Sahal Ansari (github@sahal.info)
# uses bash, wget, sed, and grep to download the Radiolab episode archive.
# DOES NOT download latest podcasts (subscribe: radiolab.org/series/podcasts/)

function ccache {
if [ -e ./rlabrawmp3 ] || [ -e ./rlabmp3 ]; then
echo "It looks like you've run this script before. Would you like delete all log files and start again?"
select yn in "Yes" "No"; do
        case $yn in
        Yes ) break;;
        No ) echo "Okay. I will now exit."; echo "Hint: Try running ./get_radiolab.sh continue"; exit ;;
        esac
done
rm ./rlabrawmp3 ./rlabmp3
fi
}

function eplist {
echo "Downloading list of Radiolab Episodes ... "
wget --append-output=wget_log -O - http://www.radiolab.org/archive/ | grep read\-more | \
sed -e s/.*href\=\"// -e s/\".*// > rlabdesc
echo "done."
}

function mp3list {
echo "Getting list of mp3s ~ 17MB (this will take a long time) ... "
wget --append-output=wget_log -O - --input-file rlabdesc | tee -a -i rlabrawmp3 | \
grep data-download | \
sed -e s/.*download=\"// -e s/\"\)\;// -e s/^\ .*\"// -e s/\".*// >> rlabmp3
echo "done."
}

function download {
echo "Would you like to download the entire Radiolab episode archive? ~ 60MB per episode (this will take an even longer time)"
select yn in "Yes" "No"; do
        case $yn in
        Yes ) break;;
        No ) echo "A list of Radiolab episode mp3s are in ./rlabmp3"; echo "If you ever change your mind, type \`./get_radiolab.sh continue\` to continue where you left off."; exit 1;;
        esac
done
wget --continue --input-file rlabmp3
}

case "$1" in
continue|download )
download;;

* )
ccache
eplist
mp3list
download
;;
esac
