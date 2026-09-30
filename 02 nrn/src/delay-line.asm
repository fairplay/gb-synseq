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
  ld [wDelayLinePtr], a
ret

.Read:
  ld b, a
  ld a, [wDelayLinePtr]
  sub b
  ld hl, wDelayLine
  ld l, a

  ld a, [hl]
ret

.Write:
  ld b, a
  ld hl, wDelayLine
  ld a, [wDelayLinePtr]
  inc a
  ld [wDelayLinePtr], a
  ld l, a

  ld a, b
  ld [hl], a
ret


SECTION "Delay Line", WRAM0, ALIGN[8]
wDelayLine:
  ds 256
wDelayLinePtr: db