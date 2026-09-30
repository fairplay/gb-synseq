SECTION "Shift Register", ROM0

def ShiftRegister_OverlayOffset equ TILEMAP0 + 15 * 32 + 16

ShiftRegister:
.Shift: ;https://firmware.phazerville.com/RunglBook
  ld b, a
  swap a
  and $0F
  jr z, .feed
  ld a, [wShiftRegister]
  rlca
  ld b, a
  get RunglerParams, xor
  xor a, b
  jr .saveRegister
.feed:
  ld a, b
  and $0F
  jr z, .feed0
.feed1:
  ld a, [wShiftRegister]
  or a, 1
  sla a
  jr .saveRegister
.feed0:
  ld a, [wShiftRegister]
  and a, %1111_1110
  sla a
.saveRegister:
  ld [wShiftRegister], a
  ret

.Draw:
  ld hl, ShiftRegister_OverlayOffset
  ld a, [wShiftRegister]
  ld c, 8

.drawDigit
  ld b, a
  and a, 1
  jr z, .draw0
  ld [hl], '-'
  jr :+
.draw0:
  ld [hl], '_'
:
  ld a, b
  srl a
  dec hl
  dec c
  jr nz, .drawDigit
  ret