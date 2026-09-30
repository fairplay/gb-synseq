MACRO get
  ld a, [w\1 + \1_\2]
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

MACRO lcd_off
  ld a, LCDC_OFF
  ldh [rLCDC], a
ENDM

MACRO lcd_on
  ld a, LCDC_ON | LCDC_BG_ON
  ld [rLCDC], a
ENDM

MACRO mul_b_c ; b * c -> a
  ld a, 0
:
  srl b
  jr z, :++
  jr nc, :+
  add a, c
:
  sla c
  jr :--
:
  jr nc, :+
  add a, c
:
ENDM

MACRO handle_start_key
  ld a, [wPlay]
  xor a, 1
  ld [wPlay], a

  ld hl, rNR50
  jr z, .soundOff
  ld [hl], $77
  ret
.soundOff:
  ld [hl], $00
  ret
ENDM

MACRO handle_arrow_key ; key
  ld a, 1
  put Grid, needsRedraw

  get Grid, editing
  and a
  jr z, .Move\1
  call Grid.ChangeParam\1
  ret
.Move\1
  call Grid.Move\1
  ret
ENDM

MACRO on_key_press ; key, callback, callback arg
  ld a, [wNewKeys]
  and a, PAD_\1
  jr z, nextKey\@
  \2 \3
nextKey\@:
ENDM