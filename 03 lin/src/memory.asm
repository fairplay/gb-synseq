SECTION "Memory Management", ROM0

CopyWithInvert:
  ; de -- src
  ; hl -- dest
  ; bc -- size
  ld a, [de]
  ld [hl], a

  push de
  push hl
  ld d, $F8
  ld e, $00
  add hl, de

  xor a, $FF
  ld [hl], a
  pop hl
  pop de

  inc hl
  inc de
  dec bc
  ld a, b
  or a, c
  jr nz, CopyWithInvert
  ret

CopyTileMap:
  ; de -- src
  ; hl -- dest
  ; b -- line count

  ld c, 20
  .CopyTileLine:
    ld a, [de]
    sub a, $10 ; because of the shifted font memory
    ld [hli], a
    inc de
    dec c
    jr nz, .CopyTileLine

  push bc
  ld bc, 12
  add hl, bc
  pop bc
  dec b
  jr nz, CopyTileMap
  ret
