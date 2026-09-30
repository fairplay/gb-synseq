SECTION "Karplus-Strong", ROM0

Synth:

.Init:
  call DelayLine.Init
  call .Reset
ret

.Reset:
  xor a
  ldh [hNoisePtr], a
  ldh [hDelayLinePtr], a
ret

.NextSample:
  ldh a, [hNoisePtr]
  cp a, 32
  jr nc, :+

  inc a
  ldh [hNoisePtr], a
  ld h, HIGH(WaveForm.NoiseWhite)
  ld l, a
  ld a, [hl]
  jr :++

:
  delay_line_load c

  mod delay_a, MAX_KS_DELAY
  delay_line_read c
  ld d, a

  mod delay_b, MAX_KS_DELAY
  delay_line_read c
  add a, d
  srl a
:
  delay_line_write
  swap a
  and $0F
ret

SECTION "KS vars", HRAM
hNoisePtr: db