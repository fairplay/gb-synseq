SECTION "Memory Management", ROM0

Copy:
  ; de -- src
  ; hl -- dest
  ; bc -- size
  ld a, [de]
  ld [hli], a
  inc de
  dec bc
  ld a, b
  or a, c
  jr nz, Copy
  ret

CopyTileMap:
  ; de -- src
  ; hl -- dest
  ; b -- line count

  ld c, 20
  .CopyTileLine:
    ld a, [de]
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

CopyInvert:
  ; de -- src
  ; hl -- dest
  ; bc -- size
  ld a, [de]
  xor a, $FF
  ld [hli], a
  inc de
  dec bc
  ld a, b
  or a, c
  jr nz, CopyInvert
  ret
