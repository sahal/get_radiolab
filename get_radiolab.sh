#! /bin/bash
# ./get_radiolab.sh [continue]
# by Sahal Ansari (github@sahal.info)
# uses bash, wget, sed, and grep to download the Radiolab episode archive.
# DOES NOT download latest podcasts (subscribe: radiolab.org/series/podcasts/)

function die { #$1 = message
	echo "$1"
	exit 1
}

function noyes { # this time its not pronounced NOISE, baby baby
# $1 = if no do this $2 = if yes do this
# nest quotes like so
# noyes "echo 'you said no!';exit" "echo 'you said yes!'"

if [ -z "$1" ]; then
	die "WARNING: function noyes - no (\$1) not set"
fi

if [ -z "$2" ]; then
	die "WARNING: function noyes - yes (\$2) not set"
fi

select yn in "Yes" "No"; do
	case "$yn" in
		Yes ) eval "$2"; break;;
		No ) eval "$1"; break;;
	esac
done

}

function ccache {
if [ -e ./rlabrawmp3 ] || [ -e ./rlabmp3 ]; then
	echo "It looks like you've run this script before. Would you like delete all log files and start again?"
	noyes "echo 'Okay, I will now exit.'; die 'Hint: Try running ./get_radiolab.sh continue'" "echo 'Okay.'"
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
noyes "echo 'A list of Radiolab episode mp3s are in ./rlabmp3'; die 'If you ever change your mind, type ./get_radiolab.sh continue to continue where you left off.'" "echo 'Okay.'"
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
