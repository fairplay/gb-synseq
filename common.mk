SOURCES = src/main.asm

RGBDS=../../rgbds
AS = $(RGBDS)/rgbasm.exe
LD = $(RGBDS)/rgblink.exe
FIX = $(RGBDS)/rgbfix.exe
EMU = $(RGBDS)/bgb64.exe

ASFLAGS = -I./inc -I./res -I./src
LDFLAGS = -m "$(ROM_NAME).map" -n "$(ROM_NAME).sym"
FIXFLAGS =  -v -p 0 -t "$(ROM_NAME)" "$(ROM_NAME).gb"

all: $(ROM_NAME).gb

$(ROM_NAME).gb: $(ROM_NAME).o
	$(LD) $(LDFLAGS) -o $@ $<
	$(FIX) $(FIXFLAGS) $@

$(ROM_NAME).o: $(SOURCES)
	$(AS) $(ASFLAGS) -o $@ $<

clean:
	rm -f *.o *.gb *.map *.sym *.sn1

run: $(ROM_NAME).gb
	$(EMU) "$(ROM_NAME).gb"

.PHONY: all clean run
