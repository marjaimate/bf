# Brainf@ck erlang interpreter
Minimal brainfuck interpreter in Erlang.
The sole purpose of this exercise is to try out something simple yet challenging in Erlang.

## Brainfuck language definition:

| Symbol | Meaning |
|-------:|--------:|
| *>* | definitionincrement the data pointer (to point to the next cell to the right).  | 
| *<* | rightdecrement the data pointer (to point to the next cell to the left). | 
| *+* | leftincrement (increase by one) the byte at the data pointer. | 
| *-* | pointerdecrement (decrease by one) the byte at the data pointer. | 
| *.* | pointeroutput the byte at the data pointer. | 
| *,* | pointeraccept one byte of input, storing its value in the byte at the data pointer. | 
| *[* | pointerif the byte at the data pointer is zero, then instead of moving the instruction pointer forward to the next command, jump it forward to the command after the matching ] command. | 
| *]* | commandif the byte at the data pointer is nonzero, then instead of moving the instruction pointer forward to the next command, jump it back to the command after the matching [ command. | 

## Hello world in BF
```
++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>.
```
