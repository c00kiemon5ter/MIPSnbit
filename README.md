MIPS nbit
=========

This is a pipelined mips architecture cpu.
It uses reduced commands, {lw, sw, add, sub, beq, j}
Using a 'word_size' variable the code will try to work 
for either 16(word_size=2) or 32(word_size=4) bit.

 -- Fri 10/7/09

--------------------------------------------------------

OK, I figured out why this cannot happen,
You cannot have 32 and 16 (or 64etc) bits 
switch with a single variable, however you 
can generalize lots of components to handle 
different sizes of input

So after building all the components using 
generics and methods that don't limit your 
program,you can build a set of 16 and 32 bit 
specific components and when connecting the 
components select the ones you need.

That's how it could be done.
That's it for now

 -- Fri 10/7/09

