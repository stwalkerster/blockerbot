#!/bin/bash

# Usage:
# -b		Backup script
# -c <list>	Custom set of maps
# -h		Heavy maps
# -l		Light maps
# -s		Sync from game server

# Requirements:
# * c10t
# * GNU Tools (bash/tar/bzip2/rm)
# * s3cmd (for Amazon AWS S3)
# * rsync
# * php (for mediawiki update)

mapsLight="cave overhead-nether overhead overheadnight players"
mapsHeavy="fatiso-nether fatiso fatisonight"
 
MAPPER="c10t-1.9-linux-x86/c10t -P c10t-1.9-linux-x86/newcolours.dat -M 100 --ttf-path=/usr/share/fonts/truetype/ttf-dejavu/DejaVuSansMono.ttf -m 4"
REMOTEWORLD="stwalkerster@minecraft:/home/minecraft/multicraft/servers/server1/world/"
REMOTEKEY="key_rsa"
WORLD="mc1-world"
OUTPUT="mc1/"

amazonsssurl="s3://minecraft-worlds/smp/mc1/"

maps=""

while getopts ":bc:hls" opt; do
case $opt in
  b)
	echo "##### Running backup to S3"
    date=`date +%FT%H%M%SZ`
	tar -cf "$date.tar" mc1-world/
	bzip2 $date.tar
	s3cmd put $date.tar.bz2 $amazonsssurl
	php updateWiki.php
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

for i in $maps; do
	case $opt in
		overhead)
			mapperopts=""
			subworld=""
			;;
		overheadnight)
			mapperopts="-n"
			subworld=""
			;;
		overhead-nether)
			mapperopts="--hell-mode -N"
			subworld="DIM-1"
			;;
		fatiso)
			mapperopts="-Z"
			subworld=""
			;;
		fatiso-nether)
			mapperopts="--hell-mode -Z -N"
			subworld="DIM-1"
			;;
		fatisonight)
			mapperopts="-Z -n"
			subworld=""
			;;
		fatiso90)
			mapperopts="-Z -r90"
			subworld=""
			;;
		fatiso180)
			mapperopts="-Z -r180"
			subworld=""
			;;
		fatiso270)
			mapperopts="-Z -r270"
			subworld=""
			;;
		cave)
			mapperopts="-c"
			subworld=""
			;;
		players)
			mapperopts="--show-players"
			subworld=""
			;;
		players-nether)
			mapperopts="--hell-mode -N --show-players"
			subworld="DIM-1"
			;;
	esac
	$MAPPER" "$mapperopts" -w "$WORLD"/"$subworld" -o "$OUTPUT$i".png"
done