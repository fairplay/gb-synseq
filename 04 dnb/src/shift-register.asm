SECTION "Shift Register Impl", ROM0

def SR_TILEMAP_OFFSET equ TILEMAP0 + 15 * 32 + 10

ShiftRegister:
.Init:
  xor a
  ldh [hShiftRegister], a
ret

.Shift
  mod length, MAX_LENGTH
  inc a
  ld c, a

  ldh a, [hShiftRegister]
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

  get MainParams, prob
  ld c, a
  ld a, [rDIV]
  swap a
  and $0F
  cp a, c
  ld a, b
  jr c, :+
  jr z, :+
  xor a, 1
:
  ldh [hShiftRegister], a
ret

.Draw:
  ld hl, SR_TILEMAP_OFFSET + 7
  mod length, MAX_LENGTH
  inc a
  ld c, a
  ld a, 9
  sub c
  ld d, a
  ldh a, [hShiftRegister]

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
hShiftRegister: db