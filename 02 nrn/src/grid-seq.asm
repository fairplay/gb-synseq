SECTION "Seq Grid Impl", ROM0

rsreset
def GridSeq_selected    rb 1   ; Currently selected parameter
def GridSeq_editing     rb 1   ; Currently editing parameter
def GridSeq_needsRedraw rb 1   ; Flag for screen redraw
def GridSeq_SIZEOF      rb 0

def GRID_SEQ_W equ 2
def GRID_SEQ_H equ 8
def GRID_SEQ_OVERLAY_OFFSET equ TILEMAP0 + 2 * 32 + 12

GridSeq:
.Overlay:
  db "                    "
  db "                    "
  db " Noise Frq  ..  ..  "
  db " Noise Lvl  ..  ..  "
  db " Noise Dec  ..  ..  "
  db " LFSR/Rate  ..  ..  "
  db "  Wave Lvl  ..  ..  "
  db "  Wave Frq  ..  ..  "
  db " Prob/Leng  ..  ..  "
  db "  Gate Thr  ..  ..  "
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
FOR I, GRID_SEQ_H
  dw I * 32, I * 32 + 4
ENDR

.MaxValues:
  db MAX_NOISE_FREQ, MAX_MOD
  db MAX_NOISE_LEVEL, MAX_MOD
  db MAX_NOISE_DECAY, MAX_MOD
  db MAX_NOISE_LFSR, MAX_RATE
  db MAX_WAVE_LEVEL, MAX_MOD
  db MAX_WAVE_FREQ, MAX_MOD
  db MAX_PROB, MAX_LENGTH
  db MAX_GATE_THRESH, MAX_GATE_THRESH

.Setup:
  xor a
  ldh [wBinCounter], a

  ld a, 1
  ldh [wRateCounter + 1], a
  ldh [wRateCounter], a
ret

grid_create Seq

.KeysProcess:
  ld a, [wCurKeys]
  and a, PAD_A
  jr z, .SelectReleased
  ld a, 1
  put GridSeq, editing
  jr .Arrows
.SelectReleased
  xor a
  put GridSeq, editing
.Arrows
  ld a, [wNewKeys]
  and a, PAD_START
  jr z, :+
  call WaveTable.Trigger
:
  on_key_press grid, Seq, Left
  on_key_press grid, Seq, Right
  on_key_press grid, Seq, Up
  on_key_press grid, Seq, Down
ret

SECTION "GridSeq Arrays", WRAM0
wGridSeq:
  ds GridSeq_SIZEOF

wGridSeqParams:
wSeqParams:
  ds SeqParams_SIZEOF

SECTION "GridSeq Vars", HRAM
wRateCounter: dw
wBinCounter: db
