start:
	call bresenham_line_2
endless:
	jp endless

	                           ;  variables
_line_x1:	defb 000           ;  line start point X
_line_y1:	defb 000           ;  line start point Y
_line_x2:	defb 004           ;  line end point X
_line_y2:	defb 007           ;  line end point Y

stepX:	defb 0                     ;  direction of travel horizontally
stepY:	defb 0                     ;  direction of travel vertically

deltaX:	defb 0                     ;  distance between points in X axis
deltaY:	defb 0                     ;  distance between points in Y axis

	                           ;  fraction: defw 0 ; deciding point on which way the next pixel will travel
fraction:	defb 0



iterations:	defb 0             ;  loop counter
steps:	defb 0                     ;  the total number of pixels to be plotted



	                           ;  ;gfx variables
_gfx_xy:	defw 0

	                           ;  variables

_hellaPlot:
	ret

	                           ;  x1=000 y1=000
	                           ;  x2=255 y2=191
	                           ;  pass 1 takes 105124
	                           ;  pass 2 takes 83262

	                           ;  try to reduce deltaX and deltaY to 8 bits

bresenham_line_2:

deltaXABS:
	                           ;  deltaX = abs(x2 - x1);
	xor A                      ;  reset flags
	ld A,(_line_x1)            ;  load load first point
	ld L,A                     ;  move to L for compairson
	ld A,(_line_x2)            ;  load second point
	cp L                       ;  compare the two
	jr c,lineX1_larger         ;  _line_x1 is larger
	jr nc,lineX2_larger        ;  _line_x2 is larger or equal

lineX1_larger:	                   ;  _line_x1 is larger
	sub L                      ;  subtract L to find the ABS difference
	neg                        ;  invert bits to make positive
	jr DXABS_finished

lineX2_larger:	                   ;  _line_x2 is larger
	sub L                      ;  subtract L to find the ABS difference

DXABS_finished:
	ld (deltaX),A


	                           ;  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
deltaYABS:
	                           ;  deltaY = abs(y2 - y1);
	xor A                      ;  reset flags
	ld A,(_line_y1)            ;  load load first point
	ld L,A                     ;  move to L for compairson
	ld A,(_line_y2)            ;  load second point
	cp L                       ;  compare the two
	jr c,lineY1_larger         ;  _line_x1 is larger
	jr nc,lineY2_larger        ;  _line_x2 is larger or equal

lineY1_larger:	                   ;  _line_x1 is larger
	sub L                      ;  subtract L to find the ABS difference
	neg                        ;  invert bits to make positive
	jr DYABS_finished

lineY2_larger:	                   ;  _line_x2 is larger
	sub L                      ;  subtract L to find the ABS difference

DYABS_finished:
	ld (deltaY),A
	                           ;  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

step_X:	                           ;  stepx = (x1 < x2) ? 1 : -1;
	xor A                      ;  clear flags
	ld A,(_line_x1)            ;  load point X1
	ld H,A                     ;  copy to H register
	ld A,(_line_x2)            ;  load point X2
	sub H                      ;  subtract point 1 from point 2
	                           ;  ld H,A ; store answer in H

	jp c,negativeDX            ;  if carry flag is set, then X2 is smaller
	jp z,negativeDX            ;  if carry flag is set, then X2 is smaller

	                           ;  fall through if positive, X2 is larger
	                           ;  ;;;;;;;;;;;;;;;;;;;;;;;;;
positiveDX:	                   ;  point 2 is larger, going forwards
	ld A,1                     ;  set a to +1
	ld (stepX),A               ;  load into variable

	jp step_Y

	                           ;  ;;;;;;;;;;;;;;;;;;;;;;;
negativeDX:	                   ;  point 1 is larger, going backwards
	ld A,-1                    ;  set A to -1 or $FF
	ld (stepX),A               ;  load into variable
	                           ;  ;;;;;;;;;;;;;;;;;;;;;;;

