#!/bin/bash

INPUT=$1
OUTPUT=$2
MODEL=$3
START=${4-0}
DUR=${5-0}
DIR=frames
CODEC='-c:v libx264'
FILENAME="${INPUT##*/}"
FILENAME="${FILENAME%.*}"
FPS=`ffprobe -v error -select_streams v:0 -show_entries stream=avg_frame_rate -of default=noprint_wrappers=1:nokey=1 $INPUT`
if [ "$(echo ${INPUT: -3} | tr a-z A-Z)" == 'GIF' ]; then
    CODEC=''
fi

mkdir -p $DIR
echo "Extracting frames"
ffmpeg -ss $START -t $DUR -i $INPUT $DIR/$FILENAME\_%d.png
echo "Finished extracting frames, transforming"
python generate.py $DIR/$FILENAME'_*.png' -m $MODEL -o $DIR/trans_ -g 0 -flow 0.02
echo "Done processing, muxing back togeter"
ffmpeg -framerate $FPS -i $DIR/trans_$FILENAME\_%d.png $CODEC $OUTPUT
