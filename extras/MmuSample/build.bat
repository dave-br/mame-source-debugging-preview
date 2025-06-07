lwasm --obj -3 -p cd -o./BlockA.obj BlockA.asm -l./BlockA.lst -i
lwasm --obj -3 -p cd -o./BlockB.obj BlockB.asm -l./BlockB.lst -i
lwasm --obj -3 -p cd -o./BlocksXU.obj BlocksXU.asm -l./BlocksXU.lst -i
lwasm --obj -3 -p cd -o./mmu.obj mmu.asm -l./mmu.lst -i
lwlink -b -oBLOCKS.bin -iBlocksFull.mdi --script=linkScript.txt --map=blocks.map BlockA.obj BlockB.obj BlocksXU.obj mmu.obj

rem change this as necessary to copy BLOCKS.bin to your virtual floppy
decb copy -2 -b -r BLOCKS.bin D:\coco\disks\202409.dsk,BLOCKS.BIN
