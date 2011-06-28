HKTMXTiledMap
==================

CCTMXTiledMap is useful, but it's absurdly slow for large maps, thus, HKTMXTiledMap is born.
It only supports orthogonal maps (no hex or isometric maps).

Animation
------------------------

  To animate tiles, you edit tile properties (via Tiled or whatever editor) to have "Next" which lists the next GID in the animation, and Delay (the delay between frames). It supports looped and one shot animations, but all animations have to be deterministic (no random)

How to create
------------------------

Created just like a CCTMXTiledMap. 


Known issues
------------------------
* Doesn't currently work with retina display enabled
* Mac Version doesn't like window resizing