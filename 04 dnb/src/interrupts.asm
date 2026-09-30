SECTION "VBlank Interrupt", ROM0[INT_HANDLER_VBLANK]
VBlankInterupt:
  jp VBlankHandler

SECTION "Timer Interrupt", ROM0[INT_HANDLER_TIMER]
TimerInterrupt:
	jp TimerHandler

SECTION "VBlank Handler", ROM0
VBlankHandler:
  push_all

  get Grid, pageChanged

  cp a, 0
  jr z, .clearTileArea
  cp a, 1
  jr z, .clearTileArea
  cp a, 2
  jr z, .drawLabels
  cp a, 3
  jr z, .drawParams
  cp a, 4
  jr z, .drawPageNames
  jr :+

.clearTileArea:
  call Grid.ClearTileArea
  jr .changePageAndReturn

.drawLabels:
  call Grid.ChangePage
  call Grid.DrawLabels
  jr .changePageAndReturn

.drawParams:
  call Grid.DrawParams
  jr .changePageAndReturn

.drawPageNames:
  call Grid.DrawPageNames
  jr .changePageAndReturn

:
  call ShiftRegister.Draw
  call Keys.Update
  call Keys.Process
  ifzero Grid, needsRedraw, :+
  grid_draw_selected
:
  xor a
  put Grid, needsRedraw
  pop_all
  reti

.changePageAndReturn:
  get Grid, pageChanged
  inc a
  put Grid, pageChanged
  pop_all
  reti


SECTION "Timer Handler", ROM0
TimerHandler:
  push_all

  ld hl, hRateCounter + 1
  dec [hl]
  jr nz, .playWave
  ld [hl], 8
  dec hl
  dec [hl]
  jr nz, .playWave
  mod rate, MAX_RATE
  inc a
  ld [hl], a

  call ShiftRegister.Shift
  ld hl, hBinCounter
  inc [hl]

.updatePulse:
  get MainParams, pulse_gate
  ld hl, hBinCounter
  and a, [hl]
  jr z, .updateWave

  call Sound.UpdatePulse

.updateWave:
  get MainParams, wave_gate
  ld hl, hBinCounter
  and a, [hl]
  jr z, .playWave
  call WaveTable.Trigger

.playWave:
  ldh a, [hWaveTableTriggered]
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