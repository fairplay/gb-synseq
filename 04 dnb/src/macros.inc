MACRO get
  ld a, [w\1 + \1_\2]
ENDM

MACRO ifzero
  ld a, [w\1 + \1_\2]
  or a
  jr z, \3
ENDM

MACRO put
  ld [w\1 + \1_\2], a
ENDM

MACRO push_all
  push af
  push bc
  push de
  push hl
ENDM

MACRO pop_all
  pop hl
  pop de
  pop bc
  pop af
ENDM

MACRO dac3_off
  xor a
  ldh [rNR30], a
ENDM

MACRO dac3_on
  ld a, $80
  ldh [rNR30], a
ENDM

MACRO lcd_off
  ld a, LCDC_OFF
  ldh [rLCDC], a
ENDM

MACRO lcd_on
  ld a, LCDC_ON | LCDC_BG_ON
  ld [rLCDC], a
ENDM