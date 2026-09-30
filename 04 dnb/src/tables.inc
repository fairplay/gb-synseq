SECTION "Waveforms", ROM0, ALIGN[8]
WaveForm:

.NoiseWhite:
  DEF x = 137
  DEF spl = 0
  REPT 256
    DEF x = x * $01010101 + $B3B3B3B3
    DEF y = (x & (255 << 24)) >> 24
    db y
  ENDR

.Sine:
  DEF frq = 2.0
  DEF amp = 7.99
  FOR angle, 0.0, 1.0, 1.0/256
    DEF spl = MUL(SIN(MUL(angle, frq)) + 1.0, amp) / 1.0
    db spl
  ENDR

SECTION "Tables", ROM0, ALIGN[8]
Envelope:
  DEF amp = 1.0
  DEF damp = 0.9888
  REPT 256
    db MUL(amp, 15.99) / 1.0
    ; print MUL(amp, 15.99) / 1.0

    DEF amp = MUL(amp, damp)
  ENDR

MultTable:
  FOR x, 0, 16
    FOR y, 0, 16
      DEF p = x * y
      ; println x, " ", y, " ", p
      db p
    ENDR
  ENDR

SECTION "Scale", ROM0
; Pure intervals
; 1 1.5 1.25 1.75 1.125 1.375 1.625 1.875
Scale:
FOR oct, 1, 9
  DEF Freq = MUL(32.7, 1<<oct)
  dw 2048-131072/MUL(Freq, 1.0)
  dw 2048-131072/MUL(Freq, 1.5)
  dw 2048-131072/MUL(Freq, 1.25)
  dw 2048-131072/MUL(Freq, 1.75)
  dw 2048-131072/MUL(Freq, 1.125)
  dw 2048-131072/MUL(Freq, 1.375)
  dw 2048-131072/MUL(Freq, 1.625)
  dw 2048-131072/MUL(Freq, 1.875)
ENDR
.End

STATIC_ASSERT Scale.End - Scale == 64 * 2, "Scale length should be 128"

MACRO mult
  push hl
  swap a
  or a, \1

  ld h, HIGH(MultTable)
  ld l, a
  ld a, [hl]
  pop hl
ENDM