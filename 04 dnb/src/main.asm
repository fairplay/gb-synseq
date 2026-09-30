INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macros.inc"
INCLUDE "tables.inc"
INCLUDE "memory.asm"
INCLUDE "delay-line.asm"
INCLUDE "main-params.asm"
INCLUDE "sound.asm"
INCLUDE "synth-karplus-strong.asm"
INCLUDE "wavetable.asm"
INCLUDE "keys.asm"
INCLUDE "grid-template.asm"
INCLUDE "grid.asm"
INCLUDE "shift-register.asm"
INCLUDE "interrupts.asm"

SECTION "Header", ROM0[$100]
  nop
	jp EntryPoint
  ds $150 - @, 0

SECTION "Main", ROM0[$150]
EntryPoint:
  di                    ; Disable interrupts during setup
  ld sp, $E000          ; Set stack pointer to end of WRAM
  ; Shut down audio circuitry
  xor a
  ldh [rNR52], a

  ; Do not turn the LCD off outside of VBlank
  .WaitVblank
    ldh a, [rLY]
    cp LY_VBLANK
    jr c, .WaitVblank

  lcd_off

  ld de, Font
  ld hl, STARTOF(VRAM) + $110 * TILE_SIZE
  ld bc, Font.End - Font
  call CopyWithInvert

  call Keys.Init
  call ShiftRegister.Init
  call MainParams.Setup
  call WaveTable.Init
  call Grid.Init
  call Grid.Clear
  call Grid.ChangePage
  call Grid.DrawLabels
  call Grid.DrawParams
  call Grid.DrawPageNames
  call Sound.Init

  lcd_on

  ; During the first (blank) frame, initialize display registers
  ld a, %11_01_11_01
  ld [rBGP], a

  ld a, IE_VBLANK | IE_TIMER
  ld [rIE], a
  ei

Main:
  halt
  nop
  jr Main

SECTION "Font", ROM0
Font:
  incbin "font_8x8.chr"
.End