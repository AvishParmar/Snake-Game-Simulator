# Avish Parmar
# avparmar
# 112647892

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

.text
load_game:
    # read_row:
    # Read one byte, save into register. Loop again, if 0($sp) = \n, save to state 0($s0)
    # Else, multiply value in saved register by 10, add 2nd value to it and save to state 0($s0)
    
    # Repeat same with read_col
    
    addi $sp, $sp -28 # Allocate space on the stack
    sw $ra, 0($sp) # Store $ra onto the stack
    sw $s0, 4($sp) # Store all $s registers
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    sw $s5, 24($sp)
    
    move $s0, $a0 # Copy state to $s0
    move $s1, $a1 # Copy filename to $s1
    move $s5, $s0
    li $s2, 0 
    
    addi $s0, $s0, 5
    li $t3, 0 # Index counter
    li $t5, 0 # Row counter
    li $t6, 0 # Col counter
    li $t7, 0 # Body length counter

    initialize_state: # Set state to null
    lb $t0, 0($s0) # Load character from state
    beqz $t0, open_file  # If character is null break loop
    move $t0, $zero # Copy null to $t0
    sb $t0, 0($s0) # Replace character in state with a null in $t0
    addi $s0, $s0, 1 # Load next character address
    addi $t3, $t3, -1
    j initialize_state # Loop again
    
    open_file: # Open the txt file
    add $s0, $s0, $t3 # Reset index of $s0
    move $a0, $s1 # Provide address of filename to $a0
    li $a1, 0 # Set flag to 0 for read-only
    li $v0, 13 # Open file initial
    syscall # Execute 
    li $t0, -1 # Flag
    
    ble $v0, $t0, load_game_return_error  # If negative, return to caller with error
    
    move $t2, $v0 # $t2 = file descriptor
    li $t3, 0 # Apple counter
    li $t4, 0 # Wall counter
    addi $sp, $sp -4 # Allocate space to provide an input buffer for read_file
    
    read_row:
    addi $s0, $s0 -5 # Restore index
    li $v0, 14 # Read file initial
    move $a0, $t2 # $a0 = file descriptor
    move $a1, $sp # $a1 = input buffer
    li $a2, 1 # $a2 = 1 character
    syscall # read_file
    
    lb $t0, 0($sp) # Load character address read
    li $t1, 49 # $t1 = 1
    bge $t0, $t1, save_row # if $t0 >= 1, save_row
    li $t1, 10 # $t1 = \n
    beq $t0, $t1, state_before_col # if $t1 = \n, move on to read_col
    addi $s0, $s0, 5 # Deallocate
    j read_row
    
    save_row:
    bnez $s2, save_double_digit_row # If $s2 != 0, jump to save_double_digit_Row
    move $s2, $t0 # Else, $s2 = character read
    addi $s2, $s2, -48 # Get integer value
    sb $s2, 0($s0) # Save to state
    addi $s0, $s0, 5 # Deallocate
    j read_row # Loop again
    save_double_digit_row:
    li $t1, 10 
    mul $s2, $s2, $t1 # $s2 = $s2 * 10
    addi $t0, $t0, -48 # Get integer value of character
    add $s2, $s2, $t0 # $s2 = $s2 + $t0
    sb $s2, 0($s0) # Save to state
    addi $s0, $s0, 5 # Deallocate
    j read_row # Loop again
    
    state_before_col:
    addi $s0, $s0, 5
    li $s2, 0
    
    read_col:
    addi $s0, $s0 -5 # Restore index
    li $v0, 14 # Read file initial
    move $a0, $t2 # $a0 = file descriptor
    move $a1, $sp # $a1 = input buffer
    li $a2, 1 # $a2 = 1 character
    syscall # read_file
    
    lb $t0, 0($sp) # Load character address read
    li $t1, 49 # $t1 = 1
    bge $t0, $t1, save_col # if $t0 >= 1, save_col
    li $t1, 10 # $t1 = \n
    beq $t0, $t1, reset_state # if $t1 = \n, move on to read_col
    addi $s0, $s0, 5 # Deallocate
    j read_col
    
    save_col:
    bnez $s2, save_double_digit_col
    move $s2, $t0 # Else, $s2 = character read
    addi $s2, $s2, -48 # Get integer value
    sb $s2, 1($s0) # Save to state
    addi $s0, $s0, 5 # Deallocate
    j read_col # Loop again
    
    save_double_digit_col:
    li $t1, 10 
    mul $s2, $s2, $t1 # $s2 = $s2 * 10
    addi $t0, $t0, -48 # Get integer value of character
    add $s2, $s2, $t0 # $s2 = $s2 + $t0
    sb $s2, 1($s0) # Save to state
    addi $s0, $s0, 5 # Deallocate
    li $s2, 0
    j read_col # Loop again
    
    reset_state: 
    addi $s0, $s0, 5
    li $s2, 0
    li $t7, 0
    
    read_file: # Read the txt file
    li $v0, 14 # Read file initial
    move $a0, $t2 # Assign file descriptor to $a0
    move $a1, $sp # Input buffer
    li $a2, 1 # Read one character at a time
    syscall # Read the character from file
    
    beqz $v0, close_file
   
    read_character: 
    lb $t0, 0($sp) # $t0 = character read from file
    li  $t1, 13
    beq $t0, $t1, skip_character # $t0 = \r then skip_character
    li  $t1, 10
    beq $t0, $t1, skip_character_n # $t0 = \n then skip_character
    beqz $v0, close_file
    
    save_character: # Save the character and performs additional operation
    sb $t0, 0($s0) # Save character to state
    addi $s0, $s0, 1 # Load next character index
    li $t1, 97		# $t1 = apple
    beq $t0, $t1, save_character_apple # if $t0 = apple, then save_character_apple
    li $t1, 35		# $t1 = wall
    beq $t0, $t1, save_character_wall # if $t0 = wall, then save_character_wall
    li $t1, 49
    beq $t0, $t1, save_head
    li $t1, 46
    beq $t0, $t1, save_character_slot
    j save_character_body_part
    
    save_character_slot:
    beqz $v0, close_file
    addi $t6, $t6, 1
    j read_file
    
    save_head:
    move $s3, $t5 # $s3 = head_row
    move $s4, $t6 # $s4 = head_col
    
    save_character_body_part:
    addi $t7, $t7, 1 # Increment body length
    addi $t6, $t6, 1 # Increment col
    beqz $v0, close_file # if $v0 = 0, close the file
    j read_file
    
    save_character_apple: # Increments apple counter
    addi $t3, $t3, 1 # Increment apple counter
    addi $t6, $t6, 1 # Increment col
    beqz $v0 close_file # if $v0 = 0, close the file
    j read_file # Read next character from the file
    
    save_character_wall: # Increments wall counter
    addi $t4, $t4, 1 # Increment wall counter
    addi $t6, $t6, 1 # Increment col
    beqz $v0, close_file # If $v0 = 0, close the file
    j read_file # Read next character from the file
  
    skip_character: # Skips the current character
    beqz $v0, close_file # If $v0 = 0, close the file
    j read_file # Read next character from the file
    
    skip_character_n: # Skips new line
    beqz $v0, close_file # If $v0 = 0, close the file
    addi $t5, $t5, 1 # Increment row
    li $t6, 0 # Reset col
    j read_file # Read next character from the file
    
    close_file: # Closes the file
    move $a0, $t2 # $a0 = file decipher
    li $v0, 16 # Close file initial
    syscall # Execute
    addi $sp, $sp, 4 # Deallocate stack
    beqz $t3, load_game_return # if $t3 = 0, (no apples found) go to load_game_return
    li $t3, 1 # else $t3 = 1 (apple(s) found)
    j load_game_return # Jump to load_game_return
    
    
    load_game_return_error: # File not found 
    lw $ra, 0($sp) # Restore $ra from stack
    lw $s0, 4($sp) # Restore all $s registers
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    lw $s5, 24($sp)
    addi $sp, $sp, 28 # Deallocate stack
    
    move $v0, $t0 # $v0 = -1
    move $v1, $v0 # $v1 = -1
    jr $ra # Return to caller
    
    load_game_return: # Return to caller
    sb $s3, 2($s5)
    sb $s4, 3($s5)
    sb $t7, 4($s5)
   
    lw $ra, 0($sp) # Restore $ra from stack
    lw $s0, 4($sp) # Restore all $s registers
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    lw $s5, 24($sp)
    addi $sp, $sp, 28 # Deallocate stack
    
    move $v0, $t3 # $v0 = 0 (no apple(s) found), $v0 = 1 (apple(s) found)
    move $v1, $t4 # $v1 = # of walls found
    jr $ra # Return to caller

