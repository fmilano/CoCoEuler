#/bin/bash
rm -f *.DSK
decb dskini EULER.DSK
decb copy -b Euler1.bin -r -2 EULER.DSK,EULER1.BIN
mame coco2 -window -autoboot_delay 2 -autoboot_script execute.lua -flop1 EULER.DSK