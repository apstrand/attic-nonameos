init:	init.asm ints.asm job.asm video.asm
	nasm init.asm

boot:	boot.asm
	nasm boot.asm

tasks:	tasks.asm
	nasm tasks.asm

w:	init boot tasks
	su -c 'cat boot init tasks> /dev/fd0'
