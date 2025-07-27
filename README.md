# ZX_Spectrum_Z80_Graphics

Optimized Z80 routines for Basic Graphics on the ZX Spectrum

HellaPlot:  My optimized calculated plot routine  Runs at 166 T states per pixel

HellaPoint: My optimized point routine to see if a pixel is in a particular x,y position

HellaLine: My optimized Bresenham line routine
     V1: first version, deltaX and delta are 16 bit.  fraction is also 16 bit.  Loop check is at the start of the loop.
     V2: optimizations of V1.  deltaX, deltaY and fraction are 8 bits, making the setup portion faster.  Loop check is at the end of the loop using a decrease, making it faster
