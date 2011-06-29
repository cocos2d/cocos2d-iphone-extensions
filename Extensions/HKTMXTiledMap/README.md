HKTMXTiledMap
==================

CCTMXTiledMap is useful, but it's absurdly slow for large maps, thus, HKTMXTiledMap is born. By pushing only polygons needed to the GPU, it drastically reduces render times by the GPU.
Currently, it only supports orthogonal maps (no hex or isometric maps).
Also added to it is animation functionality. This allows you to have data-driven animated tiles as done through the Tile Properties.

Animation
------------------------

  To animate tiles, you edit tile properties (via Tiled or whatever editor) to have "Next" which lists the next GID in the animation, and Delay (the delay between frames). It supports looped and one shot animations, but all animations have to be deterministic (no random)

How to create
------------------------

Maps should be made in Tiled http://www.mapeditor.org

Created just like a CCTMXTiledMap. 
 HKTMXTiledMap* node = [HKTMXTiledMap tiledMapWithTMXFile:@"testmap.tmx"];

Known issues
------------------------
* Doesn't currently work with retina display enabled and running on an iPhone 4 (asserts / crashes about multiple tilesets per layer)
* Mac Version can sometimes create line gaps between tiles when resizing the viewport (No easy-to-reproduce case)