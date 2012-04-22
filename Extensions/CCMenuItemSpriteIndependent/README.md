CCMenuItemSpriteIndependent
============================

CCMenuItemSpriteIndependent is CCMenuItemSprite that doesn't add normal, selected   
and disabled images as children. Instead of that it just retain them.   
So you can place images anyhow you want, and they can be located on all hierarchy levels. 
   
CCMenuItemSpriteIndependent overrides rect and "convertToNodeSpace:" methods delegating them to normalSprite.   
This allows you to position/scale/rotate only normal sprite and forget about positioning menuItem.   