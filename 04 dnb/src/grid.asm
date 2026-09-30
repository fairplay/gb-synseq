def GRID_PAGE_NAMES_OFFSET equ TILEMAP0 + 2 * 32 + 1
def GRID_START_OFFSET equ TILEMAP0 + 2 * 32 + 5
def GRID_PARAM_OFFSET equ TILEMAP0 + 2 * 32 + 10
def GRID_LABEL_LENGTH equ 3
def GRID_PAGE_WIDTH   equ 2
def GRID_LAST_PAGE    equ 2
def GRID_PAGE_CHANGE_STAGES equ 5

rsreset
def Grid_selected       rb 1   ; Currently selected parameter number
def Grid_editing        rb 1   ; Currently editing parameter number
def Grid_needsRedraw    rb 1
def Grid_activePage     rb 1
def Grid_pressedSelect  rb 1
def Grid_pageChanged    rb 1
def Grid_SIZEOF         rb 0

SECTION "Grid Pages", ROM0
GridPagesNames:
  db "s"
  db "p"
  db "k"

GridPagesLabels:
.$0:
  db "rte"
  db "prb"
  db "len"
  db "msk"
.$1:
  db "frq"
  db "lvl"
  db "dec"
  db "swp"
  db "shp"
.$2:
  db "frq"
  db "lvl"
  db "dla"
  db "dlb"
.$3

ALIGN 4
GridPagesHeights:
FOR page, 0, GRID_LAST_PAGE + 1
  DEF next_page = page + 1
  STATIC_ASSERT GridPagesLabels.{next_page} - GridPagesLabels.{page} <= 8 * GRID_LABEL_LENGTH, "Grid Page height should be <= 8 rows"
  db (GridPagesLabels.{next_page} - GridPagesLabels.{page}) / GRID_LABEL_LENGTH
ENDR

GridPagesParamsOffsets:
FOR page, 0, GRID_LAST_PAGE + 1
.{page}:
  db GRID_PAGE_WIDTH * (GridPagesLabels.{page} - GridPagesLabels.$0) / GRID_LABEL_LENGTH
ENDR

GridPagesParamsMaxValues:
.$0:
  db MAX_RATE, MAX_MOD
  db MAX_PROB, MAX_MOD
  db MAX_LENGTH, MAX_MOD
  db MAX_GATE_MASK, MAX_GATE_MASK
.$1:
  db MAX_PULSE_FREQ, MAX_MOD
  db MAX_PULSE_LEVEL, MAX_MOD
  db MAX_PULSE_DECAY, MAX_MOD
  db MAX_PULSE_SWEEP, MAX_MOD
  db MAX_PULSE_SHAPE, MAX_MOD
.$2:
  db MAX_WAVE_FREQ, MAX_MOD
  db MAX_WAVE_LEVEL, MAX_MOD
  db MAX_KS_DELAY, MAX_MOD
  db MAX_KS_DELAY, MAX_MOD

;;;;
SECTION "Grid Impl", ROM0
Grid:

.Setup:
  xor a
  ldh [hBinCounter], a

  ld a, 1
  ldh [hRateCounter + 1], a
  ldh [hRateCounter], a
ret

grid_create

.KeysProcess:
.padSelect:
  ldh a, [hCurKeys]
  and a, PAD_SELECT
  jr z, .releasedSelect
  ld a, 1
  put Grid, pressedSelect
  jr .padA
.releasedSelect:
  xor a
  put Grid, pressedSelect
.padA:
  ldh a, [hCurKeys]
  and a, PAD_A
  jr z, .releasedA
  ld a, 1
  put Grid, editing
  jr .arrows
.releasedA:
  xor a
  put Grid, editing
.arrows:
  grid_on_key_press Left
  grid_on_key_press Right
  grid_on_key_press Up
  grid_on_key_press Down
ret

SECTION "Grid Arrays", WRAM0
wGrid:
  ds Grid_SIZEOF

wGridParams:
wMainParams:
  ds MainParams_SIZEOF

SECTION "Grid Vars", HRAM
hActivePageHeight:  db
hActivePageSize:    db

; TODO: move to appropriate place
hRateCounter:       dw
hBinCounter:        db
