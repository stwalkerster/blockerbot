#!/bin/bash

cd ~/c10t/

date=`date +%FT%H%M%SZ`


tar -cf "$date.tar" mc1-world/

bzip2 $date.tar

s3cmd put $date.tar.bz2 s3://minecraft-worlds/smp/mc1/

php updateWiki.php
