SECTION "Shift Register Impl", ROM0

def SR_OVERLAY_OFFSET equ TILEMAP0 + 15 * 32 + 9

ShiftRegister:
.Init:
  xor a
  ldh [wShiftRegister], a
ret

.Shift
  get SeqParams, length
  inc a
  ld c, a

  ldh a, [wShiftRegister]
  ld b, a

:
  dec c
  jr z, :+
  srl a
  jr :-

:
  and 1
  sla b
  or a, b
  ld b, a

  get SeqParams, prob
  ld c, a
  ld hl, rPCM34
  ld a, [rDIV]
  xor a, [hl]
  swap a
  and $0F
  cp a, c
  ld a, b
  jr c, :+
  jr z, :+
  xor a, 1
:
  ldh [wShiftRegister], a
ret

.Draw:
  ld hl, SR_OVERLAY_OFFSET + 7
  get SeqParams, length
  inc a
  ld c, a
  ld a, 9
  sub c
  ld d, a
  ldh a, [wShiftRegister]

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

:
  dec d
  jr z, :+
  ld [hld], a
  jr :-
:
ret

SECTION "Shift Register Vars", HRAM
wShiftRegister: db