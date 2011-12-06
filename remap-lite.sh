#!/bin/bash

MAPPER="c10t-1.9-linux-x86/c10t -P c10t-1.9-linux-x86/newcolours.dat -M 100"
WORLD=$1 #"../survival-world/"
OUTPUT=$2 #"./survival/"

#surface renders:
# overhead
echo "Running overhead..."
CMD=$MAPPER" -w "$WORLD" -o "$OUTPUT"overhead.png"
$CMD

# overhead night
echo "Running night..."
CMD=$MAPPER" -n -w "$WORLD" -o "$OUTPUT"overheadnight.png"
$CMD

# overhead
echo "Running overhead nether..."
CMD=$MAPPER" --hell-mode -w "$WORLD"/DIM-1 -N -o "$OUTPUT"overhead-nether.png"
$CMD

# fatiso
#echo "Running fatiso..."
#CMD=$MAPPER" -Z -w "$WORLD" -o "$OUTPUT"fatiso.png"
#$CMD

# fatiso
#echo "Running fatiso nether..."
#CMD=$MAPPER" --hell-mode -Z -w "$WORLD"/DIM-1 -N -o "$OUTPUT"fatiso-nether.png"
#$CMD

# fatiso night
#echo "Running night fatiso..."
#CMD=$MAPPER" -Z -n -w "$WORLD" -o "$OUTPUT"fatisonight.png"
#$CMD

# fatiso day rotated 90
#echo "Running fatiso rotated by 90..."
#CMD=$MAPPER" -Z -r90 -w "$WORLD" -o "$OUTPUT"fatiso90.png"
#$CMD

# fatiso day rotated 180
#echo "Running fatiso rotated by 180..."
#CMD=$MAPPER" -Z -r180 -w "$WORLD" -o "$OUTPUT"fatiso180.png"
#$CMD

# fatiso day rotated 270
#echo "Running fatiso rotated by 270..."
#CMD=$MAPPER" -Z -r270 -w "$WORLD" -o "$OUTPUT"fatiso270.png"
#$CMD

#cave renders
# overhead
echo "Running caves..."
CMD=$MAPPER" -c -w "$WORLD" -o "$OUTPUT"cave.png"
$CMD

echo "Running players..."
CMD=$MAPPER" --ttf-path=/usr/share/fonts/truetype/ttf-dejavu/DejaVuSansMono.ttf --show-players -w "$WORLD" -o "$OUTPUT"players.png"
$CMD

#echo "Running players nether..."
#CMD=$MAPPER" --hell-mode --ttf-path=/usr/share/fonts/truetype/ttf-dejavu/DejaVuSansMono.ttf --show-players -w "$WORLD"/DIM-1 -o "$OUTPUT"players-nether.png"
#$CMD


echo "Deleting swap file..."
rm /home/stwalkerster/c10t/swap.bin
