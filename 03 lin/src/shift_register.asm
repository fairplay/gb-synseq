SECTION "Shift Register", ROM0

def SR_OVERLAY_OFFSET equ TILEMAP0 + 15 * 32 + 9

ShiftRegister:

.Shift:
  ld b, a

  ld hl, wCounter
  inc [hl]
  get GblinParams, rate

  cp a, [hl]
  jr nc, :+
  xor a
  ld [hl], a

  ld a, b
  swap a
  and $0F
  jr z, :+
  ld hl, wAccum
  inc [hl]

  get GblinParams, thresh

  cp a, [hl]
  jr nc, :+

  xor a
  ld [hl], a

  ld a, b
  and $0F
  jr z, .feed0
  ld a, [wShiftRegister]
  rlca
  or 1
  ld [wShiftRegister], a
  jr :+
.feed0:
  ld a, [wShiftRegister]
  rlca
  and $FE
  ld [wShiftRegister], a
:
  ret

.Draw:
  ld hl, SR_OVERLAY_OFFSET + 7
  ld c, 8
  ld a, [wShiftRegister]

:
  ld b, a
  and 1
  ld a, $7B
  jr nz, :+
  ld a, $72
:
  ld [hld], a
  ld a, b
  rrca
  dec c
  jr nz, :--

  ld a, '.' - $10

  ret