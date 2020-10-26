.data
filename: .asciiz "game09.txt"
directions: .asciiz "DRRRRRRUUUULLLLLDLLDD"
apples_length: .word 60
num_moves_to_execute: .word 500
apples: .byte 0 8 4 6 0 4 2 6 1 4 2 11 1 11 3 2 4 10 0 11 2 4 1 8 3 4 1 5 0 10 4 2 1 0 2 0 4 5 0 9 4 0 2 7 4 1 2 5 2 10 0 5 4 7 3 5 2 2 4 3 4 4 4 8 1 2 3 3 0 2 0 3 2 9 4 9 2 3 3 1 0 6 3 6 3 10 0 0 3 9 1 7 3 0 3 7 2 1 0 7 1 9 1 3 2 8 1 1 3 8 1 10 0 1 3 11 1 6 4 11
.align 2
state: .byte 0x05 0x0c 0x2a 0x36 0x77
.asciiz "NwpHO6lB06DyizI7T8RouKDE8mBAkKsWuxlOalCcJtWMmpAoFeazGmXUXK2r"

.text
.globl main
main:
la $a0, state
la $a1, filename
la $a2, directions
lw $a3, num_moves_to_execute
addi $sp, $sp, -8
la $t0, apples
sw $t0, 0($sp)
lw $t0, apples_length
sw $t0, 4($sp)
li $t0, 123920  # putting garbage in $t0
jal simulate_game
addi $sp, $sp, 8

# You must write your own code here to check the correctness of the function implementation.
move $s0, $v0

li $a0, 40
li $v0, 11
syscall
move $a0, $s0
li $v0, 1
syscall
li $a0, 44
li $v0, 11
syscall
li $a0, 32
li $v0, 11
syscall

move $a0, $v1
li $v0, 1
syscall

li $a0, 41
li $v0, 11
syscall

li $v0, 10
syscall

.include "hwk3.asm"