get_slot:
    addi $sp, $sp -16 # Allocate space on the stack
    sw $ra, 0($sp) # Store $ra onto the stack
    sw $s0, 4($sp) # Store $s registers used in get_slot
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    
    move $s0, $a0 # state
    move $s1, $a1 # row
    move $s2, $a2 # col
    
    
    lb $t0, 0($s0) # $t0 = num_row
    lb $t1, 1($s0) # $t1 = num_col
    addi $s0, $s0, 5
    
    addi $t0, $t0, -1 # Number of rows in terms of index
    addi $t1, $t1, -1 # Number of columns in terms of index
    
    bgt $s1, $t0, get_slot_return_error # If char_row >=  # of rows - 1, throw error
    bgt $s2, $t1, get_slot_return_error # If char_column >= # of columns - 1 throw error
    
    blt $s1, $zero, get_slot_return_error # If char_row < 0, throw error 
    blt $s2, $zero, get_slot_return_error # If char_column < 0 , throw error
    
    addi $t0, $t0, 1 # Restore $t0
    addi $t1, $t1, 1 # Restore $t1
     
    mul $s1, $s1, $t1 # row = row * num_col
   
    add $s1, $s1, $s2 # row = row + col
    
    add $s0, $s0, $s1 # addr = base_addr + row
    
    lbu $t2, 0($s0) # Load character address at index
    j get_slot_return # Return to caller
    
    get_slot_return_error: # Return to caller with error
    lw $ra, 0($sp) # Restore $ra from stack
    lw $s0, 4($sp) # Restore $s registers used in get_slot
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16 # Deallocate stack
    li $v0, -1 # $v0 = -1 (invalid bounds)
    jr $ra 
    
    get_slot_return: # Return to caller with character address
    lw $ra, 0($sp) # Restore $ra from stack
    lw $s0, 4($sp) # Restore $s registers used in get_slot
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16 # Deallocate stack
    move $v0, $t2 # $v0 = character address at index
    jr $ra

set_slot:    
    addi $sp, $sp -20 # Allocate space on the stack
    sw $ra, 0($sp) # Store $ra onto the stack
    sw $s0, 4($sp) # Store $s registers used in set_slot
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
     
    move $s0, $a0 # state
    move $s1, $a1 # row
    move $s2, $a2 # col
    move $s3, $a3 # ch
     
    lb $t0, 0($s0) # $t0 = num_row
    lb $t1, 1($s0) # $t1 = num_col
    addi $s0, $s0, 5
    
    addi $t0, $t0, -1 # Number of rows in terms of index
    addi $t1, $t1, -1 # Number of columns in terms of index
    
    bgt $s1, $t0, set_slot_return_error # If char_row >=  # of rows - 1, throw error
    bgt $s2, $t1, set_slot_return_error # If char_column >= # of columns - 1 throw error
    
    blt $s1, $zero, set_slot_return_error # If char_row < 0, throw error 
    blt $s2, $zero, set_slot_return_error # If char_column < 0 , throw error
    
    addi $t0, $t0, 1 # Restore $t0
    addi $t1, $t1, 1 # Restore $t1
     
    mul $s1, $s1, $t1 # row = row * num_col
   
    add $s1, $s1, $s2 # row = row + col
    
    add $s0, $s0, $s1 # addr = base_addr + row
    
    sb $s3, 0($s0)
    j set_slot_return # Return to caller
    
    set_slot_return_error: # Return to caller with error
    lw $ra, 0($sp) # Restore $ra from stack
    lw $s0, 4($sp) # Restore $s registers used in set_slot
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20 # Deallocate stack
    li $v0, -1
    jr $ra # Return to caller ($v0 = -1)
    
    set_slot_return: # Return to caller
    move $v0, $s3 # $v0 = char
    lw $ra, 0($sp) # Restore $ra from stack
    lw $s0, 4($sp) # Restore $s registers used in set_slot
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20 # Deallocate stack
    jr $ra # Return to caller