step_Y:	                           ;  stepy = (y1 < y2) ? 1 : -1;
	xor A                      ;  clear flags
	ld A,(_line_y1)            ;  load point X1
	ld H,A                     ;  copy to H register
	ld A,(_line_y2)            ;  load point X2
	sub h                      ;  subtract point 1 from point 2
	                           ;  ld H,A ; store answer in H

	jp c,negativeDY            ;  if carry flag is set, then Y2 is smaller
	jp z,negativeDY            ;  if equal, then set Y2 as negative

	                           ;  fall through if positive, Y2 is larger
	                           ;  ;;;;;;;;;;;;;;;;;;;;;;;;
positiveDY:
	ld A,1                     ;  set A to +1
	ld (stepY),A               ;  load into variable
	                           ;  ld A,H
	                           ;  ld (deltaY),A
	jp steps_calculation

negativeDY:
	ld A,-1                    ;  set A to -1 or $FF
	ld (stepY),A               ;  load into variable
	                           ;  ;;;;;;;;;;;;;;;;;;;;;;;

steps_calculation:	           ;  iterations = max(deltaX, deltaY);
	xor A                      ;  clear flags
	ld A,(deltaY)              ;  load in length of X axis
	ld H,A
	ld A,(deltaX)              ;  load in length of Y axis
	cp H                       ;  compare against deltaX
	jr c,delta_Y_max           ;  if carry flag is set, then delta_Y is larger

delta_X_max:
	ld A,(deltaX)              ;  now that deltaX is the maximum, load it into A
	jr max_steps

delta_Y_max:
	ld A,(deltaY)              ;  now that deltaY is the maximum, load it into A

max_steps:
	ld (iterations),A          ;  now we know the maximum pixels that will be used

	ld A,(_line_x1)
	ld D,A
	ld A,(_line_y1)
	ld E,A
	ld (_gfx_xy),DE
	call _hellaPlot

	                           ;  ;;;;;;;;;;;;;;;;;;;;;;;;
	                           ;  lets start our loop
	                           ;  ;;;;;;;;;;;;;;;;;;;;;;;;

DXDY_loop:	                   ;
	                           ;  if (deltaX > deltaY)
	ld A,(deltaX)              ;  load in deltaX
	ld H,A                     ;  move to H
	ld A,(deltaY)              ;  load in deltaY
	cp H                       ;  now compare the two
	jp nc,deltaY_case          ;  if the Carry is not set then deltaY is larger
	                           ;  otherwise fall through


	                           ;  if (deltaX > deltaY) then deltaX_case
	                           ;  if (deltaY >= deltaX) then deltaY_case

	                           ;  ;;;;;;;;;;;;;;;;;;;;;;

deltaX_case:	                   ;  if (deltaX > deltaY)

	                           ;  fraction = deltaY - (deltaX >> 1);
	                           ;  fraction = deltaY - (deltaX / 2);
	                           ;  solve deltaX >> 1
	ld A,(deltaX)              ;  load in deltaX
	srl A                      ;  shift deltaX right to divide by 2
	ld L,A                     ;  load into L
	ld A,(deltaY)              ;  load in deltaY
	sub L
	ld (fraction),A            ;  store answer

deltaX_loop:
	                           ;  now plot our point
plot_DX:
	ld A,(_line_x1)
	ld D,A
	ld A,(_line_y1)
	ld E,A
	ld (_gfx_xy),DE
	call _hellaPlot

addorsubtractDX:

	ld A,(fraction)
	ld L,A
	xor A
	sub L

	jp z,subtract_x_fraction   ;  HL is = 0 Zero Flag is On
	jp p,add_x_fraction        ;  HL is > 0 Sign flag is Off
	jp m,subtract_x_fraction   ;  HL is < 0 Sign flag is On

subtract_x_fraction:	           ;  fraction >= 0

	                           ;  fraction -= deltaX;
	ld A,(deltaX)              ;  load in deltaX
	ld L,A                     ;  move to to L
	ld A,(fraction)            ;  load in fraction
	sbc A,L                    ;  subtract with carry
	ld (fraction),A            ;  write answer

	                           ;  y1 += stepY;
	ld A,(_line_y1)            ;  load lineY1
	ld H,A                     ;  move to H
	ld A,(stepY)               ;  load stepY
	add A,H                    ;  add the two
	ld (_line_y1),A            ;  write the answer

	                           ;  fraction < 0
