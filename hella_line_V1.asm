start:
	call bresenham_line_1
endless:
	jp endless

	                           ;  variables
_line_x1:	defb 255           ;  line start point X
_line_y1:	defb 005           ;  line start point Y
_line_x2:	defb 000           ;  line end point X
_line_y2:	defb 000           ;  line end point Y

stepX:	defb 0                     ;  direction of travel horizontally
stepY:	defb 0                     ;  direction of travel vertically
steps:	defb 0                     ;  the total number of pixels to be plotted
iterations:	defb 0             ;  loop counter

deltaX:	defw 0                     ;  distance between points in X axis
deltaY:	defw 0                     ;  distance between points in Y axis

fraction:	defw 0             ;  deciding point on which way the next pixel will travel

;;gfx variables
_gfx_xy:	defw 0

	                           ;  variables


_hellaPlot:
	ret




bresenham_line_1:

deltaXABS:
	                           ;  deltaX = abs(x2 - x1);
	                           ;  first we perform x2-x1
	xor A                      ;  clear flags and A
	ld H,A                     ;  clear high byte of HL
	ld D,A                     ;  clear high byte of DE

	ld A,(_line_x1)            ;  load line start X into E of DE
	ld E,A
	ld A,(_line_x2)            ;  load line end X into L of HL
	ld L,A

	                           ;  https://learn.cemetech.net/index.php/Z80:Math_Routines#abs.5Breg8.5D
	                           ;  calculate ABS
	sbc HL,DE                  ;  difference between the two points
	bit 7,H                    ;  check the high bit of HL to see if the number is negative
	jp z,DXABS_finished        ;  if high bit not present, then the number is positive
	xor A                      ;  otherwise the number is negative, so lets calculate ABS
	sub L
	ld L,A
	sbc A,A
	sub H
	ld H,A

DXABS_finished:
	ld (deltax),HL             ;  ABS answer



	                           ;  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
deltaYABS:
	                           ;  deltaY = abs(y2 - y1);
	                           ;  first we perform y2-y1



	xor A                      ;  clear flags and A
	ld H,A                     ;  clear high byte of HL
	ld D,A                     ;  clear high byte of DE

	ld A,(_line_y1)            ;  load line start Y into E of DE
	ld E,A

	ld A,(_line_y2)            ;  load line end Y into L of HL
	ld L,A

	                           ;  https://learn.cemetech.net/index.php/Z80:Math_Routines#abs.5Breg8.5D
	                           ;  calculate ABS
	sbc HL,DE                  ;  difference between the two points
	bit 7,H                    ;  check the high bit of HL to see if the number is negative
	jp z,DYABS_finished        ;  if high bit not present, then the nuber is positive
	xor A                      ;  otherwise the number is negative, so lets calculate ABS
	sub L
	ld L,A
	sbc A,A

	sub H
	ld H,A

DYABS_finished:
	ld (deltaY),HL             ;  ABS answer
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

steps_calculation:	           ;  steps = max(deltaX, deltaY);
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
	ld (steps),A               ;  now we know the maximum pixels that will be used

	ld A,(_line_x1)
	ld D,A
	ld A,(_line_y1)
	ld E,A
	ld (_gfx_xy),DE
	call _hellaPlot

	                           ;  ;;;;;;;;;;;;;;;;;;;;;;;;
	                           ;  lets start our loop
	                           ;  ;;;;;;;;;;;;;;;;;;;;;;;;
	jp DXDY_loop

end_bresenham:	                   ;  <----------------- end routine
	ret



DXDY_loop:	                   ;
	                           ;  if (deltaX > deltaY)
	ld A,(deltaX)              ;  load in deltaX
	ld H,A                     ;  move to H
	ld A,(deltaY)              ;  load in deltaY
	cp H                       ;  now compare the two
	jp nc,delta_Y_larger       ;  if the Carry is not set then deltaY is larger
	                           ;  otherwise fall through


delta_X_larger:	                   ;  if (deltaX > deltaY)
	jp deltaX_case

	                           ;  else if (deltaY >= deltaX)
delta_Y_larger:
	jp deltaY_case

	                           ;  NOW we need to start treating
	                           ;  deltaX and deltaY as 16 bit variables
	                           ;  ;;;;;;;;;;;;;;;;;;;;;;

deltaX_case:	                   ;  if (deltaX > deltaY)

	                           ;  fraction = deltaY - (deltaX >> 1);
	                           ;  fraction = deltaY - (deltaX / 2);
	                           ;  solve deltaX >> 1
	ld DE,(deltaX)
	srl D                      ;  Shift high byte of deltaX right, LSB moves into carry
	rr E                       ;  Rotate low byte right through carry, completing division by 2
	                           ;  DE now has deltaX / 2 or deltaX >> 1

	ld HL,(deltaY)
	or A                       ;  Clear carry flag before subtraction
	sbc HL,DE                  ;  HL = deltaY - (deltaX / 2)
	ld (fraction),HL           ;  write answer

