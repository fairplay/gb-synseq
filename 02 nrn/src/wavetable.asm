MACRO mix
  add a, b
  srl a
  and $0F

  mix_interlace
ENDM

MACRO mix_interlace
  ld b, a

  ld hl, wWaveTableBuf
  ldh a, [wWaveTablePtr]
  srl a
  jr c, .loNibble
  or a, l
  ld l, a
  swap b
  ld [hl], b
  jr :+

.loNibble:
  or a, l
  ld l, a
  ld a, b
  or a, [hl]
  ld [hl], a
:
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

  ldh [wWaveTablePtr], a
  ldh [wWaveTableTriggered], a
  ldh [wWaveTableCounter + 1], a

  ld a, WAVETABLE_DURATION
  ldh [wWaveTableCounter], a

  ; call RissetDrum.Init
  call Kick.Init
  call KarplusStrong.Init
ret

.Trigger:
  ld a, 1
  ldh [wWaveTableTriggered], a
  xor a
  ldh [wWaveTablePtr], a
  ldh [wWaveTableCounter + 1], a

  ld a, WAVETABLE_DURATION
  ldh [wWaveTableCounter], a

  ; call RissetDrum.Reset
  call Kick.Reset
  call KarplusStrong.Reset

ret

.NextSample:
  ; call RissetDrum.NextSample
  call KarplusStrong.NextSample
  ld b, a
  ; push af
  ; call KarplusStrong.NextSample
  ; ld b, a
  ; pop af

  mix

  ld hl, wWaveTableCounter + 1
  dec [hl]
  jr nz, :+
  dec hl
  dec [hl]
  jr nz, :+
  xor a
  ldh [wWaveTableTriggered], a

:
  ldh a, [wWaveTablePtr]
  inc a
  and 31
  ldh [wWaveTablePtr], a
:
ret

.Copy:
  ld hl, wWaveTableBuf

  ld c, LOW(_AUD3WAVERAM)
REPT 16
  ld a, [hli]
  ldh [c], a
  inc c
ENDR

ret

SECTION "WaveTable Buffer", WRAM0, ALIGN[4]
wWaveTableBuf:
  ds 16

SECTION "WaveTable Vars", HRAM
wWaveTableTriggered: db
wWaveTablePtr: db
wWaveTableCounter: dw