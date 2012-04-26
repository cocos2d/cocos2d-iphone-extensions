HKTMXTiledMap
==================

CCTMXTiledMap is useful, but it's absurdly slow for large maps, thus, HKTMXTiledMap is born. By pushing only polygons needed to the GPU, it drastically reduces render times by the GPU.
Currently, it only supports orthogonal maps (no hex or isometric maps).
Also added to it is animation functionality. This allows you to have data-driven animated tiles as done through the Tile Properties.

Animation
------------------------

To animate tiles, you edit tile properties (via Tiled or whatever editor) to have "Next" which lists the next GID in the animation, and Delay (the delay between frames).
It supports looped and one shot animations, but all animations have to be deterministic (no random)

For one shot animations:
* If you add a delay, but no Next on the last frame of the animation, then after that delay, it will remove the tile (eg. for an explosion)
* if you do not add a delay, then the last frame will continue on forever without being updated

It should be noted that if you setatilegid to the start of a one shot animation before the same oneshotanimation finishes (no matter where it is on the map), it will reset the loop for all of them

How to create
------------------------

Maps should be made in Tiled http://www.mapeditor.org

Created just like a CCTMXTiledMap. 
HKTMXTiledMap* node = [HKTMXTiledMap tiledMapWithTMXFile:@"testmap.tmx"];

Known issues
------------------------

Thanks
------------------------
Special thanks to Jonathan Barnes for adding support for flipped tiles