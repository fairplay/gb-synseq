SECTION "Grid", ROM0

rsreset
def Grid_selected    rb 1   ; Currently selected parameter
def Grid_editing     rb 1   ; Currently editing parameter
def Grid_needsRedraw rb 1   ; Flag for screen redraw
def Grid_SIZEOF      rb 0

def GRID_W equ 2
def GRID_H equ 6
def GRID_OVERLAY_OFFSET equ TILEMAP0 + 2 * 32 + 12

Grid:
.Overlay:
  db "                    "
  db "                    "
  db "     Pitch  ..  ..  "
  db "     P.Mod  ..  ..  "
  db "        FM  ..  ..  "
  db "     Shape  ..  ..  "
  db "     Level  ..  ..  "
  db "  Rate/Thr  ..  ..  "
  db "                    "
  db "                    "
  db "                    "
  db "                    "
  db "                    "
  db "                    "
  db "                    "
  db "         ........   "
  db "                    "
  db "                    "
.OverlayEnd
 STATIC_ASSERT .OverlayEnd - .Overlay == 18 * 20, "Grid Overlay height should be 18 lines"

.Offsets:
FOR I, GRID_H
  dw I * 32, I * 32 + 4
ENDR

.MaxValues:
  db MAX_PITCH, MAX_PITCH
  db MAX_MOD, MAX_MOD ; Pitch Mod
  db MAX_FM, MAX_FM
  db MAX_SHAPE, MAX_SHAPE
  db MAX_LEVEL, MAX_LEVEL
  db MAX_RATE, MAX_THRESH

.Init:
  ld hl, wGrid
  xor a
  put Grid, selected
  put Grid, editing
  inc a
  put Grid, needsRedraw

  ld de, .Overlay
  ld hl, TILEMAP0
  ld b, (.OverlayEnd - .Overlay) / 20
  call CopyTileMap
  ret

.Draw:
  FOR I, GRID_W * GRID_H
    ld hl, .Offsets + 2 * I + 1
    ld d, [hl]
    ld hl, .Offsets + 2 * I
    ld e, [hl]
    ld a, [wGridParams + I]
    call .DrawParam
  ENDR
  call .DrawSelected
  ret

.Redraw:
  call .DrawSelected
  ret

.CleanSelected:
  call .GetSelectedOffset
  call .GetSelectedValue
  call .DrawParam
  ret

.DrawSelected
  call .GetSelectedOffset
  call .GetSelectedValue
  call .DrawParamSelected
  ret

.DrawParam:
  ld b, a
  swap a
  and $0F

  call DrawNibble
  ld hl, GRID_OVERLAY_OFFSET
  add hl, de
  ld [hli], a

  ld a, b
  and $0F
  call DrawNibble

  ld [hl], a
  ret

.DrawParamSelected:
  ld b, a
  swap a
  and $0F

  call DrawNibble
  sub $80

  ld hl, GRID_OVERLAY_OFFSET
  add hl, de
  ld [hli], a

  ld a, b
  and $0F
  call DrawNibble
  sub $80

  ld [hl], a
  ret

.GetSelectedOffset:
  get Grid, selected
  ld hl, Grid.Offsets
  sla a
  ld b, 0
  ld c, a
  add hl, bc
  ld a, [hli]
  ld e, a
  ld a, [hl]
  ld d, a
  ret

.GetSelectedValue:
  ld bc, wGridParams
  get Grid, selected
  ld h, 0
  ld l, a
  add hl, bc
  ld a, [hl]
  ret

.Wrap:
  push hl
  ld de, .MaxValues
  ld b, a ; preserve new value
  get Grid, selected
  ld h, 0
  ld l, a
  add hl, de
  ld c, [hl] ; max value
  ld a, b
  and a, c
  pop hl
  ret

.ChangeSelectedValue:
  ld c, a
  ld de, wGridParams
  get Grid, selected
  ld h, 0
  ld l, a
  add hl, de
  ld a, [hl]
  ld b, a
  add a, c
  call .Wrap
  ld [hl], a
  ret

.ChangeParamUp:
  ld a, $10
  call .ChangeSelectedValue
  ret

.ChangeParamDown:
  ld a, $F0
  call .ChangeSelectedValue
  ret

.ChangeParamLeft:
  ld a, $FF
  call .ChangeSelectedValue
  ret

.ChangeParamRight:
  ld a, $01
  call .ChangeSelectedValue
  ret

.MoveInc:
  ld b, a
  get Grid, selected
  add b
  cp GRID_W * GRID_H
  jr c, :+
  sub GRID_W * GRID_H
  :
    put Grid, selected
    ret

.MoveDec:
  ld b, a
  get Grid, selected
  sub b
  jr nc, :+
  add GRID_W * GRID_H
  :
    put Grid, selected
    ret

.MoveUp
  call .CleanSelected
  ld a, GRID_W
  call .MoveDec
  ret

.MoveDown
  call .CleanSelected
  ld a, GRID_W
  call .MoveInc
  ret

.MoveLeft
  call .CleanSelected
  ld a, 1
  call .MoveDec
  ret

.MoveRight
  call .CleanSelected
  ld a, 1
  call .MoveInc
  ret

DrawNibble:
  cp 10
  jr c, :+
  add 7
:
  add a, '0' - $10
  ret