place_next_apple:
   # To find an apple to place in the grid, start with first two coordinates
   # See if that position is empty (position has '.')
   # If it does, change position to 'a' using set_slot then change both indexes of apple to -1
   # If it contains a wall or a part of the snake or another apple, skip over the two coordinates and move on to the next.
   # If (-1,-1) is encountered in apples, skip over it and continue to the next pair.
    addi $sp, $sp, -16 # Allocate stack
    sw $ra, 0($sp) # Save $ra onto the stack
    sw $s0, 4($sp) # Save all $s registers used in find_next_body_part
    sw $s1, 8($sp)
    sw $s2, 12($sp)
  
    move $s0, $a0 # state
    move $s1, $a1 # apples
    move $s2, $a2 # apples_length
    move $t1, $s1 # Copy of $s1
    li $t9, 0
    apples_index_loop:
    
    beqz $s2, place_next_apple_return
    
    check_position: # Check the coordinates given from the apples array for valid position
    move $a0, $s0 # state
    lb $a1, 0($t1) # Load apple row 
    lb $a2, 1($t1) # Load apple col
    
    blt $a1, $zero, load_apple_index # If apple row < 0, load new coordinates
    blt $a2, $zero, load_apple_index # If apple column < 0, load new coordinates
    
    addi $sp, $sp, -16 # Allocate space on the stack
    sw $a1, 0($sp) # Store apple row onto the stack
    sw $a2, 4($sp) # Store apple column onto the stack
    sw $t1, 8($sp) # Store $t registers onto the stack
    sw $t9, 12($sp) 
    
    jal get_slot # returns character located at state.grid[apple row][apple col], else -1
    
    
    lw $a1, 0($sp) # Load apple row from stack
    lw $a2, 4($sp) # Load apple column from stack
    lw $t1, 8($sp) # Restore $t registers from the stack
    lw $t9, 12($sp) 
    addi $sp, $sp, 16 # Deallocate stack
     
    move $t0, $v0 # $t0 = character read at index
    li $t2, 46 # '.' in ASCII
    bne $t0, $t2, load_apple_index # If $t0 != . load new coordinates
   
    set_apple: # If position is valid, spawn an apple at the position
    move $a0, $s0 # $a0 = state
    lb $a1, 0($t1) # Load apple row 
    lb $a2, 1($t1) # Load apple col
    li $a3, 97 # a3 = 'a' in ASCII
    
    addi $sp, $sp, -20 # Allocate space on stack
    sw $a1, 0($sp) # Save $a registers onto the stack
    sw $a2, 4($sp)
    sw $a3, 8($sp)
    sw $t1, 12($sp) # Save $t registers to the stack
    sw $t9, 16($sp) 
    
    jal set_slot # Sets the index to 'a'
    
    lw $a1, 0($sp) # Restore $a registers from the stack
    lw $a2, 4($sp)
    lw $a3, 8($sp)
    lw $t1, 12($sp) # Load $t registers from the stack
    lw $t9, 16($sp)
    addi $sp, $sp, 20 # Deallocate stack
    
    j update_apples
    
    load_apple_index: # Load new coordinates
    addi $t1, $t1, 2 # Increment index by 2
    addi $s2, $s2, -1 # Decrement apple length by 1
    addi $t9, $t9, -1 # Increment load_apple_index counter
    j apples_index_loop # Loop again
    
    update_apples:
    li $t0, -1 
    sb $t0, 0($t1) # Initialize $t1 indexes to -1 to indicate used coordinates
    sb $t0, 1($t1)
    li $t0, 2 # Number of times indexes moved during each load_apple_index call
    mul $t9, $t9, $t0 # Multiply load_apple_index counter by $t0 to get total difference of the apples address 
    add $t1, $t1, $t9 # Restore apples address
    move $s1, $t1 # Copy $t1 back into $s1
    j place_next_apple_return
    
    place_next_apple_return:
    lw $ra, 0($sp) # Restore $ra
    lw $s0, 4($sp) # Restore all $s registers
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16 # Deallocate stack
    move $v0, $a1 # $v0 = apple row
    move $v1, $a2 # $v1 = apple col
    jr $ra

find_next_body_part:
# Inspects four grid slots up, down, left, and right of [row][col] for the character target_part.
# If found, return coordinates of target_part
# Else return -1, -1
# If row or col is outside its valid range, return -1, -1

    addi $sp, $sp, -20 # Allocate stack
    sw $ra, 0($sp) # Save $ra onto the stack
    sw $s0, 4($sp) # Save all $s registers used in find_next_body_part
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    
    move $s0, $a0 # state
    move $s1, $a1 # row
    move $s2, $a2 # col
    move $s3, $a3 # target_part
    
    addi $sp, $sp, -12 # Allocate space on the stack
    sw $a0, 0($sp) # Save all $a registers used by get_slot
    sw $a1, 4($sp)
    sw $a2, 8($sp)
    
    jal get_slot # Call get_slot
    
    lw $a0, 0($sp)
    lw $a1, 4($sp)
    lw $a2, 8($sp) # Restore all $a registers from the stack
    addi $sp, $sp, 12 # Deallocate stack
    
    move $t0, $v0 # $t0 = character found at index
    bltz $t0, find_next_body_part_return_error # if $t0 < 0, return error since index is invalid
    beq $t0, $s3, find_next_body_part_return # else if $t0 = target_part, return coordinates
    
    look_up:
    
    move $a1, $s1 # $a1 = row
    beqz $a1, look_down # if $a1 = 0, jump to look_down (no rows above it)
    move $a0, $s0 # state
    addi $a1, $a1, -1 # $a1 = row - 1 (row above current)
    move $a2, $s2 # $a2 = col (same column index)
    
    addi $sp, $sp, -12 # Allocate space on the stack
    sw $a0, 0($sp) # Save all $a registers used by get_slot
    sw $a1, 4($sp)
    sw $a2, 8($sp)
    
    jal get_slot # Call get_slot
    
    lw $a0, 0($sp)
    lw $a1, 4($sp)
    lw $a2, 8($sp) # Restore all $a registers from the stack
    addi $sp, $sp, 12 # Deallocate stack
    
    move $t0, $v0 # $t0 = character found at index
    move $a3, $s3 # $a3 = target_part
    beq $t0, $a3, find_next_body_part_return # if $t0 = $a3, return coordinates
        
    look_down:
    move $a1, $s1 # $a1 = row
    move $a0, $s0 # $a0 = state 
    lb $t0, 0($s0) # $t0 = num_rows
    addi $t0, $t0 -1 #$t0 = num_rows - 1
    bge $a1, $t0, look_right # if $a1 >= $t0, jump to look_right (no rows below it)
    addi $a1, $a1, 1 # $a1 = row + 1 (row below current)
    move $a2, $s2 # $a2 = col (same column index)
    
    addi $sp, $sp, -12 # Allocate space on the stack
    sw $a0, 0($sp) # Save all $a registers used by get_slot
    sw $a1, 4($sp)
    sw $a2, 8($sp)
    
    jal get_slot # Call get_slot
    
    lw $a0, 0($sp)
    lw $a1, 4($sp)
    lw $a2, 8($sp) # Restore all $a registers from the stack
    addi $sp, $sp, 12 # Deallocate stack
    
    move $t0, $v0 # $t0 = character found at index
    move $a3, $s3 # $a3 = target_part
    beq $t0, $a3, find_next_body_part_return # if $t0 = $a3, return coordinates
    
    look_right:
    move $a0, $s0 # $a0 = state
    move $a1, $s1 # $a1 = row
    move $a2, $s2 # $a2 = col
    lb $t0, 1($s0) # $t0 = num_cols
    addi $t0, $t0, -1 # $t0 = num_cols - 1
    bge $a2, $t0, look_left # if $a2 >= $t0, jump to look_left (no columns in its right)
    addi $a2, $a2, 1 # a2 = col + 1 (column to the right)
    
    addi $sp, $sp, -12 # Allocate space on the stack
    sw $a0, 0($sp) # Save all $a registers used by get_slot
    sw $a1, 4($sp)
    sw $a2, 8($sp)
    
    jal get_slot # Call get_slot
    
    lw $a0, 0($sp)
    lw $a1, 4($sp)
    lw $a2, 8($sp) # Restore all $a registers from the stack
    addi $sp, $sp, 12 # Deallocate stack
    
    move $t0, $v0 # $t0 = character found at index
    move $a3, $s3 # $a3 = target_part
    beq $t0, $a3, find_next_body_part_return # if $t0 = $a3, return coordinates
    
    look_left:
    move $a0, $s0 # $a0 = state
    move $a1, $s1 # $a1 = row
    move $a2, $s2 # $a2 = col
    beqz $a2, find_next_body_part_return_error # if $a2 = 0, no columns to its left. Return error 
    addi $a2, $a2, -1 # $a2 = col - 1 (column to the left)
    
    addi $sp, $sp, -12 # Allocate space on the stack
    sw $a0, 0($sp) # Save all $a registers used by get_slot
    sw $a1, 4($sp)
    sw $a2, 8($sp)
    
    jal get_slot # Call get_slot
    
    lw $a0, 0($sp)
    lw $a1, 4($sp)
    lw $a2, 8($sp) # Restore all $a registers from the stack
    addi $sp, $sp, 12 # Deallocate stack
    
    move $t0, $v0 # $t0 = character found at index
    move $a3, $s3 # $a3 = target_part
    beq $t0, $a3, find_next_body_part_return # if $t0 = $a3, return coordinates  
    
    find_next_body_part_return_error: # Returns to caller with error values 
    lw $ra, 0($sp) # Restore $ra
    lw $s0, 4($sp) # Restore all $s registers
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20 # Deallocate stack
    
    li $v0, -1 # $v0 = -1
    li $v1, -1 # $v1 = -1
    jr $ra # Return to caller 
    
    find_next_body_part_return: # Returns to caller with the coordinates of target_part on the grid if found.
    lw $ra, 0($sp) # Restore $ra
    lw $s0, 4($sp) # Restore all $s registers
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20 # Deallocate stack
    
    move $v0, $a1 # $v0 = row index of character
    move $v1, $a2 # $v1 = column index of character
    jr $ra # Return to caller

