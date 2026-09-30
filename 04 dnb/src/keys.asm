SECTION "Keys Impl", ROM0
Keys:
.Init:
  xor a
  ldh [hCurKeys], a
  ldh [hNewKeys], a
  ldh [hKeysTarget], a
ret

.Update:
  ; Poll half the controller
  ld a, JOYP_GET_BUTTONS
  call .onenibble
  ld b, a ; B7-4 = 1; B3-0 = unpressed buttons

  ; Poll the other half
  ld a, JOYP_GET_CTRL_PAD
  call .onenibble
  swap a ; A7-4 = unpressed directions; A3-0 = 1
  xor a, b ; A = pressed buttons + directions
  ld b, a ; B = pressed buttons + directions

  ; And release the controller
  ld a, JOYP_GET_NONE
  ldh [rP1], a

  ; Combine with previous hCurKeys to make hNewKeys
  ldh a, [hCurKeys]
  xor a, b ; A = keys that changed state
  and a, b ; A = keys that changed to pressed
  ldh [hNewKeys], a
  ld a, b
  ldh [hCurKeys], a

ret
.onenibble
  ldh [rP1], a ; switch the key matrix
  call .knownret ; burn 10 cycles calling a known ret
  ldh a, [rP1] ; ignore value while waiting for the key matrix to settle
  ldh a, [rP1]
  ldh a, [rP1] ; this read counts
  or a, $F0 ; A7-4 = 1; A3-0 = unpressed keys
.knownret
ret

.Process:
  ldh a, [hKeysTarget]
  or a
  call z, Grid.KeysProcess
ret

SECTION "Keys Vars", HRAM
hCurKeys: db
hNewKeys: db
hKeysTarget: db