SECTION "Sound", ROM0

rsreset
def GblinParams_pitch1     rb 1
def GblinParams_pitch2     rb 1
def GblinParams_pitch1_mod rb 1
def GblinParams_pitch2_mod rb 1
def GblinParams_fm1        rb 1
def GblinParams_fm2        rb 1
def GblinParams_shape1     rb 1
def GblinParams_shape2     rb 1
def GblinParams_level1     rb 1
def GblinParams_level2     rb 1
def GblinParams_rate       rb 1
def GblinParams_thresh     rb 1
def GblinParams_SIZEOF     rb 0

def MAX_PITCH     equ $7F
def MAX_SHAPE     equ $03
def MAX_LEVEL     equ $0F
def MAX_MOD       equ $07
def MAX_FM        equ $07
def MAX_RATE      equ $7F
def MAX_THRESH    equ $0F

Sound:
.Setup:
  ld a, 0
  put GblinParams, pitch1
  put GblinParams, pitch2
  put GblinParams, fm1
  put GblinParams, fm2
  put GblinParams, pitch1_mod
  put GblinParams, pitch2_mod

  ld a, $02
  put GblinParams, shape1
  put GblinParams, shape2
  put GblinParams, level1
  put GblinParams, level2

  ld a, $07
  put GblinParams, thresh
  ld a, $20
  put GblinParams, rate

  ret

.Init:
  ; Enable sound
  ld a, $80
  ld [rNR52], a

  ; Set all GblinParams to full volume
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

  ld a, %1_0_000_000
	ld [rNR14], a
	ld [rNR24], a

  ld a, 6
  ld [rTAC], a

  ld a, $FF
  ld [rTMA], a

  ret

MACRO mod ; target, channel, max value
  get GblinParams, \1\2_mod
  ld b, a
  ld a, [wShiftRegister]
  and a, 7
  ld c, a

  mul_b_c

  ld b, a
  get GblinParams, \1\2
  add a, b
  cp a, \3
  jr c, :+
  ld a, \3
:
ENDM

MACRO update_level
  get GblinParams, level\1
  swap a
  ld [wLevel], a
ENDM

MACRO update_shape
  get GblinParams, shape\1
  rrca
  rrca
  ldh [rNR\11], a
ENDM

MACRO fm ; car channel, mod channel
  get GblinParams, fm\1
  ld b, a
  ld a, [wPhase\2]
  sla a
  sla a
  ld c, a

  mul_b_c

  ld d, 0
  jr nc, :+
  ld d, 1
:
  ld e, a
  ld a, [wPitchHi]
  ld h, a
  ld a, [wPitchLo]
  ld l, a
  add hl, de

  ld a, l
  ld [wPitchLo], a
  ld a, h
  cp a, 7
  jr c, :+
  ld a, 7
:
  ld [wPitchHi], a
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
  ld a, [wLevel]
  ld b, a
  ld a, [rNR\12]
  cp a, b
  jr z, :+
  ld c, %1_0_000_000
  ld a, b
  ld [rNR\12], a
  jr :++
:
  ld c, %0_0_000_000
:
  ld a, [wPitchLo]
  ld [rNR\13], a
  ld a, [wPitchHi]
  or a, c
  ld [rNR\14], a
ENDM

MACRO inc_phase ; channel
  ld a, [rPCM12]
  REPT \1 - 1
  swap a
  ENDR
  and $0F
  jr z, :+
  ld a, [wPhase\1]
  inc a
  and $0F
  ld [wPhase\1], a
:
ENDM

.Update:
  inc_phase 1
  inc_phase 2

.updateCh1:
  mod pitch, 1, MAX_PITCH
  update_pitch 1
  fm 1, 2

  update_shape 1
  update_level 1

  play_channel 1

.updateCh2:
  mod pitch, 2, MAX_PITCH
  update_pitch 2
  fm 2, 1

  update_shape 2
  update_level 2

  play_channel 2

  ret

SECTION "Scale", ROM0
; Chromatic
; made in Excel using formula 2048-131072/freq = period_value
Scale:
dw $002C
dw $009D
dw $0107
dw $016B
dw $01CA
dw $0223
dw $0277
dw $02C7
dw $0312
dw $0359
dw $039B
dw $03DA
dw $0416
dw $044E
dw $0483
dw $04B5
dw $04E5
dw $0511
dw $053C
dw $0563
dw $0589
dw $05AC
dw $05CE
dw $05ED
dw $060B
dw $0627
dw $0642
dw $065B
dw $0672
dw $0689
dw $069E
dw $06B2
dw $06C4
dw $06D6
dw $06E7
dw $06F7
dw $0706
dw $0714
dw $0721
dw $072D
dw $0739
dw $0744
dw $074F
dw $0759
dw $0762
dw $076B
dw $0773
dw $077B
dw $0783
dw $078A
dw $0790
dw $0797
dw $079D
dw $07A2
dw $07A7
dw $07AC
dw $07B1
dw $07B6
dw $07BA
dw $07BE
dw $07C1
dw $07C5
dw $07C8
dw $07CB
dw $07CE
dw $07D1
dw $07D4
dw $07D6
dw $07D9
dw $07DB
dw $07DD
dw $07DF
dw $07E1
dw $07E2
dw $07E4
dw $07E6
dw $07E7
dw $07E9
dw $07EA
dw $07EB
dw $07EC
dw $07ED
dw $07EE
dw $07EF
dw $07F0
dw $07F1
dw $07F2
dw $07F3
dw $07F4
dw $07F4
dw $07F5
dw $07F6
dw $07F6
dw $07F7
dw $07F7
dw $07F8
dw $07F8
dw $07F9
dw $07F9
dw $07F9
dw $07FA
dw $07FA
dw $07FA
dw $07FB
dw $07FB
dw $07FB
dw $07FC
dw $07FC
dw $07FC
dw $07FC
dw $07FD
dw $07FD
dw $07FD
dw $07FD
dw $07FD
dw $07FD
dw $07FE
dw $07FE
dw $07FE
dw $07FE
dw $07FE
dw $07FE
dw $07FE
dw $07FE
dw $07FE
dw $07FF
dw $07FF
dw $07FF
.End

STATIC_ASSERT Scale.End - Scale == 128 * 2, "Scale length should be 2^n"