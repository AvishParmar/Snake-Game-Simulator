.data
direction: .byte 'U'
apples: .byte 1 2 2 9 0 5 1 7 6 10 3 10 3 11 2 10 2 1 2 4 2 5 1 13
apples_length: .word 12
.align 2
state:
.byte 8  # num_rows
.byte 14  # num_cols
.byte 4  # head_row
.byte 5  # head_col
.byte 14  # length
# Game grid:
.asciiz "....................##......................#..a.....#....#..1234..#..........56...E......##.7..CD.........89AB."


.text
.globl main
main:
la $a0, state
lbu $a1, direction
la $a2, apples
lw $a3, apples_length
jal move_snake

# You must write your own code here to check the correctness of the function implementation.
move $a0, $v0
li $v0, 1
syscall

li $a0, 10
li $v0, 11
syscall

move $a0, $v1
li $v0, 1
syscall

li $v0, 10
syscall

.include "hwk3.asm"
