#!/bin/bash

#wget -m 'ftp://stwalkerster.1:Acrtbe2bm!@minecraft/world'

rsync -avz -e "ssh -i key_rsa" stwalkerster@minecraft:/home/minecraft/multicraft/servers/server1/world/ mc1-world/
