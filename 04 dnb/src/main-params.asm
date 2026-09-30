rsreset
; page 1: Shift Register
def MainParams_rate             rb 1
def MainParams_rate_mod         rb 1
def MainParams_prob             rb 1
def MainParams_prob_mod         rb 1
def MainParams_length           rb 1
def MainParams_length_mod       rb 1
def MainParams_pulse_gate       rb 1
def MainParams_wave_gate        rb 1

; page 2: Pulse channel
def MainParams_pulse_freq       rb 1
def MainParams_pulse_freq_mod   rb 1
def MainParams_pulse_level      rb 1
def MainParams_pulse_level_mod  rb 1
def MainParams_pulse_decay      rb 1
def MainParams_pulse_decay_mod  rb 1
def MainParams_pulse_sweep      rb 1
def MainParams_pulse_sweep_mod  rb 1
def MainParams_pulse_shape      rb 1
def MainParams_pulse_shape_mod  rb 1

; page 3: "Karplus-Strong"
def MainParams_wave_freq        rb 1
def MainParams_wave_freq_mod    rb 1
def MainParams_wave_level       rb 1
def MainParams_wave_level_mod   rb 1
def MainParams_delay_a          rb 1
def MainParams_delay_a_mod      rb 1
def MainParams_delay_b          rb 1
def MainParams_delay_b_mod      rb 1

def MainParams_SIZEOF           rb 0

def MAX_PULSE_FREQ   equ $3F
def MAX_PULSE_LEVEL  equ $0F
def MAX_PULSE_DECAY  equ $07
def MAX_PULSE_SWEEP  equ $07
def MAX_MOD          equ $07
def MAX_PULSE_SHAPE  equ $03
def MAX_PROB         equ $07
def MAX_WAVE_LEVEL   equ $03
def MAX_WAVE_FREQ    equ $FF
def MAX_RATE         equ $FF
def MAX_LENGTH       equ $07
def MAX_GATE_MASK    equ $0F
def MAX_KS_DELAY     equ $7F

MACRO mod ; target, max value
  push bc
  ldh a, [hShiftRegister]
  ld b, a
  get MainParams, \1_mod
  and a, b
  ld b, a
  get MainParams, \1
  add a, b
  and a, \2
  pop bc
ENDM

SECTION "Main Params", ROM0
MainParams:
.Setup:
  xor a
  put MainParams, pulse_freq
  put MainParams, pulse_sweep
  put MainParams, pulse_shape
  put MainParams, wave_freq
  put MainParams, pulse_freq_mod
  put MainParams, pulse_decay_mod
  put MainParams, pulse_level_mod
  put MainParams, pulse_sweep_mod
  put MainParams, pulse_shape_mod
  put MainParams, wave_freq_mod
  put MainParams, wave_level_mod
  put MainParams, rate_mod
  put MainParams, prob
  put MainParams, prob_mod
  put MainParams, length_mod
  put MainParams, pulse_gate
  put MainParams, delay_a_mod
  put MainParams, delay_b_mod

  ld a, $20
  put MainParams, delay_a
  ld a, $21
  put MainParams, delay_b

  ld a, $07
  put MainParams, pulse_level

  ld a, $01
  put MainParams, pulse_decay
  put MainParams, wave_gate

  ld a, $03
  put MainParams, wave_level

  ld a, $40
  put MainParams, rate

  ld a, $07
  put MainParams, length

  ; xor a
  ; put MainParams, fm_mod_freq
  ; put MainParams, fm_car_freq
  ; put MainParams, fm_decay
  ; put MainParams, fm_amount
  ; put MainParams, fm_feedback

  ; put MainParams, fm_mod_freq_mod
  ; put MainParams, fm_car_freq_mod
  ; put MainParams, fm_decay_mod
  ; put MainParams, fm_amount_mod
  ; put MainParams, fm_feedback_mod

ret
