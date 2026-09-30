MACRO grid_on_key_press ; key
  REDEF key EQUS STRUPR("\1")
  ldh a, [hNewKeys]
  and a, PAD_{key}
  jp z, .\1NextKey
  grid_handle_key \1

.\1NextKey:
ENDM

MACRO grid_handle_key ; key
  ld a, 1
  put Grid, needsRedraw
  ifzero Grid, pressedSelect, .goto1\@
  grid_change_page \1

.goto1\@:
  ifzero Grid, editing, .goto2\@
  grid_change_param \1

.goto2\@:
  grid_move \1
ENDM

MACRO grid_page_up
  or a
  jr nz, :+
  ld a, GRID_LAST_PAGE + 1
:
  dec a
  put Grid, activePage

  xor a
  put Grid, pageChanged
ENDM

MACRO grid_page_down
  cp a, GRID_LAST_PAGE
  jr nz, :+
  ld a, $FF

:
  inc a
  put Grid, activePage

  xor a
  put Grid, pageChanged
ENDM

MACRO grid_page_right
ENDM

MACRO grid_page_left
ENDM

MACRO grid_change_page
  REDEF lc_dir EQUS STRLWR("\1")
  get Grid, activePage
  grid_page_{lc_dir}
ret
ENDM

MACRO grid_choose_page ; number of pages hardcoded (because loop is not working for some reason)
  ld b, a
  get Grid, activePage
  cp a, 0
  jr z, .page0\@
  cp a, 1
  jr z, .page1\@
  cp a, 2
  jr z, .page2\@

.page0\@:
  ld de, GridPages\1.$0
  jr :+
.page1\@:
  ld de, GridPages\1.$1
  jr :+
.page2\@:
  ld de, GridPages\1.$2
  jr :+
:
  ld a, b
ENDM

MACRO grid_clean_selected
  call Grid.GetSelectedData
  ld c, $00
  call Grid.DrawParam
ENDM

MACRO grid_draw_selected
  call Grid.GetSelectedData
  ld c, $80
  call Grid.DrawParam
ENDM

MACRO grid_params_set_page
  get Grid, activePage
  grid_choose_page ParamsOffsets
  ld a, [de]
  ld d, 0
  ld e, a
  ld hl, wGridParams
  add hl, de
  ld d, h
  ld e, l
ENDM

DEF changeUp EQUS "$10"
DEF changeDown EQUS "$F0"
DEF changeLeft EQUS "$FF"
DEF changeRight EQUS "$01"
MACRO grid_change_param ; direction
  grid_params_set_page
  get Grid, selected
  ld c, a
  ld a, change\1
  call .ChangeSelectedValue

  grid_choose_page ParamsMaxValues
  call .Wrap
  ret
ENDM

MACRO grid_move_up
  ld a, GRID_PAGE_WIDTH
  call .MoveDec
ENDM

MACRO grid_move_down
  ld a, GRID_PAGE_WIDTH
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

MACRO grid_move ; direction
  REDEF lc_dir EQUS STRLWR("\1")
  grid_clean_selected
  grid_move_{lc_dir}
  ret
ENDM

MACRO draw_nibble
  cp 10
  jr c, :+
  add 7
:
  add a, '0' - $10
ENDM

MACRO grid_create
.Init:
  call Grid.Setup
  ld hl, wGrid
  xor a
  put Grid, selected
  put Grid, editing
  put Grid, activePage
  put Grid, pressedSelect

  ld a, GRID_PAGE_CHANGE_STAGES
  put Grid, pageChanged

  inc a
  put Grid, needsRedraw
ret

.Clear:
  ld hl, TILEMAP0
  ld b, 18

.clearLoop:
  ld c, 20
:
  ld [hl], ' ' - $10
  inc hl
  dec c
  jr nz, :-

  ld d, 0
  ld e, 12
  add hl, de
  dec b
  jr nz, .clearLoop
ret