slide_body:
    # Algorithm: First, Get coordinates of head by loading them from state:
    # $t1 = head_row 
    # $t2 = head_col
    # Calculate the coordinate to move head to by doing $t1 + $s1 (for row) and $t2 + $s2 (for head)
    # Get the character at that slot. If it is equal to 'a', call place_next_apple first, then move head using set_slot
    # To place new apple, Using apples_length as a loop counter:
    # End the loop, restore apples_length and then call set_slot to move the head. 
    # set_slot: $a0 = state, $a1 = row, $a2 = col, $a3 = ch
    # Else if the character is equal to '.', then move head using set_slot
    # Else if the slot is either out of bounds or a wall ('#'), dont make any changes and return -1
    # Set $s5 to indicate waht happened during the attempted move.
    # $s5 = 0 if the head moved onto a slot containing '.'
    # $s5 = 1 if the head moved onto a slot containing 'a'
    # Else, if the move cannot be done, directly set $v0 = -1, $s5 does not need to come into play.
    
    # Second: the move is possible (either $s5 = 0 or 1), move the rest of the body parts
    # In a loop: using $t3 = length of snake ( 4($s0) ) as loop counter
    # If loop counter != 0: else jump to return
    # If target_part > 57, jump to alphabet_body_part
    # Call find_next_body_part, $a0 = state, $a1 = previous body part row, $a2 = previous body part column, $a3 = target_part
    # Get coordinates of next body part: $v0 = next body row, $v1 = next body col.
    # Call set_slot: $a0 = state, $a1 = previous body part row, $a2 = previous body part col, $a3 = target_part
    # $t1 = $v0
    # $t2 = $v1
    # Decrement loop counter (addi $t3, $t3, -1)
    # target_part++
    # loop again
    
    # alphabet_body_part: 
    # li $t4 = 65 ASCII for A
    
    #alphabet_body_part_loop:
    # if loop counter != 0: else jump to return
    # Call find_next_body_part, $a0 = state, $a1 = previous body part row, $a2 = previous body part col, $a3 = target_part
    # Get coordinates of next body part: $v0 = next body row, $v1 = next body col.
    # Call set_slot: $a0 = state, $a1 = previous body part row, $a2 = previous body part col, $a3 = target_part
    # $t1 = $v0
    # $t2 = $v1
    # Decrement loop counter (addi $t3, $t3, -1)
    # target_part++
    # loop agian
    lw $t0, 0($sp) # $t0 = apples_length
    
    addi $sp, $sp, -24 # Allocate space on the stack
    sw $ra, 0($sp) # Store $ra onto the stack
    sw $s0, 4($sp) # Store all $s registers used in slide_body
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s5, 20($sp)
    
    move $s0, $a0 # $s0 = state
    move $s1, $a1 # $s1 = head_row_delta
    move $s2, $a2 # $s2 = head_col_delta
    move $s3, $a3 # $s3 = apples
    li $s5, 0 # $s5 = return value holder
    
    lb $t1, 2($s0) # head_row
    lb $t2, 3($s0) # head_col
    
    add $s1, $t1, $s1 # Row Coordinate to move head to 
    add $s2, $t2, $s2 # Column Coordinate to move head to 
    
    addi $sp, $sp, -12 # Allocate space on the stack
    sw $t0, 0($sp) # Save all $t registers
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    
    move $a0, $s0 # $a0 = state
    move $a1, $s1 # $a1 = move_head_row
    move $a2, $s2 # $a2 = move_head_col
    
    jal get_slot # Get character at the slot to move to
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp) # Restore all $t registers
    addi $sp, $sp, 12 # Deallocate stack
    
    move $t3, $v0 # $t3 = character found at slot
    bltz $t3, slide_body_return_error # If $t3 = -1, it indicates that this slot is outside the game board, return error
    li $t4, 35 
    beq $t3, $t4, slide_body_return_error # If $t3 = 35, indicating a wall, return error since such a move is not possible
    li $t4, 97
    beq $t3, $t4, place_apple # If $t3 = 'a', indicating an apple, jump to place_apple
    li $t4, 46
    beq $t3, $t4, move_head # If $t3 = '.', indicating an empty slot, jump to move_head
    
    j slide_body_return_error
    place_apple: # Places a new apple on the grid.
    beqz $t0, slide_body_return_error
    
    addi $sp, $sp, -20 # Allocate space on the stack
    sw $t0, 0($sp) # Save all $t registers used in slide_body
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t4, 16($sp)
    
    move $a0, $s0 # state
    move $a1, $s3 # apples
    move $a2, $t0 # apples_length
    
    jal place_next_apple
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp) # Restore $t registers
    addi $sp, $sp, 20 # Deallocate stack
    
    li $s5, 1 # Indicates that the snake's head is about to move onto a slot containing an apple
    
    move_head:
    li $t4, 49 # ASCII for 1 (head)
    
    addi $sp, $sp, -20 # Allocate space on the stack
    sw $t0, 0($sp) # Save all $t registers used in slide_body
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t4, 16($sp)
    
    move $a0, $s0 # state
    move $a1, $s1 # row
    move $a2, $s2 # col
    move $a3, $t4 # ch
    
    jal set_slot # Move head one spot forward
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp) # Restore $t registers
    addi $sp, $sp, 20 # Deallocate stack
    
    bltz $v0, slide_body_return_error
    
    sb $s1, 2($s0) # Save head_row
    sb $s2, 3($s0) # Save head_col
    
    move $s1, $t1 # $s1 = coordinate to move next body part to (ROW)
    move $s2, $t2 # $s2 = coordinate to move next body part to (COLUMN)
    
    lb $t3, 4($s0) # $t3 = length of snake (loop counter)
    addi $t3, $t3, -1 # Since head is already moved, move_body_segments will move the other length-1 segments
    li $t5, 57 # ASCII for 9 
    bltz $t3, slide_body_return_error # If length of snake < 0, return error
    move_body_segments_numbers:
    
    beqz $t3, initialize_tail # If length of snake = 0, break loop
    
    bge $t4, $t5, move_body_segments_alphabets_initialize # If $t4 >= 57, go to move_body_segments_alphabets
    addi $t4, $t4, 1 # $t4 = next digit in ASCII
    
    addi $sp, $sp, -24 # Allocate space on the stack
    sw $t0, 0($sp) # Save all $t registers used in slide_body
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t4, 16($sp)
    sw $t5, 20($sp)
    
    move $a0, $s0 # state
    move $a1, $s1 # row
    move $a2, $s2 # col
    move $a3, $t4 # target_part
    
    jal find_next_body_part # Find next body part call
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp) # Restore $t registers
    lw $t5, 20($sp)
    addi $sp, $sp, 24 # Deallocate stack
    
    move $t1, $v0 # Coordinate of current body part to move (ROW)
    move $t2, $v1 # Coordinate of current body part to move (COLUMN)
    
    addi $sp, $sp, -24 # Allocate space on the stack
    sw $t0, 0($sp) # Save all $t registers used in slide_body
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t4, 16($sp)
    sw $t5, 20($sp)
    
    move $a0, $s0 # State
    move $a1, $s1 # Row
    move $a2, $s2 # Col
    move $a3, $t4 # target_part (ch)
    
    jal set_slot # Move body segment one position
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp) # Restore $t registers
    lw $t5, 20($sp)
    addi $sp, $sp, 24 # Deallocate stack
    
    move $s1, $t1 # $s1 = coordinate to move next body part to (ROW)
    move $s2, $t2 # $s2 = coordinate to move next body part to (COLUMN)
    addi $t3, $t3, -1 # Decrement loop counter
    
    j move_body_segments_numbers # Loop again
    
    move_body_segments_alphabets_initialize:
    li $t5, 91
    li $t4, 65
    move_body_segments_alphabets:
    beqz $t3, initialize_tail # If length of snake = 0, break loop
    beq $t4, $t5, initialize_tail # If length of snake exceeds the range of both numbers and alphabets, return to caller
    addi $sp, $sp, -24 # Allocate space on the stack
    sw $t0, 0($sp) # Save all $t registers used in slide_body
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t4, 16($sp)
    sw $t5, 20($sp)
    
    move $a0, $s0 # state
    move $a1, $s1 # row
    move $a2, $s2 # col
    move $a3, $t4 # target_part
    
    jal find_next_body_part # Find next body part call
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp) # Restore $t registers
    lw $t5, 20($sp)
    addi $sp, $sp, 24 # Deallocate stack
    
    move $t1, $v0 # Coordinate of current body part to move (ROW)
    move $t2, $v1 # Coordinate of current body part to move (COLUMN)
    
    addi $sp, $sp, -24 # Allocate space on the stack
    sw $t0, 0($sp) # Save all $t registers used in slide_body
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t4, 16($sp)
    sw $t5, 20($sp)
    
    move $a0, $s0 # State
    move $a1, $s1 # Row
    move $a2, $s2 # Col
    move $a3, $t4 # target_part (ch)
    
    jal set_slot # Move body segment one position
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp) # Restore $t registers
    lw $t5, 20($sp)
    addi $sp, $sp, 24 # Deallocate stack
    
    move $s1, $t1 # $s1 = coordinate to move next body part to (ROW)
    move $s2, $t2 # $s2 = coordinate to move next body part to (COLUMN)
    addi $t3, $t3, -1 # Decrement loop counter
    addi $t4, $t4, 1 # Load next character
    
    j move_body_segments_alphabets # Loop again
    
    initialize_tail:
    li $t4, 46 # ASCII for '.'
    
    addi $sp, $sp, -24 # Allocate space on the stack
    sw $t0, 0($sp) # Save all $t registers used in slide_body
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t4, 16($sp)
    sw $t5, 20($sp)
    
    move $a0, $s0 # State
    move $a1, $s1 # Row
    move $a2, $s2 # Col
    move $a3, $t4 # target_part (ch)
    
    jal set_slot # Initialize tail to '.'
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp) # Restore $t registers
    lw $t5, 20($sp)
    addi $sp, $sp, 24 # Deallocate stack
    
    j slide_body_return 
    
    slide_body_return_error:
    lw $ra, 0($sp) # Restore $ra from the stack
    lw $s0, 4($sp) # Restore all $s registers used in slide_body
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s5, 20($sp)
    addi $sp, $sp, 24
    li $v0, -1 # -1 indicates that the snake was not moved at all
    
    jr $ra # Return to caller
    
    slide_body_return:
    move $v0, $s5 # $v0 = indicator of where the head was moved
    
    lw $ra, 0($sp) # Restore $ra from the stack
    lw $s0, 4($sp) # Restore all $s registers used in slide_body
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s5, 20($sp)
    addi $sp, $sp, 24
    
    jr $ra # Return to caller

