INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macros.inc"
INCLUDE "tables.inc"
INCLUDE "memory.asm"
INCLUDE "delay-line.asm"
INCLUDE "synth-kick-henke.asm"
; INCLUDE "synth-drum-risset.asm"
INCLUDE "synth-karplus-strong.asm"
INCLUDE "wavetable.asm"
INCLUDE "sound.asm"
INCLUDE "keys.asm"
INCLUDE "grid.asm"
INCLUDE "grid-seq.asm"
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

  ; Turn the LCD off
  ld a, LCDC_OFF
  ldh [rLCDC], a

  ld de, Font
  ld hl, STARTOF(VRAM) + $110 * TILE_SIZE
  ld bc, Font.End - Font
  call CopyWithInvert

  call Keys.Init
  call ShiftRegister.Init
  call Sound.Setup
  call WaveTable.Init
  call GridSeq.Init
  call GridSeq.Draw
  call Sound.Init

  ; Turn the LCD on
  ld a, LCDC_ON | LCDC_BG_ON
  ld [rLCDC], a

  ; During the first (blank) frame, initialize display registers
  ld a, %11_01_11_01
  ld [rBGP], a

  ld a, IE_VBLANK | IE_TIMER
  ld [rIE], a
  ei

Main:
  halt
  nop
  jp Main

SECTION "Font", ROM0
Font:
  incbin "font_8x8.chr"
.End