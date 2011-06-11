CCMenuItemSpriteIndependent
============================

CCMenuItemSpriteIndependent is CCMenuItemSprite that doesn't add normal, selected   
and disabled images as children. Instead of that its just retain them.   
So you can place images anyhow you want.   
   
CCmenuItemSprite reimplements rect and "convertToNodeSpace:" methods delegating them to normalSprite.   
This allows you to position/scale/rotate only normal sprite and forget about positioning menuItem.   