SECTION "Waveforms", ROM0, ALIGN[8]
WaveForm:

.NoiseWhite:
  DEF x = 137
  DEF spl = 0
  REPT 256
    DEF x = x * $01010101 + $B3B3B3B3
    DEF y = (x & (255 << 24)) >> 24 & $0F
    db y
  ENDR

.Sine:
  DEF frq = 1.0
  DEF amp = 8.0
  FOR angle, 0.0, 1.0, 1.0/256
    DEF spl = MUL(SIN(MUL(angle, frq)) + 1.0, amp) / 1.0
    db spl
  ENDR

.SineInharm:
  DEF frq1 = 1.0
  DEF frq2 = 1.6
  DEF frq3 = 2.2
  DEF frq4 = 2.3

  DEF amp1 = 1.0
  DEF amp2 = 1.5
  DEF amp3 = 2.0
  DEF amp4 = 1.5

  FOR angle, 0.0, 1.0, 1.0/256
    DEF p1 = MUL(SIN(MUL(angle, frq1)), amp1)
    DEF p2 = MUL(SIN(MUL(angle, frq2)), amp2)
    DEF p3 = MUL(SIN(MUL(angle, frq3)), amp3)
    DEF p4 = MUL(SIN(MUL(angle, frq4)), amp4)
    DEF p = p1 + p2 + p3 + p4
    DEF spl = (MUL(p + 1.0, 8.0) / 1.0) & $0F
    db spl
  ENDR

SECTION "Tables", ROM0, ALIGN[8]
Envelope:
  DEF amp0 = 1.0
  DEF damp = 0.988
  REPT 256
    DEF amp = MUL(amp0, 15.99) / 1.0
    DEF amp0 = MUL(amp0, damp)
    db amp
  ENDR

MultTable:
  FOR x, 0, 16
    FOR y, 0, 16
      DEF p = x * y
      db p
    ENDR
  ENDR