.ClearTileArea:
  ld hl, GRID_START_OFFSET
  ld a, [hActivePageHeight]
  ld c, a
  srl c
  inc c

  get Grid, pageChanged
  and 1
  jr z, :+
  ld b, GRID_LABEL_LENGTH + 2 * 4
  jr .clearTileAreaLoop
:
  ld b, GRID_LABEL_LENGTH + 2 * 4 + 32
  ld d, b

.clearTileAreaLoop:
  ld a, ' ' - $10
  ld [hli], a
  dec b
  jr nz, .clearTileAreaLoop

  ld b, d
  dec c
  jr z, :+

  ld a, 32 + 32 - (GRID_LABEL_LENGTH + 2 * 4)
  add a, l
  ld l, a
  jr nc, .clearTileAreaLoop
  inc h
  jr .clearTileAreaLoop
:
ret

.CopyTileArea:
  ; de -- src
  ; hl -- dest
  ; b -- area width
  ; c -- area height
  push bc

.copyLoop:
  ld a, [de]
  sub a, $10 ; because of the shifted font memory
  ld [hli], a
  inc de
  dec b
  jr nz, .copyLoop

  pop bc
  dec c
  push bc
  jr z, :+

  ld a, 32
  sub b
  add a, l
  ld l, a
  jr nc, .copyLoop
  inc h
  jr .copyLoop
:
  pop bc
ret

.ChangePage:
  get Grid, activePage
  ld hl, GridPagesHeights
  or a, l
  ld l, a
  ld a, [hl]
  ldh [hActivePageHeight], a
  sla a
  ldh [hActivePageSize], a

  xor a
  put Grid, selected

  ld a, 1
  put Grid, needsRedraw
ret

.DrawPageNames:
  ld hl, GRID_PAGE_NAMES_OFFSET
  ld de, GridPagesNames
  ld c, GRID_LAST_PAGE + 1
  ld b, 1
  call .CopyTileArea
  get Grid, activePage

  ; mark selected page
  ld hl, GRID_PAGE_NAMES_OFFSET
  swap a
  sla a
  add a, l
  ld l, a
  jr nc, :+
  inc h
:
  ld a, -$80
  add a, [hl]
  ld [hl], a
ret

.DrawLabels:
  grid_choose_page Labels

  ld hl, GRID_START_OFFSET
  ldh a, [hActivePageHeight]
  ld c, a
  ld b, GRID_LABEL_LENGTH
  call .CopyTileArea
ret

.DrawParams:
  grid_params_set_page

  ld b, GRID_PAGE_WIDTH
  ldh a, [hActivePageHeight]
  ld c, a

  ld hl, GRID_PARAM_OFFSET

.loopDrawParam:
  ld a, [de]
  inc de

  push bc
  ld c, 0
  call .DrawParam
  pop bc

  dec b
  jr nz, :+
  ld b, GRID_PAGE_WIDTH
  dec c
  jr z, :++
  ld a, 31 - 2 * GRID_PAGE_WIDTH
  add a, l
  ld l, a
  jr nc, .loopDrawParam
  inc h
  jr .loopDrawParam

:
  ld a, 3
  add a, l
  ld l, a
  jr nc, .loopDrawParam
  inc h
  jr .loopDrawParam

:
  grid_draw_selected
ret

.DrawParam:
; mut a  : param value
; mut c  : shift for selected/not selected
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

  grid_params_set_page
  get Grid, selected
  ld h, 0
  ld l, a
  add hl, de
  ld a, [hl]
  ld b, a

  get Grid, selected
  ld c, a
  srl a
  ld h, 0
  ld l, a
  REPT 5
  add hl, hl
  ENDR
  ld a, c
  and 1
  jr z, :+
  ld d, 0
  ld e, 4
  add hl, de
:
  ld de, GRID_PARAM_OFFSET

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
  get Grid, selected
  add b
  ld hl, hActivePageSize
  cp [hl]
  jr c, :+
  sub [hl]
:
  put Grid, selected
ret

.MoveDec:
  ld b, a
  get Grid, selected
  sub b
  jr nc, :+
  ld hl, hActivePageSize
  add [hl]
:
  put Grid, selected
ret

ENDM