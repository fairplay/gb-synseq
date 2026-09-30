rsreset
def SeqParams_noise_freq       rb 1
def SeqParams_noise_freq_mod   rb 1
def SeqParams_noise_level      rb 1
def SeqParams_noise_level_mod  rb 1
def SeqParams_noise_decay      rb 1
def SeqParams_noise_decay_mod  rb 1
def SeqParams_noise_lfsr       rb 1
def SeqParams_rate             rb 1
def SeqParams_wave_level       rb 1
def SeqParams_wave_level_mod   rb 1
def SeqParams_wave_freq        rb 1
def SeqParams_wave_freq_mod    rb 1
def SeqParams_prob             rb 1
def SeqParams_length           rb 1
def SeqParams_noise_gate       rb 1
def SeqParams_wave_gate        rb 1
def SeqParams_SIZEOF           rb 0

def MAX_NOISE_FREQ   equ $7F
def MAX_NOISE_LEVEL  equ $0F
def MAX_NOISE_DECAY  equ $07
def MAX_MOD          equ $07
def MAX_NOISE_LFSR   equ $01
def MAX_PROB         equ $07
def MAX_WAVE_LEVEL   equ $03
def MAX_WAVE_FREQ    equ $FF
def MAX_RATE         equ $FF
def MAX_LENGTH       equ $07
def MAX_GATE_THRESH  equ $0F

MACRO knob ; target
  get SeqParams, \1
  ld b, a
ENDM

MACRO mod ; target, max value
  get SeqParams, \1_mod
  ld c, a
  ldh a, [wShiftRegister]
  and a, c
  add a, b
  and a, \2
ENDM

MACRO update_noise_level
  swap a
  ldh [wNoiseLevel], a
ENDM

MACRO update_noise_decay
  ldh [wNoiseDecay], a
ENDM

MACRO update_noise_freq
  ld b, a
  and 7
  ldh [wNoiseClockDiv], a

  ld a, b
  sla a
  swap a
  and $0F
  ldh [wNoiseClockShift], a
ENDM

MACRO play_noise_channel
  ldh a, [wNoiseLevel]
  ld b, a
  ldh a, [wNoiseDecay]
  or a, b
  ldh [rNR42], a

  ldh a, [wNoiseClockShift]
  swap a
  ld b, a
  ldh a, [wNoiseClockDiv]
  or a, b
  ld b, a
  get SeqParams, noise_lfsr
  swap a
  srl a
  or a, b
  ldh [rNR43], a
  ld c, %10_00_00_00
  or a, c
  ldh [rNR44], a
ENDM

MACRO update_wave_freq
  ; sla a
  ; ld hl, Scale
  ; ld d, 0
  ; ld e, a
  ; add hl, de
  ; ld a, [hli]
  ldh [wWaveFreqLo], a
  ; ld a, [hl]
  ; ldh [wWaveFreqHi], a
ENDM

MACRO update_wave_level
  ld b, a
  sla a
  xor b
  swap a
  sla a
  ldh [wWaveLevel], a
ENDM

MACRO play_wave_channel
  ldh a, [wWaveLevel]
  ldh [rNR32], a

  ldh a, [wWaveFreqLo]
  ldh [rNR33], a

  ; ldh a, [wWaveFreqHi]
  ; ld b, $87
  ; or a, b
  ld a, $87
  ldh [rNR34], a
ENDM

SECTION "Sound Impl", ROM0
Sound:

.Setup:
  ld a, $00
  put SeqParams, noise_freq

  ld a, $07
  put SeqParams, noise_level

  ld a, $01
  put SeqParams, noise_decay

  ld a, $00
  put SeqParams, noise_freq_mod
  put SeqParams, noise_level_mod
  put SeqParams, wave_freq_mod
  put SeqParams, wave_level_mod
  put SeqParams, noise_decay_mod
  put SeqParams, prob

  ld a, $01
  put SeqParams, noise_gate
  ld a, $01
  put SeqParams, wave_gate

  ld a, $01
  put SeqParams, noise_lfsr

  ld a, $00
  put SeqParams, wave_freq

  ld a, $03
  put SeqParams, wave_level

  ld a, $40
  put SeqParams, rate

  ld a, $07
  put SeqParams, length

ret

.Init:
  xor a
  ldh [wNoiseClockShift], a
  ldh [wNoiseClockDiv], a
  ldh [wNoiseLevel], a
  ldh [wNoiseDecay], a

  ; Enable sound
  ld a, $80
  ldh [rNR52], a

  ; Set all SeqParams to full volume
  ld a, $FF
  ldh [rNR50], a

  ; Set sound output terminals
  ld a, $FF
  ldh [rNR51], a

  ; Set wave duty.
	ld a, %00000000
	ldh [rNR11], a
	ldh [rNR21], a

	; Set the vol envelope.
	ld a, 0
	ldh [rNR12], a
	ldh [rNR22], a

  ld a, 0
	ldh [rNR14], a
	ldh [rNR24], a

  ; Wave channel
  ld a, $80
  ldh [rNR30], a
  ld a, 0
  ldh [rNR31], a
  ldh [rNR32], a
  ld a, %1_0_000_111
  ldh [rNR34], a

  ld a, $6
  ld [rTAC], a

  ld a, $F8
  ld [rTMA], a
  ld [rTIMA], a

ret

.UpdateNoise:
  knob noise_freq
  mod noise_freq, MAX_NOISE_FREQ
  update_noise_freq

  knob noise_level
  mod noise_level, MAX_NOISE_LEVEL
  update_noise_level

  knob noise_decay
  mod noise_decay, MAX_NOISE_DECAY
  update_noise_decay

  play_noise_channel
ret

.UpdateWave:
  knob wave_freq
  mod wave_freq, MAX_WAVE_FREQ
  update_wave_freq

  knob wave_level
  mod wave_level, MAX_WAVE_LEVEL
  update_wave_level

  play_wave_channel
ret

SECTION "Scale", ROM0
; Pure intervals
; 1 1.5 1.25 1.75 1.125 1.375 1.625 1.875
Scale:
FOR oct, 0, 8
  DEF pitch = MUL(65.41, 1<<oct)
  dw 2048-131072/MUL(pitch, 1.0)
  dw 2048-131072/MUL(pitch, 1.5)
  dw 2048-131072/MUL(pitch, 1.25)
  dw 2048-131072/MUL(pitch, 1.75)
  dw 2048-131072/MUL(pitch, 1.125)
  dw 2048-131072/MUL(pitch, 1.375)
  dw 2048-131072/MUL(pitch, 1.625)
  dw 2048-131072/MUL(pitch, 1.875)
ENDR
.End

STATIC_ASSERT Scale.End - Scale == 64 * 2, "Scale length should be 128"

SECTION "Sound Vars", HRAM
wNoiseClockShift: db
wNoiseClockDiv: db
wNoiseLevel: db
wNoiseDecay: db
wWaveLevel: db
wWaveFreqLo: db
wWaveFreqHi: db