add_tail_segment:
    # Takes coordinates of the tail and attempts to add a new segment to the tail of the snake in the given direction
    # The new tail segment may only be placed on an empty grid slot, denoted by '.'
    # If successfully added, the length field of the state object must be incremented by 1,
    # New length is returned by add_tail_segment
    # If tail segment is not added, the function makes no changes to main memory and returns -1.
    # Directions:
    # U = (1,0), D: (-1, 0), L: (0,-1), R: (0,1)
    addi $sp, $sp, -24 
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    
    move $s0, $a0 # state
    move $s1, $a1 # direction
    move $s2, $a2 # tail_row
    move $s3, $a3 # tail_col
    
    lb $t0, 4($s0)
    li $t1, 35
    beq $t0, $t1, add_tail_segment_return_error # If length of snake == 35, return error since cannot increase length.
    
    move $a0, $s0 # state
    move $a1, $s2 # tail_row
    move $a2, $s3 # taiL_col
    
    addi $sp, $sp -8 # Store all $t registers
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    
    jal get_slot # Get character at tail_row and tail_col
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    addi $sp, $sp, 8 # Restore all $t registers
    
    move $s4, $v0 # $s4 = character read at index
    bltz $s4, add_tail_segment_return_error # if $s4 < 0, return error
    
    li $t0, 57 # $t0 = 9
    beq $s4, $t0, initialize_new_tail # if $s4 = 9, simply incrementing it wont work, so load next character in initialize_new_tail
    addi $s4, $s4, 1 # Else, increment $s4 to load new tail character
    j determine_direction # Determine the direction in which to add the tail
    
    initialize_new_tail: # Initializes $s4 to A when current tail is a 9
    li $s4, 65 # $s4 = A
    
    determine_direction: # Determine the direction in which to add the tail
    li $t0, 85 # U 
    beq $t0, $s1, add_tail_up # If the direction is 'U' (up), jump to add_tail_up
    
    li $t0, 68 # D
    beq $t0, $s1, add_tail_down # If direction is 'D' (down), jump to add_tail_down
    
    li $t0, 76 # L
    beq $t0, $s1, add_tail_left # If direction is 'L' (left), jump to add_tail_left
    
    li $t0, 82 # R
    beq $t0, $s1, add_tail_right # If direction is 'R' (right)< jump to add_tail_right
    
    j add_tail_segment_return_error # After checking each direction, if the direction is != to U, D, L, or R, return error
    
    add_tail_up: # Add new tail in the row below
    
    li $t1, -1 # tail_row_delta
    li $t2, 0 # tail_col_delta
    add $s2, $s2, $t1 # new_tail_row
    add $s3, $s3, $t2 # new_tail_col
    
    move $a0, $s0 # state
    move $a1, $s2 # new_tail_row
    move $a2, $s3 # new_tail_col
    
    addi $sp, $sp, -12 # Save all $t registers used in add_tail_segment
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    
    jal get_slot # Get character at new_tail_row and new_tail_col
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    addi $sp, $sp, 12 # Restore all $t registers
    
    li $t0, 46 # '.'
    move $t3, $v0 # $t0 = character read at new_tail slot
    
    bne $t0, $t3, add_tail_segment_return_error  # If the new_tail slot is not an empty slot, return error
    
    addi $sp, $sp, -16 # Save all $t registers used in add_tail_segment
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    
    move $a0, $s0 # State
    move $a1, $s2 # new_tail_row
    move $a2, $s3 # new_tail_col
    move $a3, $s4 # new_tail
    
    jal set_slot # Add new_tail to the snake
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    addi $sp, $sp, 16 # Restore all $t registers
    
    lb $t0, 4($s0) # Load length
    addi $t0, $t0, 1 # Increment length
    sb $t0, 4($s0) # Store new length
    
    j add_tail_segment_return
    
    add_tail_down: # Add new tail in the row above
    
    li $t1, 1 # tail_row_delta
    li $t2, 0 # tail_col_delta
    add $s2, $s2, $t1 # new_tail_row
    add $s3, $s3, $t2 # new_tail_col
    
    move $a0, $s0 # state
    move $a1, $s2 # new_tail_row
    move $a2, $s3 # new_tail_col
    
    addi $sp, $sp, -12 # Save all $t registers used in add_tail_segment
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    
    jal get_slot # Get character at new_tail_row and new_tail_col
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    addi $sp, $sp, 12 # Restore all $t registers
    
    li $t0, 46 # '.'
    move $t3, $v0 # $t0 = character read at new_tail slot
    
    bne $t0, $t3, add_tail_segment_return_error  # If the new_tail slot is not an empty slot, return error
    
    addi $sp, $sp, -16 # Save all $t registers used in add_tail_segment
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    
    move $a0, $s0 # State
    move $a1, $s2 # new_tail_row
    move $a2, $s3 # new_tail_col
    move $a3, $s4 # new_tail
    
    jal set_slot # Add new_tail to the snake
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    addi $sp, $sp, 16 # Restore all $t registers
    
    lb $t0, 4($s0) # Load length
    addi $t0, $t0, 1 # Increment length
    sb $t0, 4($s0) # Store new length
    
    j add_tail_segment_return
    
    add_tail_left: # Add new tail in the column to the left
    
    li $t1, 0 # tail_row_delta
    li $t2, -1 # tail_col_delta
    add $s2, $s2, $t1 # new_tail_row
    add $s3, $s3, $t2 # new_tail_col
    
    move $a0, $s0 # state
    move $a1, $s2 # new_tail_row
    move $a2, $s3 # new_tail_col
    
    addi $sp, $sp, -12 # Save all $t registers used in add_tail_segment
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    
    jal get_slot # Get character at new_tail_row and new_tail_col
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    addi $sp, $sp, 12 # Restore all $t registers
    
    li $t0, 46 # '.'
    move $t3, $v0 # $t0 = character read at new_tail slot
    
    bne $t0, $t3, add_tail_segment_return_error  # If the new_tail slot is not an empty slot, return error
    
    addi $sp, $sp, -16 # Save all $t registers used in add_tail_segment
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    
    move $a0, $s0 # State
    move $a1, $s2 # new_tail_row
    move $a2, $s3 # new_tail_col
    move $a3, $s4 # new_tail
    
    jal set_slot # Add new_tail to the snake
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    addi $sp, $sp, 16 # Restore all $t registers
    
    lb $t0, 4($s0) # Load length
    addi $t0, $t0, 1 # Increment length
    sb $t0, 4($s0) # Store new length
    
    j add_tail_segment_return
    
    add_tail_right: # Add new tail to the column to the right
    
    li $t1, 0 # tail_row_delta
    li $t2, 1 # tail_col_delta
    add $s2, $s2, $t1 # new_tail_row
    add $s3, $s3, $t2 # new_tail_col
    
    move $a0, $s0 # state
    move $a1, $s2 # new_tail_row
    move $a2, $s3 # new_tail_col
    
    addi $sp, $sp, -12 # Save all $t registers used in add_tail_segment
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    
    jal get_slot # Get character at new_tail_row and new_tail_col
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    addi $sp, $sp, 12 # Restore all $t registers
    
    li $t0, 46 # '.'
    move $t3, $v0 # $t0 = character read at new_tail slot
    
    bne $t0, $t3, add_tail_segment_return_error  # If the new_tail slot is not an empty slot, return error
    
    addi $sp, $sp, -16 # Save all $t registers used in add_tail_segment
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    
    move $a0, $s0 # State
    move $a1, $s2 # new_tail_row
    move $a2, $s3 # new_tail_col
    move $a3, $s4 # new_tail
    
    jal set_slot # Add new_tail to the snake
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    addi $sp, $sp, 16 # Restore all $t registers
    
    lb $t0, 4($s0) # Load length
    addi $t0, $t0, 1 # Increment length
    sb $t0, 4($s0) # Store new length
    
    j add_tail_segment_return
    
    add_tail_segment_return_error:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp) # Restore all $s registers
    addi $sp, $sp, 24 # Deallocate stack
    
    li $v0, -1 # $v0 = -1 to indicate an error
    jr $ra # Return to caller
    
    add_tail_segment_return:
    lbu $t0, 4($s0)
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp) # Restore all $s registers
    addi $sp, $sp, 24 # Deallocate stack
    
    move $v0, $t0 # $v0 = new length
    jr $ra # Return to caller

