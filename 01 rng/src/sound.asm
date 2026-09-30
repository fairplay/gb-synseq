SECTION "Sound", ROM0

rsreset
def RunglerParams_pitch1     rb 1
def RunglerParams_pitch2     rb 1
def RunglerParams_sweep1     rb 1
def RunglerParams_sweep1_mod rb 1
def RunglerParams_shape1     rb 1
def RunglerParams_shape2     rb 1
def RunglerParams_level1     rb 1
def RunglerParams_level2     rb 1
def RunglerParams_decay1     rb 1
def RunglerParams_decay2     rb 1
def RunglerParams_pitch1_mod rb 1
def RunglerParams_pitch2_mod rb 1
def RunglerParams_level1_mod rb 1
def RunglerParams_level2_mod rb 1
def RunglerParams_decay1_mod rb 1
def RunglerParams_decay2_mod rb 1
def RunglerParams_pan        rb 1
def RunglerParams_div        rb 1
def RunglerParams_xor        rb 1
def RunglerParams_gate       rb 1
def RunglerParams_SIZEOF     rb 0

def MAX_PITCH     equ $3F
def MAX_SWEEP     equ $07
def MAX_SHAPE     equ $03
def MAX_LEVEL     equ $0F
def MAX_DECAY     equ $07
def MAX_MOD       equ $07
def MAX_PAN       equ $01
def MAX_DIV       equ $7F
def MAX_GATE      equ $01
def MAX_XOR       equ $01

Sound:
.MasksForDAC:
  db %0, %1, %11, %111, %1111, %1_1111, %11_1111, %111_1111

.Setup:
  ld a, 0
  put RunglerParams, pitch1
  put RunglerParams, pitch2

  put RunglerParams, sweep1
  put RunglerParams, sweep1_mod

  ld a, $02
  put RunglerParams, shape1
  put RunglerParams, shape2

  ld a, $07
  put RunglerParams, level1
  put RunglerParams, level2

  ld a, $00
  put RunglerParams, decay1
  put RunglerParams, decay2

  ld a, $00
  put RunglerParams, pitch1_mod
  put RunglerParams, pitch2_mod

  put RunglerParams, level1_mod
  put RunglerParams, level2_mod

  put RunglerParams, decay1_mod
  put RunglerParams, decay2_mod

  put RunglerParams, pan

  ld a, $30
  put RunglerParams, div

  ld a, 0
  put RunglerParams, xor
  put RunglerParams, gate

  ret

.Init:
  ; Enable sound
  ld a, $80
  ld [rNR52], a

  ; Set all RunglerParams to full volume
  ld a, $FF
  ld [rNR50], a

  ; Set sound output terminals
  ld a, $FF
  ld [rNR51], a

  ; Set wave duty.
	ld a, %00000000
	ld [rNR11], a
	ld [rNR21], a

	; Set the vol envelope.
	ld a, %0000_0_000
	ld [rNR12], a
	ld [rNR22], a

  ld a, %00_00_00_00
	ld [rNR14], a
	ld [rNR24], a

  ld a, $4
  ld [rTAC], a

  ld a, $F0
  ld [rTMA], a

  ret

MACRO mod ; target, channel, max value
  get RunglerParams, \1\2_mod
  ld hl, .MasksForDAC
  ld b, 0
  ld c, a
  add hl, bc
  ld a, [hl]
  ld b, a
  ld a, [wShiftRegister]
  and b
  ld b, a
  get RunglerParams, \1\2
  or a, b
  and a, \3
ENDM

MACRO update_level
  swap a
  ld [wLevel], a
ENDM

MACRO update_decay
  ld [wDecay], a
ENDM

MACRO update_shape
  get RunglerParams, shape\1
  rrca
  rrca
  ldh [rNR\11], a
ENDM

MACRO update_sweep
  and a
  jr z, :+
  ld b, a
  ld a, %0_001_1_000
  or a, b
:
  ldh [rNR10], a
ENDM

MACRO update_pitch
  sla a
  ld hl, Scale
  ld d, 0
  ld e, a
  add hl, de
  ld a, [hli]
  ld [wPitchLo], a
  ld a, [hl]
  ld [wPitchHi], a
ENDM

MACRO play_channel
  get RunglerParams, gate
  and a
  jr z, :+
  ld a, [wShiftRegister]
  bit 1, a
  jr nz, :++
:
  ld c, %10_00_00_00
  ld a, [wLevel]
  ld b, a
  ld a, [wDecay]
  or a, b
  ld [rNR\12], a
:
  ld a, [wPitchLo]
  ld [rNR\13], a
  ld a, [wPitchHi]
  or a, c
  ld [rNR\14], a
ENDM

MACRO update_pan
  get RunglerParams, pan
  and a
  ld a, %0001_0010
  jr nz, :+
  ld a, %0011_0011
:
  ld [rNR51], a
ENDM

.Update:

update_pan

.updateCh1:
  mod pitch, 1, MAX_PITCH
  update_pitch 1
  update_shape 1
  mod sweep, 1, MAX_SWEEP
  update_sweep 1
  mod level, 1, MAX_LEVEL
  update_level 1
  mod decay, 1, MAX_DECAY
  update_decay 1
  play_channel 1

.updateCh2:
  mod pitch, 2, MAX_PITCH
  update_pitch 2
  update_shape 2
  mod level, 2, MAX_LEVEL
  update_level 2
  mod decay, 2, MAX_DECAY
  update_decay 2
  play_channel 2

  ret

SECTION "Scale", ROM0
; Pure intervals
; made in Excel using formula 131072/(2048-period_value) = freq
Scale:
dw $002C
dw $02C8
dw $01BD
dw $0387
dw $010B
dw $024F
dw $032F
dw $03D3
dw $0416
dw $0564
dw $04DE
dw $05C3
dw $0485
dw $0527
dw $0597
dw $05EA
dw $060B
dw $06B2
dw $066F
dw $06E2
dw $0643
dw $0694
dw $06CC
dw $06F5
dw $0706
dw $0759
dw $0738
dw $0771
dw $0721
dw $074A
dw $0766
dw $077A
dw $0783
dw $07AD
dw $079C
dw $07B8
dw $0791
dw $07A5
dw $07B3
dw $07BD
dw $07C1
dw $07D6
dw $07CE
dw $07DC
dw $07C8
dw $07D2
dw $07D9
dw $07DF
dw $07E1
dw $07EB
dw $07E7
dw $07EE
dw $07E4
dw $07E9
dw $07ED
dw $07EF
dw $07F8
dw $07F8
dw $07F8
dw $07F8
dw $07F8
dw $07F8
dw $07F8
dw $07F8
.End

STATIC_ASSERT Scale.End - Scale == 64 * 2, "Scale length should be 2^n"