deltaX_loop:	                   ;  for (iterations = 0; iterations <= steps; iterations++)
	                           ;  incrementor
	xor A                      ;  clear flags
	ld A,(iterations)          ;  load in iterations
	ld H,A                     ;  move to H
	ld A,(steps)               ;  load in steps
	cp H                       ;  compare steps with iterations
	jr z,end_DX                ;  if no difference, Zero flag is set and we can break out
	                           ;  otherwise continue the loop

	                           ;  now plot our point
	ld A,(_line_x1)
	ld D,A
	ld A,(_line_y1)
	ld E,A
	ld (_gfx_xy),DE
	call _hellaPlot

	                           ;  everything needs to be adjusted here to assume fraction
	                           ;  is 16 bit, may have to use DE as well as HL
	                           ;  --- fraction is a 16 bit number

	xor A                      ;  clear carry flag
	ld DE,(fraction)           ;  load 16 bit fraction
	ld HL,0                    ;  load our compare value
	sbc HL,DE                  ;  compare against 0

	jp z,subtract_x_fraction   ;  HL is = 0 Zero Flag is On
	jp p,add_x_fraction        ;  HL is > 0 Sign flag is Off
	jp m,subtract_x_fraction   ;  HL is < 0 Sign flag is On

subtract_x_fraction:	           ;  fraction >= 0

	                           ;  fraction -= deltaX;
	ld HL,(fraction)           ;  load HL with fraction
	ld DE,(deltaX)             ;  load DE with deltaX
	sbc HL,DE                  ;  subtract deltaX
	ld (fraction),HL           ;  write the answer

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
	or A                       ;  clear our flags
	ld A,(deltaY)              ;  load in our deltaY
	ld HL,(fraction)           ;  load in our fraction 16 bit variable
	add A,L                    ;  add the two
	ld L,A                     ;
	jr nc,DX_fraction          ;  if no carry, skip incrementing H
	inc H

DX_fraction:
	ld (fraction),HL           ;  write the Answer
	                           ;  115 / 120 T
	                           ;  26 bytes

	                           ;  finally, we increment our loop by 1
	ld A,(steps)
	dec A
	ld (steps),A

	jp deltaX_loop             ;  jump back to start of loop

end_DX:
	jp end_bresenham

	                           ;  ;;;;;;;;;;;;;;;;;;;;;;

deltaY_case:	                   ;  if (deltaY > deltaX)

	                           ;  fraction = deltaX - (deltaY >> 1);
	                           ;  fraction = deltaX - (deltaY / 2);

	                           ;  Assuming deltaX is in HL and deltaY is in DE:
	                           ;  solve deltaY >> 1
	ld DE,(deltaY)
	srl D                      ;  Shift high byte of deltaX right, LSB moves into carry
	rr E                       ;  Rotate low byte right through carry, completing division by 2
	                           ;  DE now has deltaY / 2 or deltaY >> 1

	ld HL,(deltaX)
	or a                       ;  Clear carry flag before subtraction
	sbc hl,de                  ;  HL = deltaX - (deltaY / 2)
	ld (fraction),HL           ;  write answer

deltaY_loop:	                   ;  for (iterations = 0; iterations <= steps; iterations++)

	                           ;  incrementor
	xor A                      ;  clear flags
	ld A,(iterations)
	ld H,A
	ld A,(steps)
	cp H                       ;  compare steps with iterations
	jr z,end_DY                ;  if no difference, Zero flag is set and we can break out
	                           ;  otherwise continue the loop

	                           ;  now plot our point
	ld A,(_line_x1)
	ld D,A
	ld A,(_line_y1)
	ld E,A
	ld (_gfx_xy),DE
	call _hellaPlot


	                           ;  everything needs to be adjusted here to assume fraction
	                           ;  is 16 bit, may have to use DE as well as HL
	                           ;  --- fraction is a 16 bit number

	xor A                      ;  clear carry flag
	ld DE,(fraction)           ;  load 16 bit fraction
	ld HL,0                    ;  load our compare value
	sbc HL,DE                  ;  compare against 0

	jp z,subtract_y_fraction   ;  HL is = 0
	jp m,subtract_y_fraction   ;  HL is < 0
	jp p,add_y_fraction        ;  HL is > 0

subtract_y_fraction:	           ;  fraction >= 0

	                           ;  fraction -= deltaY;
	ld HL,(fraction)
	ld DE,(deltaY)
	sbc HL,DE
	ld (fraction),HL

	                           ;  x1 += stepx;
	ld A,(_line_x1)
	ld H,A
	ld A,(stepX)
	add A,H
	ld (_line_x1),A

	                           ;  fraction < 0
add_y_fraction:	                   ;  add_y_fraction:
	                           ;  y1 += stepY;
	ld A,(_line_y1)
	ld H,A
	ld A,(stepY)
	add A,H
	ld (_line_y1),A

	                           ;  fraction += deltaY;
	or A
	ld A,(deltaX)
	ld HL,(fraction)
	add A,L
	ld L,A
	jr nc,DY_fraction          ;  if no carry, skip incrementing H
	inc H

DY_fraction:
	ld (fraction),HL

	                           ;  finally, we increment our loop by 1
	ld A,(steps)
	dec A
	ld (steps),A

	jp deltaY_loop

end_DY:
	jp end_bresenham
