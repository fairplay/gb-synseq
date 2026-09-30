SECTION "VBlank Interrupt", ROM0[INT_HANDLER_VBLANK]
VBlankInterupt:
  jp VBlankHandler

SECTION "Timer Interrupt", ROM0[INT_HANDLER_TIMER]
TimerInterrupt:
	jp TimerHandler

SECTION "VBlank Handler", ROM0

VBlankHandler:
  push_all

  call Keys.Update
  call Keys.Process

  call ShiftRegister.Draw

  get Grid, needsRedraw
  and a
  jr z, .exit
  call Grid.Redraw
  xor a
  put Grid, needsRedraw

.exit:
  pop_all
  reti

SECTION "Timer Handler", ROM0
TimerHandler:
  push_all
  ld a, [wPlay]
  and a
  jr z, :+

  ld a, [rPCM12]
  call ShiftRegister.Shift
  call Sound.Update
:
  pop_all
  reti
