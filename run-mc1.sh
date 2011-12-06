#!/bin/bash

#rsync -avz -e "ssh -i key_rsa" ec2-user@minecraft:/home/ec2-user/1.8-prerelease/world/ 1.8-world/

./fetch-mc1.sh

./remap.sh "minecraft/world" "mc1/"

