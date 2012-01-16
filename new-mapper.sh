#!/bin/bash

# crontab
# 0 3 * * * cd /home/stwalkerster/c10t/;./new-mapper.sh -sl >/dev/null
# 0 6 * * * cd /home/stwalkerster/c10t/;./new-mapper.sh -sl>/dev/null
# 0 9 * * * cd /home/stwalkerster/c10t/;./new-mapper.sh -sl >/dev/null
# 0 12 * * * cd /home/stwalkerster/c10t/;./new-mapper.sh -sl >/dev/null
# 0 15 * * * cd /home/stwalkerster/c10t/;./new-mapper.sh -sl >/dev/null
# 0 18 * * * cd /home/stwalkerster/c10t/;./new-mapper.sh -sl >/dev/null
# 0 21 * * * cd /home/stwalkerster/c10t/;./new-mapper.sh -sl >/dev/null
# 0 0 * * * cd /home/stwalkerster/c10t/;./new-mapper.sh -sbwlh >/dev/null


# Usage:
# -b		Backup to s3
# -c <list>	Custom set of maps
# -h		Heavy maps
# -l		Light maps
# -s		Sync from game server
# -w		Update backup list on-wiki
# -r		Map core - smaller map

# Requirements:
# * c10t
# * GNU Tools (bash/tar/bzip2/rm)
# * s3cmd (for Amazon AWS S3)
# * rsync
# * php (for mediawiki update)

mapsLight="cave overhead-nether overhead overheadnight players"
mapsHeavy="fatiso-nether fatiso fatisonight"
 
MAPPER="c10t-git/build/c10t -M 100 --ttf-path=/usr/share/fonts/truetype/ttf-dejavu/DejaVuSansMono.ttf -m 4"
#MAPPER="c10t -P c10t-1.9-linux-x86/newcolours.dat -M 100 --ttf-path=/usr/share/fonts/truetype/ttf-dejavu/DejaVuSansMono.ttf -m 4"
REMOTEWORLD="stwalkerster@minecraft:/home/minecraft/multicraft/servers/server1/world/"
REMOTEKEY="key_rsa"
WORLD="mc1-world"
OUTPUT="mc1/"
SUFFIX="-full"
amazonsssurl="s3://minecraft-worlds/smp/mc1/"

maps=""

while getopts ":bc:hlswr" opt; do
case $opt in
  b)
	echo "##### Running backup to S3"
    date=`date +%FT%H%M%SZ`
	echo "########## Adding to tarball"
	tar -cf "$date.tar" mc1-world/
	echo "########## Compressing tarball"
	bzip2 $date.tar
	echo "########## Verifying MD5"
	LASTSUM=`cat lastmd5`
	THISSUM=`md5sum $date.tar.bz2 | awk '{print $1}'`
	echo $THISSUM > lastmd5
	if [ "$LASTSUM" != "$THISSUM" ];
	then
		echo "########## Uploading"
		s3cmd put $date.tar.bz2 $amazonsssurl
	else
		echo "########## MD5 matches, skipping upload"
	fi
	rm $date.tar.bz2
	echo "##### Done backup"
    ;;
  c)
    echo "##### Adding custom maps ($OPTARG) to queue"
	maps=$maps" "$OPTARG
    ;;
  h)
	echo "##### Adding heavy maps to queue"
	maps=$maps" "$mapsHeavy
    ;;
  l)
	echo "##### Adding light maps to queue"
    maps=$maps" "$mapsLight
	;;
  s)
	echo "##### Running sync from game server"
	rsync -avz -e "ssh -i $REMOTEKEY" $REMOTEWORLD $WORLD
	echo "##### Done sync"
    ;;
  w)
	echo "##### Updating wiki backup list"
	php updateWiki.php
	;;
  r)
	MAPPER=$MAPPER" -R 42 --center 21,33"
	SUFFIX=""
	;;
  \?)
    echo "Invalid option: -$OPTARG" >&2
    exit 1
    ;;
  :)
    echo "Option -$OPTARG requires an argument." >&2
    exit 1
    ;;
esac
done

echo
echo "Queue:" $maps
echo
echo "##### Starting render jobs"
for i in $maps; do
	mapperopts=""
	case $i in
		overhead)
			mapperopts=""
			;;
		overheadnight)
			mapperopts="-n"
			;;
		overhead-nether)
			mapperopts="--hell-mode -N"
			;;
		fatiso)
			mapperopts="-Z"
			;;
		fatiso-nether)
			mapperopts="--hell-mode -Z -N"
			;;
		fatisonight)
 			mapperopts="-Z -n"
			;;
		fatiso90)
			mapperopts="-Z -r90"
			;;
		fatiso180)
			mapperopts="-Z -r180"
			;;
		fatiso270)
			mapperopts="-Z -r270"
			;;
		cave)
			mapperopts="-c"
			;;
		cave-fatiso)
			mapperopts="-c -Z"
			;;
		players)
			mapperopts="--show-players"
			;;
		players-nether)
			mapperopts="--hell-mode -N --show-players"
			;;
		*)
			echo "########## warning: unrecognised map key: "$i
			continue;
			;;
	esac

	command=$MAPPER" "$mapperopts" -w "$WORLD"/ -o "$OUTPUT$i$SUFFIX".png"
	echo "########## "$i" = "$command
	$command
done

echo "##### Cleaning up"

rm -f c10t.log cookies.tmp swap.bin

