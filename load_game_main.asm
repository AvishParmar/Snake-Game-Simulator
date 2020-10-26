.data
filename: .asciiz "game01.txt"
.align 2
state: .byte 0x05 0x0c 0x0e 0x45 0x17
.asciiz "XArg153cyIJvv2dkivJvSpka5BXf4MyeauUCg5cfQjiY6bs6BKEqE1cXtvHZ"

.text
.globl main
main:

la $a0, state
la $a1, filename
jal load_game

# You must write your own code here to check the correctness of the function implementation.
move $a0, $v0
li $v0, 1 
syscall 

addi $a0, $0, 0xA 
li $v0, 11
syscall

move $a0, $v1
li $v0, 1
syscall

li $v0, 10
syscall

.include "hwk3.asm"
