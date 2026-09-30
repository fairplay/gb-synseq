SECTION "VBlank Interrupt", ROM0[INT_HANDLER_VBLANK]
VBlankInterupt:
  jp VBlankHandler

SECTION "Timer Interrupt", ROM0[INT_HANDLER_TIMER]
TimerInterrupt:
	jp TimerHandler

SECTION "VBlank Handler", ROM0
VBlankHandler:
  push_all
  call ShiftRegister.Draw
  call Keys.Update
  call Keys.Process
  get Grid, needsRedraw
  and a
  jr z, :+
  call Grid.Redraw
:
  xor a
  put Grid, needsRedraw
  pop_all
  reti

SECTION "Timer Handler", ROM0
TimerHandler:
  push_all
  ld a, [wPlay]
  and a
  jr z, :++

  ld a, [wSoundDivCounter]
  and a
  jr nz, :+
  call Sound.Update
  ld a, [rPCM12]
  call ShiftRegister.Shift
:
  ld hl, wSoundDivCounter
  inc [hl]
  get RunglerParams, div
  cp a, [hl]
  jr nc, :+
  ld [hl], 0
:
  pop_all
  reti
