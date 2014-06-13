# SimpleScript Concept

## Language structure:

### General:
**//, # and -- can be used to comment out lines.**

Every script is supplied with "function packages".
Examples for such packages are:
* move - Contains basic movement functions for turtles.
* terminal - Contains terminal functions.
* computer - Contains computer functions like file management or checking what computer family it belongs to.
* network - A rednet interface.

Lines are ended with either a new line or a semicolon.

### Blocks and Statements:
Statements include:
* perchance / if - 'if' equivalent.
* otherwise / else - 'else' equivalent.
* perhaps / maybe - 'elseif' equivalent.

Blocks are ended Python-style by indenting its contents and begun with a colon.
E.g:

```
perchance { computer: isAdvanced }:
	terminal: print ["Hello World. This computer is very advanced."]
```

### Functions:
Functions are called with this syntax (<> = required, {} = optional):
```
<function package>: <function name> {[<parameters>]} {*<amount of times to repeat>}[, ..., ...]
```

For example:
```
move: down *2, forward *4
terminal: print ["Parameters!"] *4
```

**To keep things simple there are no user-defined functions!**

## Example program:
```
perchance { computer: isTurtle }:
	move: forward *2, up *4, down
otherwise:
	terminal: print ["This program can only run on a turtle!"]
```



