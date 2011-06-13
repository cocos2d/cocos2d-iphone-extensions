#!/bin/sh

#  CCBigImage
#  Tiles Builder Script for CCBigImageDemo
#
#  Created by Stepan Generalov on 05.08.11.
#  Copyright (c) 2011 Stepan Generalov
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.
#

# Create directory
mkdir tiles

# Prepare SD Tiles
echo Preparing SD Tiles
./tileCutter --rigidTilesSize --tileWidth 256 --tileHeight 256 --inputFile bigImage.jpg --outputFile tiles/bigImage

# Prepare HD Tiles
echo Preparing HD Tiles
./tileCutter --rigidTilesSize --tileWidth 512 --tileHeight 512 --inputFile bigImage-hd.jpg --outputFile tiles/bigImage --outputSuffix -hd

# Remove HD Tiles PLISTs
rm tiles/bigImage-hd.plist

# Compress tiles to pvr.ccz
echo Converting Tiles to pvr.ccz
cd tiles
../tilesCompress.sh



