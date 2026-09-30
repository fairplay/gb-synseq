MACRO sine_reset
  xor a
  ldh [wSinePtr], a
  ldh [wRingModPtrCenter], a
  ldh [wRingModPtrBand], a
  ldh [wRingNoisePtr], a
  ldh [wSampleCounter], a

  ld a, RISSET_INITIAL_SAMPLE_COUNTER
  ldh [wSampleCounter + 1], a
ENDM

MACRO mult
  swap \1
  or a, \1

  ld hl, MultTable
  ld l, a
  ld a, [hl]
  swap a
  and $0F
ENDM

MACRO envelope_fast
  sla a
  jr nc, :+
  ld a, $FF
:
ENDM

MACRO envelope_slow
ENDM

MACRO apply_envelope
  ld b, a
  ldh a, [wSampleCounter]

  envelope_\1

  ld hl, Envelope
  ld l, a
  ld a, [hl]

  mult b
ENDM

SECTION "Risset Drum Synth Impl", ROM0
RissetDrum:

.Init:
  sine_reset
ret

.Reset:
  sine_reset
ret

.NextSample:
  ld hl, wSampleCounter + 1
  inc [hl]
  jr nz, .fundamental
  ld [hl], RISSET_INITIAL_SAMPLE_COUNTER
  dec hl
  ld a, [hl]
  add a, 1
  ld [hl], a
  jr nc, .fundamental
  ld [hl], $FF

.fundamental:
  ld hl, WaveForm.Sine

  ldh a, [wSinePtr]
  ld l, a
  ld a, [hl]
  apply_envelope slow

  ldh [wFundamental], a

.inharmonic:
  ld hl, WaveForm.SineInharm
  ldh a, [wSinePtr]
  ld l, a
  add a, 8
  ldh [wSinePtr], a
  ld a, [hl]
  apply_envelope slow

  ldh [wInharmonic], a

.ringMod:
  ld hl, WaveForm.NoiseWhite
  ldh a, [wRingNoisePtr]
  ld l, a
  inc a
  ldh [wRingNoisePtr], a
  ld a, [hl]
  ld b, a

  ld hl, WaveForm.Sine
  ldh a, [wRingModPtrBand]
  ld l, a
  add a, 1
  ld [wRingModPtrBand], a
  ld a, [hl]

  ldh a, [wRingModPtrCenter]
  ld l, a
  add a, 1
  ld [wRingModPtrCenter], a
  add a, [hl]
  srl a

  mult b
  apply_envelope fast

  ldh [wRingMod], a

.mix:
  ld a, [wRingMod]
  ld b, 15
  mult b

  ld c, a

  ld hl, wFundamental
  ld a, [wInharmonic]
  add [hl]
  srl a
  ld b, 0
  mult b

  add c
ret

SECTION "Sine Synth Vars", HRAM
wSinePtr: db
wRingNoisePtr: db
wRingModPtrCenter: db
wRingModPtrBand: db
wSampleCounter: dw
wFundamental: db
wInharmonic: db
wRingMod: db