increase_snake_length:
    # Call find_next_body_part iteratively: $a0 = state, $a1 = row, $a2 = col, $a3 = target_part
    # Length of the snake will serve as loop counter
    # If target_part == 57 (9), load 65 into the target_part
    # After each call, update row and col and value of target_part
    # Loop back until loop counter is 0
    
    # After the loop has ended, $v0 and $v1 contains the row and column coordinates of the tail.
    # Load tail_row_delta and tail_col_delta which indicate the opposite of the direction given.
    # Load new tail character by incrementing the tail character address. 
    # If tail == 57 (9), load 65 (A) as target_part
    # Call get_slot: $a0 = state, $a1 = row, $a2 = col
    # $v0 = character at the particular slot. 
    # If $v0 = 46, indicating an empty slot, add the new tail segment to that slot using add_tail_segment
    # Else repeat the same process by loading each direction, in a counterclockwise order, and checking that slot.
    # If no empty slot is found, return error indicating that there is no place for the tail to added.
    
    addi $sp, $sp, -20 # Allocate space on the stack
    sw $ra, 0($sp) # Store $ra in the stack
    sw $s0, 4($sp) # Save all $s registers used in increase_snake_length
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    
    move $s0, $a0 # State
    move $s1, $a1 # Direction
    
    lb $t0, 4($s0) # Length
    lb $t1, 2($s0) # head_row
    lb $t2, 3($s0) # head_col
    li $t3, 49 # head
    addi $t0, $t0, -1 # Length - 1 body segments left to find
    
    find_each_body_part:
    
    beqz $t0, initialize_find_new_tail_spot # If loop counter = 0, go to find_new_tail_spot
    li $t4, 57 # ASCII for 9
    beq $t3, $t4, load_letter # If $t3 == 9, load index before A (64)
    addi $t3, $t3, 1 # Load next body segment address
     
    addi $sp, $sp, -20 # Store all $t registers
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t4, 16($sp)
    
    move $a0, $s0 # state
    move $a1, $t1 # row
    move $a2, $t2 # col
    move $a3, $t3 # target_part
   
    jal find_next_body_part # Find coordinates of next body segment
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp)
    addi $sp, $sp, 20 # Restore all $t registers
    
    move $t1, $v0 # Row of next body segment
    move $t2, $v1 # Col of next body segment
    addi $t0, $t0, -1 # Decrement loop counter
    
    j find_each_body_part # Loop again
    
    load_letter: # Load index before A
    li $t3, 64
    j find_each_body_part
    
    initialize_find_new_tail_spot:
    move $s2, $t1 # tail_row
    move $s3, $t2 # tail_col
    
    li $t5, 0 # Find_new_tail_spot loop counter
    
    li $t0, 85 # U
    beq $s1, $t0, initialize_direction_down # If $s1 = 'U', initialize $s1 to 'D'
    li $t0, 68 # D
    beq $s1, $t0, initialize_direction_up # If $s1 = 'D', initialize $s1 to 'U'
    li $t0, 76 # L 
    beq $s1, $t0, initialize_direction_right # If $s1 = 'L', initialize $s1 to 'R'
    li $t0, 82 # R
    beq $s1, $t0, initialize_direction_left # If $s1 = 'R', initialize $s1 to 'L'
    
    j increase_snake_length_return_error
    
    initialize_direction_up:
    li $t0, 85 # U
    move $s1, $t0 # $s1 = U
    j find_new_tail_spot
    
    initialize_direction_down:
    li $t0, 68 # D
    move $s1, $t0 # $s1 = D
    j find_new_tail_spot
    
    initialize_direction_left:
    li $t0, 76 # L
    move $s1, $t0 # $s1 = L
    j find_new_tail_spot
    
    initialize_direction_right:
    li $t0, 82 # R
    move $s1, $t0 # $s1 = R
    j find_new_tail_spot
    
    find_new_tail_spot:
    li $t0, 4
    beq $t5, $t0, increase_snake_length_return_error
    li $t0, 85 # U
    beq $s1, $t0, search_slot_up
    li $t0, 68 # D
    beq $s1, $t0, search_slot_down
    li $t0, 76 # L
    beq $s1, $t0, search_slot_left
    li $t0, 82 # R
    beq $s1, $t0, search_slot_right
    
    j increase_snake_length_return_error
    search_slot_up:
    li $t0, -1 # tail_row_delta
    add $t1, $s2, $t0 # new_tail_row
    move $t2, $s3 # new_tail_col
    
    move $a0, $s0 # State
    move $a1, $t1 # new_tail_row
    move $a2, $t2 # new_tail_col
    
    addi $sp, $sp, -28 # Store all $t registers
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t4, 16($sp)
    sw $t5, 20($sp)
    sw $t6, 24($sp)
    
    jal get_slot # Get character at the new_tail coordinates
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp)
    lw $t5, 20($sp)
    lw $t6, 24($sp)
    addi $sp, $sp, 28 # Restore all $t registers
    
    li $t0, 46 # '.'
    move $t6, $v0 # Address of character found at new_tail slot
    
    beq $t0, $t6, add_new_tail # If empty slot found, add new tail at that positoin
    addi $t5, $t5, 1 # Increment loop counter
    li $s1, 76 # $s1 = L
    
    j find_new_tail_spot
    
    
    search_slot_down:
    li $t0, 1 # tail_row_delta
    add $t1, $s2, $t0 # new_tail_row
    move $t2, $s3 # new_tail_col
    
    move $a0, $s0 # State
    move $a1, $t1 # new_tail_row
    move $a2, $t2 # new_tail_col
    
    addi $sp, $sp, -28 # Store all $t registers
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t4, 16($sp)
    sw $t5, 20($sp)
    sw $t6, 24($sp)
    
    jal get_slot # Get character at the new_tail coordinates
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp)
    lw $t5, 20($sp)
    lw $t6, 24($sp)
    addi $sp, $sp, 28 # Restore all $t registers
    
    li $t0, 46 # '.'
    move $t6, $v0 # Address of character found at new_tail slot
    
    beq $t0, $t6, add_new_tail # If empty slot found, add new tail at that positoin
    addi $t5, $t5, 1 # Increment loop counter
    li $s1, 82 # $s1 = R
    
    j find_new_tail_spot
    
    search_slot_left:
    li $t0, -1 # tail_col_delta
    move $t1, $s2 # new_tail_row
    add $t2, $s3, $t0 # new_tail_col
    
    move $a0, $s0 # State
    move $a1, $t1 # new_tail_row
    move $a2, $t2 # new_tail_col
    
    addi $sp, $sp, -28 # Store all $t registers
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t4, 16($sp)
    sw $t5, 20($sp)
    sw $t6, 24($sp)
    
    jal get_slot # Get character at the new_tail coordinates
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp)
    lw $t5, 20($sp)
    lw $t6, 24($sp)
    addi $sp, $sp, 28 # Restore all $t registers
    
    li $t0, 46 # '.'
    move $t6, $v0 # Address of character found at new_tail slot
    
    beq $t0, $t6, add_new_tail # If empty slot found, add new tail at that positoin
    addi $t5, $t5, 1 # Increment loop counter
    li $s1, 68 # $s1 = D
    
    j find_new_tail_spot
    
    search_slot_right: 
    li $t0, 1 # tail_col_delta
    move $t1, $s2 # new_tail_row
    add $t2, $s3, $t0 # new_tail_col
    
    move $a0, $s0 # State
    move $a1, $t1 # new_tail_row
    move $a2, $t2 # new_tail_col
    
    addi $sp, $sp, -28 # Store all $t registers
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t4, 16($sp)
    sw $t5, 20($sp)
    sw $t6, 24($sp)
    
    jal get_slot # Get character at the new_tail coordinates
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp)
    lw $t5, 20($sp)
    lw $t6, 24($sp)
    addi $sp, $sp, 28 # Restore all $t registers
    
    li $t0, 46 # '.'
    move $t6, $v0 # Address of character found at new_tail slot
    
    beq $t0, $t6, add_new_tail # If empty slot found, add new tail at that positoin
    addi $t5, $t5, 1 # Increment loop counter
    li $s1, 85 # $s1 = U
    
    j find_new_tail_spot 
    
    add_new_tail:
    
    move $a0, $s0 # State
    move $a1, $s1 # direction
    move $a2, $s2 # tail_row
    move $a3, $s3 # tail_col
    
    addi $sp, $sp, -28 # Store all $t registers
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t4, 16($sp)
    sw $t5, 20($sp)
    sw $t6, 24($sp)
    
    jal add_tail_segment # Add new tail segment
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp)
    lw $t5, 20($sp)
    lw $t6, 24($sp)
    addi $sp, $sp, 28 # Restore all $t registers
    
    move $t0, $v0 # $t0 = new length of snake
    bltz $t0, increase_snake_length_return_error # If $t0 < 0, an error occured and operation was aborted
    j increase_snake_length_return # Else, new tail was successfully added, return to caller with new length of snake
    
    
    increase_snake_length_return_error:
    lw $ra, 0($sp) # Restore $ra in the stack
    lw $s0, 4($sp) # Restore all $s registers used in increase_snake_length
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    li $v0, -1 # $v0 = -1 to indicate an error
    jr $ra # Return to caller
    increase_snake_length_return:
    
    lw $ra, 0($sp) # Restore $ra in the stack
    lw $s0, 4($sp) # Restore all $s registers used in increase_snake_length
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    move $v0, $t0 # $v0 = updated state.length
    jr $ra # Return to caller

