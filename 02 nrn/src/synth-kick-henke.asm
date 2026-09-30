MACRO sine_reset
  xor a
  ldh [wKickSinePtr], a
  ldh [wKickFreqDamp], a
  ld [wKickLastSample], a

  ld hl, wKickBuffer
  ld de, WaveForm.Sine
  ld c, 0
:
  ld a, [de]
  ld [hli], a
  ld a, e
  add a, 32
  ld e, a
  dec c
  jr nz, :-

ENDM

SECTION "Kick Synth Impl", ROM0

Kick:

.Init:
  sine_reset
ret

.Reset:
  sine_reset
ret

.NextSample:
  ld a, [wKickLastSample]
  ld b, a

  ld hl, wKickBuffer
  ldh a, [wKickSinePtr]
  ld l, a
  ld a, [hl]

  add b
  srl a

  ld b, a

.incPtr:
  ldh a, [wKickFreqDamp]
  and $07
  inc a
  ld c, a

  ld a, b
:
  ld [hli], a
  dec c
  jr nz, :-

  ld a, l
  ldh [wKickSinePtr], a
  or a

  jr nz, .returnSample

  ldh a, [wKickFreqDamp]
  add a, 12
  sla a
  ldh [wKickFreqDamp], a

.returnSample:
  ld a, b
  ld [wKickLastSample], a
ret

SECTION "Sine Wave Buffer", WRAM0, ALIGN[8]
wKickBuffer:
  ds 256

SECTION "Sine Synth Vars", HRAM
wKickSinePtr: db
wKickFreqDamp: db
wKickLastSample: db