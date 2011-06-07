#!/bin/sh

# tilesCompress.sh
# iTraceur Tools
#
# Created by Stepan Generalov on 27.01.11.
# Copyright 2011 Parkour Games. All rights reserved.


for f in *.png
do  
	# get basename of png file without extension
	basename=`basename "$f" .png`
	
	# create RGBA4444 pvr.ccz from png
	texturePacker --allow-free-size --no-trim --disable-rotation --opt RGBA4444 $f --sheet $basename.pvr.ccz
	
	# remove png
	rm $f
done

# remove unnecessary texturePacker output file
rm out.plist
