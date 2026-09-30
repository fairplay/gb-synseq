MACRO update_pulse_shape
  mod pulse_shape, MAX_PULSE_SHAPE
  rrca
  rrca
  ldh [rNR11], a
ENDM

MACRO update_pulse_sweep
  and a
  jr z, :+
  ld b, a
  ld a, %0_001_1_000
  or a, b
:
  ldh [rNR10], a
ENDM

MACRO update_pulse_freq
  sla a
  ld hl, Scale
  ld d, 0
  ld e, a
  add hl, de
  ld a, [hli]
  ldh [hPulseFreqLo], a
  ld a, [hl]
  ldh [hPulseFreqHi], a
ENDM

MACRO update_pulse_level
  swap a
  ldh [hPulseLevel], a
ENDM

MACRO update_pulse_decay
  ldh [hPulseDecay], a
ENDM

MACRO play_pulse_channel
  ldh a, [hPulseLevel]
  ld b, a
  ldh a, [hPulseDecay]
  or a, b
  ldh [rNR12], a

  ldh a, [hPulseFreqLo]
  ldh [rNR13], a
  ldh a, [hPulseFreqHi]
  ld c, %10_00_00_00
  or a, c
  ldh [rNR14], a
ENDM

MACRO update_wave_freq
  ldh [rNR33], a
ENDM

MACRO update_wave_level
  ld b, a
  sla a
  xor b
  swap a
  sla a
  ldh [rNR32], a
ENDM

MACRO play_wave_channel
  ld a, $86
  ldh [rNR34], a
ENDM

SECTION "Sound Impl", ROM0
Sound:
.Init:
  xor a
  ldh [hPulseFreqHi], a
  ldh [hPulseFreqLo], a

  ; Enable sound
  ld a, $80
  ldh [rNR52], a

  ; Set all channels to full volume
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

  ld a, $E0
  ld [rTMA], a
  ld [rTIMA], a

ret

.UpdatePulse:
  mod pulse_freq, MAX_PULSE_FREQ
  update_pulse_freq
  update_pulse_shape

  mod pulse_sweep, MAX_PULSE_SWEEP
  update_pulse_sweep

  mod pulse_level, MAX_PULSE_LEVEL
  update_pulse_level

  mod pulse_decay, MAX_PULSE_DECAY
  update_pulse_decay

  play_pulse_channel
ret

.UpdateWave:
  mod wave_freq, MAX_WAVE_FREQ
  update_wave_freq

  mod wave_level, MAX_WAVE_LEVEL
  update_wave_level

  play_wave_channel
ret

SECTION "Sound Vars", HRAM
hPulseFreqLo: db
hPulseFreqHi: db
hPulseLevel:  db
hPulseDecay:  db
hPulseSweep:  db