move_snake:
    addi $sp, $sp, -20 # Save all $s registers used in move_snake
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    
    move $s0, $a0 # State
    move $s1, $a1 # Direction
    move $s2, $a2 # apples
    move $s3, $a3 # apples_length
    
    li $t0, 85 # U
    beq $s1, $t0, initialize_up
    li $t0, 68 # D
    beq $s1, $t0, initialize_down
    li $t0, 76 # L
    beq $s1, $t0, initialize_left
    li $t0, 82 # R
    beq $s1, $t0, initialize_right
    
    j move_snake_return_error # Direction is invalid, return with error
    
    initialize_up:
    li $t1, -1 # head_row_delta
    li $t2, 0 # head_col_delta
    j slide_body_in_direction
    
    initialize_down:
    li $t1, 1 # head_row_delta
    li $t2, 0 # head_col_delta
    j slide_body_in_direction
    
    initialize_left:
    li $t1, 0 # head_row_delta
    li $t2, -1 # head_col_delta
    j slide_body_in_direction
    
    initialize_right:
    li $t1, 0 # head_row_delta
    li $t2, 1 # head_col_delta
    j slide_body_in_direction
    
    slide_body_in_direction:
    
    move $a0, $s0 # state
    move $a1, $t1 # head_row_delta
    move $a2, $t2 # head_col_delta
    move $a3, $s2 # apples
    move $t0, $s3 # apples_length
    addi $sp, $sp, -12 # Save all $t registers
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    
    jal slide_body # Move snake in specified direction
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    addi $sp, $sp, 12 # Restore all $t registers
    
    move $t0, $v0 # $t0 = indicator of what action to place. 0 = moved onto empty slot, 1 = apple eaten, -1 = error
    bltz $t0, move_snake_return_error # if $t0 < 0, return error
    bgtz $t0, snake_ate_apple # if $t0 > 0, jump to snake_ate_apple
    li $t1, 0 # Else, the snake moved onto an empty slot. Thus return (0,1). $t1 = 0
    li $t2, 1 # $t2 = 1
    j move_snake_return # Return to caller
    
    snake_ate_apple:
    
    move $a0, $s0 # State
    move $a1, $s1 # Direction
    
    addi $sp, $sp, -12 # Save all $t registers
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    
    jal increase_snake_length # Increase snake length 
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    addi $sp, $sp, 12 # Restore all $t registers
    
    move $t0, $v0 # $t0 = length of snake 
    beqz $t0, move_snake_return_error # if $t0 < 0, return error
    li $t1, 100 # Else, move was successful so $t1 = 100, indicating 100 pointers were scored
    li $t2, 1 # $t2 = 1
    j move_snake_return
    
    move_snake_return_error:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20 # Restore $s registers
    
    li $v0, 0 # $v0 = 0
    li $v1, -1 # $v1 = -1
    jr $ra # Return to caller
    move_snake_return:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20 # Restore $s registers
    
    move $v0, $t1 # $v0 = $t1
    move $v1, $t2 # $v1 = $t2
    jr $ra # Return to caller

