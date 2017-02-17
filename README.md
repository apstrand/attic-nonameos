## i386 "OS kernel"

This code is part of a project of mine to revive old code,
just for fun. It was done as a high school project in 1997.

It basically just sets up protected mode and a scheduler,
and then runs user mode processes. The only devices that are
supported are screen and keyboard, "programs" have to be
preloaded by the bootloader to memory.

Should build with nasm.

