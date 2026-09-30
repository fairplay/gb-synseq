MACRO wavetable_interleave
  ld b, a

  ld hl, wWaveTableBuf
  ldh a, [hWaveTablePtr]
  srl a
  or a, l
  ld l, a
  ld a, [hl]
  and $F0
  or a, b
  swap a
  ld [hl], a
ENDM

SECTION "WaveTable Impl", ROM0

WaveTable:

.Init:
  ld c, 16
  ld hl, wWaveTableBuf
  xor a
:
  ld [hli], a
  dec c
  jr nz, :-

  ldh [hWaveTablePtr], a
  ldh [hWaveTableTriggered], a
  ldh [hWaveTableCounter + 1], a

  ld a, WAVETABLE_DURATION
  ldh [hWaveTableCounter], a

  call Synth.Init
ret

.Trigger:
  ld a, 1
  ldh [hWaveTableTriggered], a
  xor a
  ldh [hWaveTablePtr], a
  ldh [hWaveTableCounter + 1], a

  ld a, WAVETABLE_DURATION
  ldh [hWaveTableCounter], a

  call Synth.Reset
ret

.NextSample:
  call Synth.NextSample

  wavetable_interleave

  ld hl, hWaveTableCounter + 1
  dec [hl]
  jr nz, :+
  dec hl
  dec [hl]
  jr nz, :+
  xor a
  ldh [hWaveTableTriggered], a

:
  ldh a, [hWaveTablePtr]
  inc a
  and 31
  ldh [hWaveTablePtr], a
ret

.Copy:
  ld hl, wWaveTableBuf

  ld c, LOW(_AUD3WAVERAM)
REPT 16
  ld a, [hli]
  swap a ; interleave leaves nibbles reversed
  ldh [c], a
  inc c
ENDR

ret

SECTION "WaveTable Buffer", WRAM0, ALIGN[4]
wWaveTableBuf:
  ds 16

SECTION "WaveTable Vars", HRAM
hWaveTableTriggered: db
hWaveTablePtr: db
hWaveTableCounter: dw