simulate_game:
    lw $s4, 0($sp) # $s4 = apples
    lw $s5, 4($sp) # $s5 = apples_length
    
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    move $s0, $a0 # $s0 = state
    move $s1, $a1 # $s1 = filename
    move $s2, $a2 # $s2 = directions
    move $s3, $a3 # $s3 = num_moves_to_execute
    
    li $s6, 0 # Number of moves executed counter
    li $s7, 0 # Total score counter
    
    move $a0, $s0 # state
    move $a1, $s1 # filename
    
    jal load_game # Load game
     
    move $t0, $v0 # $t0 = file status
    bltz $t0, simulate_game_return_error # if $t0 < 0, file DNE: return error
    beqz $t0, spawn_apple # if $t0 = 0, no apples were found: spawn apple
    j start_game # Else, start simulating game
 
    spawn_apple:
    move $a0, $s0 # state
    move $a1, $s4 # apples
    move $a2, $s5 # apples_length
    
    addi $sp, $sp, -4 # Save all $t registers
    sw $t0, 0($sp)
    
    jal place_next_apple # Spawn an apple on the grid
    
    lw $t0, 0($sp)
    addi $sp, $sp, 4 # Restore all $t registers
    
    move $t0, $v0 
    bltz $t0, simulate_game_return_error
    move $t0, $v1
    bltz $t0, simulate_game_return_error
   
    start_game: # Simulate the game
    beq $s6, $s3, simulate_game_return # if num_moves_executed == num_moves_to_execute: return to caller
    
    
    li $t0, 35 # Max length of snake
    lbu $t1, 4($s0) # Length of snake
    beq $t0, $t1, simulate_game_return # If length of snake = max length of snake: return to caller
    
    
    lbu $t0, 0($s2) # Load direction
    addi $s2, $s2, 1 # Load next direction character address
    
    beqz $t0, simulate_game_return # if t0 = null: return to caller since out of directions
    
    
    move $a0, $s0 # $a0 = state
    move $a1, $t0 # $a1 = direction
    move $a2, $s4 # $a2 = apples
    move $a3, $s5 # $a3 = apples_length
    
    addi $sp, $sp, -8 # Save all $t registers
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    
    jal move_snake # Move the snake
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    addi $sp, $sp, 8 # Restore all $t registers
    
    move $t0, $v1 # $t0 = indicator of where move was successful or not
    bltz $t0, simulate_game_return # if $t0 < 0, move was unsuccessful: break loop and return result
    
    addi $s6, $s6, 1 # increment num_moves_executed
    move $t0, $v0 # $t0 = points scored
    beqz $t0, start_game # if $t0 = 0, loop again
    
    lbu $t1, 4($s0) # Load new state.length
    addi $t1, $t1, -1 # state.length = state.length - 1
    mul $t2, $t0, $t1 # calculated_score = score * (state.length - 1)
    
    add $s7, $s7, $t2 # total_score = total_score + calculated_score
    
    j start_game # loop again
    
    simulate_game_return_error:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    li $v0, -1
    li $v1, -1
    jr $ra
    
    simulate_game_return:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    move $v0, $s6 # number of moves executed
    move $v1, $s7 # total points scored
    jr $ra

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
