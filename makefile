os:	init.asm ints.asm proc.asm kbd.asm video.asm kernel.asm memory.asm abs.asm
	nasm kernel.asm -o os

boot:	boot.asm
	nasm boot.asm

task1:	task1.asm
	nasm task1.asm

task2:	task2.asm
	nasm task2.asm

w:	boot os task1 task2
	su -c 'cat boot os task1 task2> /dev/fd0'

d:	os
	ndisasm -u os>os.lst
