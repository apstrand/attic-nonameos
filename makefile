init:	init.asm ints.asm job.asm video.asm
	nasm init.asm

boot:	boot.asm
	nasm boot.asm

w:	init boot
	su -c 'cat boot init > /dev/fd0'
