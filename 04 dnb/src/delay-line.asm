MACRO delay_line_load
  ld h, HIGH(wDelayLine)
  ldh a, [hDelayLinePtr]
  ld \1, a
ENDM

MACRO delay_line_read
  cpl
  inc a
  add \1
  ld l, a
  ld a, [hl]
ENDM

MACRO delay_line_write
  ld b, a
  ld h, HIGH(wDelayLine)
  ldh a, [hDelayLinePtr]
  inc a
  ldh [hDelayLinePtr], a
  ld l, a

  ld a, b
  ld [hl], a
ENDM

SECTION "Delay Impl", ROM0

DelayLine:

.Init:
  ld c, 0
  ld hl, wDelayLine
  ld a, $00
:
  ld [hli], a
  dec c
  jr nz, :-

  xor a
  ldh [hDelayLinePtr], a
ret

SECTION "Delay Line", WRAM0, ALIGN[8]
wDelayLine:
  ds 256

SECTION "Delay Line Vars", HRAM
hDelayLinePtr: db