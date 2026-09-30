INCLUDE "hardware.inc"
INCLUDE "macros.inc"
INCLUDE "interrupts.asm"
INCLUDE "memory.asm"
INCLUDE "sound.asm"
INCLUDE "keys.asm"
INCLUDE "grid.asm"
INCLUDE "shift_register.asm"
INCLUDE "vars.asm"

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
  ldh [rAUDENA], a

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

  call Init
  call Sound.Setup
  call Grid.Init
  call Grid.Draw
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

Init:
  ld a, 1
  ld [wPlay], a

  xor a
  ld [wCurKeys], a
  ld [wNewKeys], a
  ld [wCounter], a
  ld [wShiftRegister], a
  ld [wLevel], a
  ld [wAccum], a
  ld [wPhase1], a
  ld [wPhase2], a
  ld [wPitchHi], a
  ld [wPitchLo], a
  ret

SECTION "Font", ROM0
Font:
  incbin "font_8x8.chr"
.End