MACRO get
  ld a, [w\1 + \1_\2]
ENDM

MACRO ifzero
  ld a, [w\1 + \1_\2]
  or a
ENDM

MACRO put
  ld [w\1 + \1_\2], a
ENDM

MACRO push_all
  push af
  push bc
  push de
  push hl
ENDM

MACRO pop_all
  pop hl
  pop de
  pop bc
  pop af
ENDM

MACRO process_keys
  ldh a, [wKeysTarget]
  cp a, 0
  jr nz, :+
  call GridSeq.KeysProcess
  jr .exitProcessKeys
:
.exitProcessKeys:
ENDM

MACRO on_key_press ; target type, target, key
  REDEF key EQUS STRUPR("\3")
  ldh a, [wNewKeys]
  and a, PAD_{key}
  jr z, .\3NextKey
  \1_handle_key \2, \3

.\3NextKey:
ENDM

MACRO dac3_off
  xor a
  ldh [rNR30], a
ENDM

MACRO dac3_on
  ld a, $80
  ldh [rNR30], a
ENDM