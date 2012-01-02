#!/bin/bash

rsync -avz -e "ssh -i key_rsa" stwalkerster@minecraft:/home/minecraft/multicraft/servers/server1/world/ mc1-world/