add_x_fraction:
	                           ;  x1 += stepx;
	ld A,(_line_x1)            ;  load lineX1
	ld H,A                     ;  move to H
	ld A,(stepX)               ;  load stepX
	add A,H                    ;  add the two
	ld (_line_x1),A            ;  write the answer

	                           ;  fraction += deltaY;
	ld A,(fraction)            ;  load in fraction
	ld L,A                     ;  move to L
	ld A,(deltaY)              ;  load in deltaY
	add A,L                    ;  add the two
	ld (fraction),A            ;  write answer



DX_loop:
	                           ;  finally, we decrement our loop by 1
	ld A,(iterations)
	dec A
	ld (iterations),A


iterationDX:
	                           ;  iterations already in A
	cp 0                       ;  compare steps with iterations
	ret z                      ;  if no difference, Zero flag is set and we can return
	                           ;  otherwise continue the loop

	jp deltaX_loop             ;  jump back to start of loop




	                           ;  ;;;;;;;;;;;;;;;;;;;;;;

deltaY_case:	                   ;  if (deltaY >= deltaX)

	                           ;  fraction = deltaX - (deltaY >> 1);
	                           ;  fraction = deltaX - (deltaY / 2);
	                           ;  solve deltaX >> 1
	ld A,(deltaY)              ;  load in deltaY
	srl A                      ;  shift deltaX right to divide by 2
	ld L,A                     ;  load into L
	ld A,(deltaX)              ;  load in deltaX
	sub L
	ld (fraction),A            ;  store answer

deltaY_loop:
	                           ;  now plot our point
plot_DY:
	ld A,(_line_x1)
	ld D,A
	ld A,(_line_y1)
	ld E,A
	ld (_gfx_xy),DE
	call _hellaPlot

addorsubtractDY:

	ld A,(fraction)
	ld L,A
	xor A
	sub L

	jp z,subtract_y_fraction   ;  HL is = 0 Zero Flag is On
	jp p,add_y_fraction        ;  HL is > 0 Sign flag is Off
	jp m,subtract_y_fraction   ;  HL is < 0 Sign flag is On

subtract_y_fraction:	           ;  fraction >= 0

	                           ;  fraction -= deltaY;
	ld A,(deltaY)              ;  load in deltaY
	ld L,A                     ;  move to to L
	ld A,(fraction)            ;  load in fraction
	sbc A,L                    ;  subtract with carry
	ld (fraction),A            ;  write answer

	                           ;  x1 += stepX;
	ld A,(_line_x1)            ;  load lineX1
	ld H,A                     ;  move to H
	ld A,(stepX)               ;  load stepX
	add A,H                    ;  add the two
	ld (_line_x1),A            ;  write the answer

	                           ;  fraction < 0
add_y_fraction:
	                           ;  y1 += stepx;
	ld A,(_line_y1)            ;  load lineY1
	ld H,A                     ;  move to H
	ld A,(stepY)               ;  load stepY
	add A,H                    ;  add the two
	ld (_line_y1),A            ;  write the answer

	                           ;  fraction += deltaY;
	ld A,(fraction)            ;  load in fraction
	ld L,A                     ;  move to L
	ld A,(deltaX)              ;  load in deltaX
	add A,L                    ;  add the two
	ld (fraction),A            ;  write answer



DY_loop:
	                           ;  finally, we decrement our loop by 1
	ld A,(iterations)
	dec A
	ld (iterations),A


iterationDY:
	                           ;  iterations already in A
	cp 0                       ;  compare steps with iterations
	ret z                      ;  if no difference, Zero flag is set and we can return
	                           ;  otherwise continue the loop

	jp deltaY_loop             ;  jump back to start of loop


