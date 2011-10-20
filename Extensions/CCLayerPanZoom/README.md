CCLayerPanZoom
=============

This class represents the layer that can be scroll and scale with one or two fingers. 
Supports two layer's modes: sheet mode and frame mode.
In first mode you can scroll and scale layer like in Google Maps (see "Simple sheet test").
In second mode you can scale layer like in first mode and scroll layer with touch at specified zones that located at the edges. 
You can use this when it's need to move objects at layer with drag & drop (see "Frame test"). For example, in edit mode on your map.
In this mode supports delegate callbacks for clicked at point event.
Similarly, in sheet mode you can use "ruber edges" (see "Advanced sheet test").
Supports delegate callbacks for clicked at point, touch position updated and touch move began at position events.

Usage
=============

1. Add both files to your project.
2. Import CCLayerPanZoom.h when you want to use it.
3. Make sure that you enable multitouch in your glView.
4. Create CCLayerPanZoom instance and add childs to the layer.
5. Assign the delegate if you need it.
6. Set mode for the layer.
7. If you want to use kCCLayerPanZoomModeSheet:
	a. Set ruberEdgesMargin if you want to use "ruber edges". This is distance from panBoundRect on which possible stretch layer. 
	For disable "rubber edges" you can set this property to 0.0f (this value by default).
	b. For "rubber edges" you can set ruberEdgesTime. This is delay for recover layer position and scale.
8. If you want to use kCCLayerPanZoomModeFrame:
	a. Set topFrameMargin, leftFrameMargin, bottomFrameMargin and rightFrameMargin for define distances from edges of panBoundingRect.
	b. Set maxSpeed and minSpeed for autoscrolling when touch is in zone near edge of panBoundingRect.
9. Set maxScale and minScale for the layer.
10. Set maxTouchDistanceToClick for the layer. This is the max distance that touch can be drag before click.
11 In updateForScreenReshape method:
	a. Set contentSize for the layer.
    b. Set anchorPoint and position for the layer.
	c. Set panBoundsRect for the layer. This is rectangle in which layer can be scroll and scale.




