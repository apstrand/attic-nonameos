os:	init.asm ints.asm proc.asm kbd.asm video.asm kernel.asm memory.asm abs.asm
	nasm kernel.asm -o os

boot:	boot.asm
	nasm boot.asm

task1:	task1.asm
	nasm task1.asm

task2:	task2.asm
	nasm task2.asm

all: boot os task1 task2

image: all
	cat boot os task1 task2 > fd0.img

w:	all
	su -c 'cat boot os task1 task2> /dev/fd0'

d:	os
	ndisasm -u os>os.lst
