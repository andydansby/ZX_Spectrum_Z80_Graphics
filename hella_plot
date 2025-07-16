main:
	ld A,(_gfx_x)
	ld H,A
	ld A,(_gfx_y)
	ld L,A
	ld (_gfx_xy),HL
	call _hellaPlot2

done:
	jp done
;
; GRAPHICS PLOTTING ROUTINE FOR THE ZX Spectrum
; 
_gfx_x:	defb 0              ; Current X coordinate (0-255)
_gfx_y:	defb 0              ; Current Y coordinate (0-191) 
_gfx_xy:	defw 0      ; Combined X,Y coordinate pair (little-endian)

; Lookup table for X-axis bit positions
X_PositionBits:	defb 128,64,32,16,8,4,2,1
	                           ;  ;;;;;;;;;;;;

; Function: _hellaPlot2
; Purpose:  Plots a single pixel at coordinates stored in *gfx*xy
; Input:    Coordinates should be pre-loaded into *gfx*xy
;           B = X coordinate (0-255)
;           C = Y coordinate (0-191 typical for 256x192 display)
; Output:   Pixel set in video memory
; Destroys: A, BC, HL
; Timing:   166 T-states per pixel
_hellaPlot2:	                   ;  plot B = x-axis, C = y-axis
	ld BC,(_gfx_xy)            ;  load xy pair
	xor A                      ;  reset a to 0 and flags to default

	ld A,C                     ; A = Y coordinate

	rra                        ;  rotate Right ----------- divide in half
	scf                        ;  set carry flag --------- turn on Carry flag
	rra                        ;  rotate right
	or A                       ;  Reset flags
	rra                        ;  rotate right

	ld L,A                     ; Temporarily store calculated value in L

                                   ; Apply bit manipulation to refine the address calculation
	xor C                      ; XOR with original Y coordinate
	and %11111000              ; Mask to keep only upper 5 bits
	xor C                      ; XOR back with Y coordinate

	ld H,A                     ; H = high byte of screen address

                                   ; Calculate low byte of screen address
	ld A,B                     ;  load Y plot point
	xor L                      ; XOR with previously calculated value
	and %00000111              ; Keep only lower 3 bits (X % 8)
	xor B                      ; XOR back with X coordinate
	rrca                       ; Rotate right
	rrca                       ; Rotate right
	rrca                       ; Rotate right

	ld L,A                     ; L = low byte of screen address
	                           ; At this point: HL = complete screen memory address for the pixel

	                           ;  now use LUT to find which bit to set
	ld A,B                     ; A = X coordinate
	and %00000111              ; A = X % 8 (which bit within the byte)
	                           ;  use a LUT to quickly find the bit position for the X position
	ld BC,X_PositionBits       ; BC points to start of lookup table
	add A,C                    ; Add offset to table base address
	ld C,A                     ; C = address of required bit mask
	ld A,(BC)                  ; A = bit mask for this X position

	                           ;  output to screen
	or (HL)                    ; OR the bit mask with existing byte in screen memory
	ld (HL),A                  ; Store the modified byte back to screen memory
	ret
