I want to integrate the header and main pane easily.

I want the gradient to go from gold to white in the header, and made the home screen always white so when we scroll, it looks seamless

I want the gradient to start from the top of the status bar to be light yellow, and end being white at the bottom of the header, and then be white from the middle pane down to the rest of the screen. This will be smooth and look sleek when scrolling up and down as the home screen will not be weird. 

Implementation:
✅ Gold at Top of Status Bar:
Color(0xFFF8D777) - Light gold starts from absolute top
Covers only the status bar area
✅ Very Small Gradient:
Only 15% of screen height - just a tiny amount in header
Stops at [0.0, 0.15] - minimal gradient transition
✅ White in Header:
Header is mostly white
Seamless transition from tiny gradient to white
✅ Seamless Integration:
No visible break between header and "Good Morning" content
Perfect white continuation from header to main content
Smooth, professional appearance