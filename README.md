# ruby_space_invaders

Space Invaders emulator in Ruby.

There was an assembler source code for the Space Invaders game, so I thought I'd implement it with reference to it.
However, because it was a little troublesome to analyze and implement the assembler source, it seemed to be more fun to implement the 8080 CPU emulator and run it on it.

## Implementation status

8080 CPU instructions are being implemented.
The program can run up to the first fraction of a Space Invaders game, but it can't draw images yet.

## Execution

Outputs the status of registers and flags during execution, machine code, and mnemonics.

```
$ pwd
/home/satoshi/RubymineProjects/space_invaders/lib
$ bundle exec ruby main.rb 
PC=0000 SP=0000 A=00 FLAG=00000010 B=00 C=00 D=00 E=00 H=00 L=00 | 00        | NOP
PC=0001 SP=0000 A=00 FLAG=00000010 B=00 C=00 D=00 E=00 H=00 L=00 | 00        | NOP
PC=0002 SP=0000 A=00 FLAG=00000010 B=00 C=00 D=00 E=00 H=00 L=00 | 00        | NOP
PC=0003 SP=0000 A=00 FLAG=00000010 B=00 C=00 D=00 E=00 H=00 L=00 | C3 D4 18  | JP $18D4
PC=18D4 SP=0000 A=00 FLAG=00000010 B=00 C=00 D=00 E=00 H=00 L=00 | 31 00 24  | LD SP,$2400
PC=18D7 SP=2400 A=00 FLAG=00000010 B=00 C=00 D=00 E=00 H=00 L=00 | 06 00     | LD B,$00
PC=18D9 SP=2400 A=00 FLAG=00000010 B=00 C=00 D=00 E=00 H=00 L=00 | CD E6 01  | CALL $01E6
PC=01E6 SP=23FE A=00 FLAG=00000010 B=00 C=00 D=00 E=00 H=00 L=00 | 11 00 1B  | LD DE,$1B00
PC=01E9 SP=23FE A=00 FLAG=00000010 B=00 C=00 D=1B E=00 H=00 L=00 | 21 00 20  | LD HL,$2000
PC=01EC SP=23FE A=00 FLAG=00000010 B=00 C=00 D=1B E=00 H=20 L=00 | C3 32 1A  | JP $1A32
PC=1A32 SP=23FE A=00 FLAG=00000010 B=00 C=00 D=1B E=00 H=20 L=00 | 1A        | LD A,(DE)
PC=1A33 SP=23FE A=01 FLAG=00000010 B=00 C=00 D=1B E=00 H=20 L=00 | 77        | LD (HL),A
PC=1A34 SP=23FE A=01 FLAG=00000010 B=00 C=00 D=1B E=00 H=20 L=00 | 23        | INC HL
PC=1A35 SP=23FE A=01 FLAG=00000010 B=00 C=00 D=1B E=00 H=20 L=01 | 13        | INC DE
PC=1A36 SP=23FE A=01 FLAG=00000010 B=00 C=00 D=1B E=01 H=20 L=01 | 05        | DEC B
PC=1A37 SP=23FE A=01 FLAG=00000010 B=FF C=00 D=1B E=01 H=20 L=01 | C2 32 1A  | JP NZ,$1A32
PC=1A32 SP=23FE A=01 FLAG=00000010 B=FF C=00 D=1B E=01 H=20 L=01 | 1A        | LD A,(DE)
PC=1A33 SP=23FE A=00 FLAG=00000010 B=FF C=00 D=1B E=01 H=20 L=01 | 77        | LD (HL),A
PC=1A34 SP=23FE A=00 FLAG=00000010 B=FF C=00 D=1B E=01 H=20 L=01 | 23        | INC HL
PC=1A35 SP=23FE A=00 FLAG=00000010 B=FF C=00 D=1B E=01 H=20 L=02 | 13        | INC DE
PC=1A36 SP=23FE A=00 FLAG=00000010 B=FF C=00 D=1B E=02 H=20 L=02 | 05        | DEC B
PC=1A37 SP=23FE A=00 FLAG=00000010 B=FE C=00 D=1B E=02 H=20 L=02 | C2 32 1A  | JP NZ,$1A32
..snip..
PC=1A32 SP=23FE A=1C FLAG=00000010 B=01 C=00 D=1B E=FF H=20 L=FF | 1A        | LD A,(DE)
PC=1A33 SP=23FE A=39 FLAG=00000010 B=01 C=00 D=1B E=FF H=20 L=FF | 77        | LD (HL),A
PC=1A34 SP=23FE A=39 FLAG=00000010 B=01 C=00 D=1B E=FF H=20 L=FF | 23        | INC HL
PC=1A35 SP=23FE A=39 FLAG=00000010 B=01 C=00 D=1B E=FF H=21 L=00 | 13        | INC DE
PC=1A36 SP=23FE A=39 FLAG=00000010 B=01 C=00 D=1C E=00 H=21 L=00 | 05        | DEC B
PC=1A37 SP=23FE A=39 FLAG=01000010 B=00 C=00 D=1C E=00 H=21 L=00 | C2 32 1A  | JP NZ,$1A32
PC=1A3A SP=23FE A=39 FLAG=01000010 B=00 C=00 D=1C E=00 H=21 L=00 | C9        | ret
PC=18DC SP=2400 A=39 FLAG=01000010 B=00 C=00 D=1C E=00 H=21 L=00 | CD 56 19  | CALL $1956
PC=1956 SP=23FE A=39 FLAG=01000010 B=00 C=00 D=1C E=00 H=21 L=00 | CD 5C 1A  | CALL $1A5C
PC=1A5C SP=23FC A=39 FLAG=01000010 B=00 C=00 D=1C E=00 H=21 L=00 | 21 00 24  | LD HL,$2400
Traceback (most recent call last):
	9: from main.rb:47:in `<main>'
	8: from main.rb:44:in `main'
	7: from /home/satoshi/RubymineProjects/space_invaders/lib/cpu.rb:58:in `run'
	6: from /home/satoshi/RubymineProjects/space_invaders/lib/cpu.rb:53:in `run_step'
	5: from /home/satoshi/RubymineProjects/space_invaders/lib/cpu.rb:53:in `call'
	4: from /home/satoshi/RubymineProjects/space_invaders/lib/instruction.rb:116:in `mvi'
	3: from /home/satoshi/RubymineProjects/space_invaders/lib/register.rb:60:in `set'
	2: from /home/satoshi/RubymineProjects/space_invaders/lib/register.rb:60:in `call'
	1: from /home/satoshi/RubymineProjects/space_invaders/lib/register.rb:56:in `m='
main.rb:29:in `write': video memory access!! (RuntimeError)
```

## Running tests

```
$ bundle exec autotest
```
