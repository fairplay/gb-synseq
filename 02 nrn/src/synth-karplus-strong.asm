SECTION "Karplus-Strong", ROM0

KarplusStrong:

.Init:
  call DelayLine.Init
  call .Reset
ret

.Reset:
  xor a
  ld [wNoisePtr], a
  ld [wDelayLinePtr], a
ret

.NextSample:
  ld a, [wNoisePtr]
  cp a, 32
  jr nc, :+

  inc a
  ld [wNoisePtr], a
  ld hl, WaveForm.NoiseWhite
  ld l, a
  ld a, [hl]
  jr :++
:
  ld a, 64
  call DelayLine.Read
  ld c, a
  ld a, 63
  call DelayLine.Read
  add a, c
  srl a
:
  call DelayLine.Write
ret

SECTION "KS data", WRAM0
wNoisePtr: db