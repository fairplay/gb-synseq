SECTION "Keys", ROM0
Keys:
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

  ; Combine with previous wCurKeys to make wNewKeys
  ld a, [wCurKeys]
  xor a, b ; A = keys that changed state
  and a, b ; A = keys that changed to pressed
  ld [wNewKeys], a
  ld a, b
  ld [wCurKeys], a

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
  ld a, [wCurKeys]
  and a, PAD_A
  jr z, .AReleased
  ld a, 1
  put Grid, editing
  jr :+
.AReleased
  xor a
  put Grid, editing

:
  on_key_press START, handle_start_key, -1
  on_key_press LEFT, handle_arrow_key, Left
  on_key_press RIGHT, handle_arrow_key, Right
  on_key_press UP, handle_arrow_key, Up
  on_key_press DOWN, handle_arrow_key, Down

  ret