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
  ifzero GridSeq, needsRedraw
  jr z, :+
  grid_draw_selected GridSeq ; TODO: looks ugly
:
  xor a
  put GridSeq, needsRedraw
  pop_all
reti

SECTION "Timer Handler", ROM0
TimerHandler:
  push_all
  ; jr .playWave

  ld hl, wRateCounter + 1
  dec [hl]
  jr nz, .playWave
  ld [hl], 16
  dec hl
  dec [hl]
  jr nz, .playWave
  get SeqParams, rate
  inc a
  ld [hl], a

  call ShiftRegister.Shift
  ld hl, wBinCounter
  inc [hl]

.updateNoise:
  get SeqParams, noise_gate
  ld hl, wBinCounter
  and a, [hl]
  jr z, .updateWave

  call Sound.UpdateNoise

.updateWave:
  get SeqParams, wave_gate
  ld hl, wBinCounter
  and a, [hl]
  jr z, .playWave
  call WaveTable.Trigger

.playWave:
  ldh a, [wWaveTableTriggered]
  or a
  jr z, :+

  call WaveTable.NextSample
  or a
  jr nz, :+

  dac3_off
  dac3_on
  call WaveTable.Copy
  call Sound.UpdateWave
:
  pop_all
reti