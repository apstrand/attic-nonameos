os:	init.asm ints.asm job.asm video.asm kernel.asm memory.asm os.inc
	nasm kernel.asm -o os

boot:	boot.asm os.inc
	nasm boot.asm

task1:	task1.asm os.inc
	nasm task1.asm

task2:	task2.asm os.inc
	nasm task2.asm

w:	boot os task1 task2
	su -c 'cat boot os task1 task2> /dev/fd0'

d:	os
	ndisasm -u os>os.lst
