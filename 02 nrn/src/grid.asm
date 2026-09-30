MACRO grid_handle_key ; target grid, key
  ld a, 1
  put Grid\1, needsRedraw

  ifzero Grid\1, editing
  jr z, :+
  grid_change_param \2
ret
:
  grid_move \2
ret
ENDM

MACRO grid_clean_selected
  call {grid_name}.GetSelectedData
  ld c, $00
  call {grid_name}.DrawParam
ENDM

MACRO grid_draw_selected
  call \1.GetSelectedData
  ld c, $80
  call \1.DrawParam
ENDM

DEF changeUp EQUS "$10"
DEF changeDown EQUS "$F0"
DEF changeLeft EQUS "$FF"
DEF changeRight EQUS "$01"
MACRO grid_change_param ; direction
  ld de, w{grid_name}Params
  get {grid_name}, selected
  ld c, a
  ld a, change\1
  call .ChangeSelectedValue
  ld de, .MaxValues
  call .Wrap
ENDM

MACRO grid_move_up
  ld a, {grid_name_uc}_W
  call .MoveDec
ENDM

MACRO grid_move_down
  ld a, {grid_name_uc}_W
  call .MoveInc
ENDM

MACRO grid_move_left
  ld a, 1
  call .MoveDec
ENDM

MACRO grid_move_right
  ld a, 1
  call .MoveInc
ENDM

MACRO grid_move ; target grid, direction
  REDEF lc_dir EQUS STRLWR("\1")
  grid_clean_selected
  grid_move_{lc_dir}
ENDM

MACRO draw_nibble
  cp 10
  jr c, :+
  add 7
:
  add a, '0' - $10
ENDM

MACRO grid_create ; grid name

REDEF grid_name EQUS "Grid\1"
REDEF grid_name_uc EQUS STRUPR("GRID_\1")

.Init:
  call {grid_name}.Setup
  ld hl, w{grid_name}
  xor a
  put {grid_name}, selected
  put {grid_name}, editing
  inc a
  put {grid_name}, needsRedraw

  ld de, .Overlay
  ld hl, TILEMAP0
  ld b, (.OverlayEnd - .Overlay) / 20
  call CopyTileMap
ret

.Draw:
  FOR I, {grid_name_uc}_W * {grid_name_uc}_H
    ld hl, .Offsets + 2 * I + 1
    ld d, [hl]
    ld hl, .Offsets + 2 * I
    ld e, [hl]
    ld hl, {grid_name_uc}_OVERLAY_OFFSET
    add hl, de
    ld a, [w{grid_name}Params + I]
    call .DrawParam
  ENDR
  grid_draw_selected {grid_name}
ret

.DrawParam:
; mut a  : param value
; mut hl : tilemap offset
  ld b, a

  swap a
  and $0F
  draw_nibble
  sub a, c

  ld [hli], a

  ld a, b
  and $0F
  draw_nibble
  sub a, c

  ld [hl], a

ret

.GetSelectedData:
;  ret a : selected value
; ret hl : tilemap offset

  ld hl, w{grid_name}Params
  get {grid_name}, selected
  ld d, 0
  ld e, a
  add hl, de
  ld a, [hl]
  ld b, a

  ld hl, .Offsets
  get {grid_name}, selected
  sla a
  ld d, 0
  ld e, a
  add hl, de
  ld a, [hli]
  ld e, a
  ld a, [hl]
  ld d, a
  ld hl, {grid_name_uc}_OVERLAY_OFFSET

  add hl, de
  ld a, b

ret

.ChangeSelectedValue:
; mut a  : param value shift
;     c  : selected param id
;     de : params array
; mut hl
; mut b
; ret a  : new value
  ld b, a
  ld h, 0
  ld l, c
  add hl, de
  ld a, [hl]
  add a, b
ret

.Wrap:
; mut a  : param value
; mut b
;     c  : selected param id
;     de : max values array
; mut hl
  push hl
  ld b, a ; preserve new value
  ld h, 0
  ld l, c
  add hl, de
  ld c, [hl] ; max value
  ld a, b
  and a, c
  pop hl
  ld [hl], a
ret

.MoveInc:
  ld b, a
  get {grid_name}, selected
  add b
  cp {grid_name_uc}_W * {grid_name_uc}_H
  jr c, :+
  sub {grid_name_uc}_W * {grid_name_uc}_H
:
  put {grid_name}, selected
ret

.MoveDec:
  ld b, a
  get {grid_name}, selected
  sub b
  jr nc, :+
  add {grid_name_uc}_W * {grid_name_uc}_H
:
  put {grid_name}, selected
ret

ENDM