.data
    MAX_DIGITS_SUPPORTED: .word 5
    MIN_DIGITS_GAME:      .word 3
    DEFAULT_DIGITS:       .word 4
    DEFAULT_ATTEMPTS:     .word 10
    TRUE:                 .word 1
    FALSE:                .word 0

    current_num_digits:   .word 4
    current_max_attempts: .word 10
    allow_duplicates_in_secret: .word 0
    zen_mode_active:      .word 0
    
    secret_digits:      .space 20
    guess_digits:       .space 20
    temp_digits_parsing:.space 20
    
    secret_digit_bull_marked: .space 20
    guess_digit_bull_marked:  .space 20
    secret_digit_cow_marked:  .space 20

    powers_of_10:       .word 1, 10, 100, 1000, 10000, 100000

    str_newline:            .asciiz "\n"
    str_separator:          .asciiz "----------------------------------------\n"
    str_welcome:            .asciiz "Bulls and Cows - MIPS Edition\n"
    str_main_menu_title:    .asciiz "\nMain Menu:\n"
    str_main_menu_1:        .asciiz "1. Play Game\n"
    str_main_menu_2:        .asciiz "2. Exit\n"
    str_main_menu_prompt:   .asciiz "Enter your choice (1-2): "
    str_invalid_choice:     .asciiz "Invalid choice. Please try again.\n"
    
    str_prompt_num_digits:  .asciiz "Enter number of digits (3-5): "
    str_prompt_max_attempts:.asciiz "Enter max attempts (e.g., 10, or 0 for Zen Mode): "
    str_prompt_allow_duplicates: .asciiz "Allow duplicate digits in secret? (1=Yes, 0=No): "
    str_invalid_setting:    .asciiz "Invalid setting. Please try again.\n"

    str_generating_secret:  .asciiz "Generating secret number...\n"
    str_attempt_prefix:     .asciiz "\nAttempt "
    str_attempt_infix:      .asciiz "/"
    str_attempt_zen_suffix: .asciiz " (Zen Mode): "
    str_attempt_suffix:     .asciiz ": "
    str_prompt_guess_part1: .asciiz "Enter your "
    str_prompt_guess_part2: .asciiz "-digit guess: "
    str_feedback_bulls:     .asciiz "Bulls: "
    str_feedback_cows:      .asciiz ", Cows: "
    
    str_win_msg_1:          .asciiz "Congratulations! You guessed the number: "
    str_lose_msg_1:         .asciiz "Game Over! You ran out of attempts.\nThe secret number was: "
    str_error_guess_format: .asciiz "Error: Invalid guess format or range.\n"
    str_error_guess_duplicates: .asciiz "Error: Guess must contain unique digits for this game setting.\n"

.text
.globl main

main:
    lw $t0, DEFAULT_DIGITS
    sw $t0, current_num_digits
    lw $t0, DEFAULT_ATTEMPTS
    sw $t0, current_max_attempts
    sw $zero, allow_duplicates_in_secret
    sw $zero, zen_mode_active

main_menu_loop:
    li $v0, 4
    la $a0, str_welcome
    syscall
    la $a0, str_separator
    syscall
    la $a0, str_main_menu_title
    syscall
    la $a0, str_main_menu_1
    syscall
    la $a0, str_main_menu_2
    syscall
    la $a0, str_main_menu_prompt
    syscall
    li $v0, 5
    syscall
    move $t0, $v0

    beq $t0, 1, case_play_game
    beq $t0, 2, exit_program_main

    li $v0, 4
    la $a0, str_invalid_choice
    syscall
    j main_menu_loop

case_play_game:
    jal setup_game_difficulty
    jal run_game_loop_main
    j main_menu_loop

exit_program_main:
    li $v0, 10
    syscall

setup_game_difficulty:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

get_num_digits_config_loop:
    li $v0, 4
    la $a0, str_prompt_num_digits
    syscall
    li $v0, 5
    syscall
    move $t0, $v0
    lw $t1, MIN_DIGITS_GAME
    lw $t2, MAX_DIGITS_SUPPORTED
    blt $t0, $t1, invalid_num_digits_config
    bgt $t0, $t2, invalid_num_digits_config
    sw $t0, current_num_digits
    j get_max_attempts_config_loop
invalid_num_digits_config:
    li $v0, 4
    la $a0, str_invalid_setting
    syscall
    j get_num_digits_config_loop

get_max_attempts_config_loop:
    li $v0, 4
    la $a0, str_prompt_max_attempts
    syscall
    li $v0, 5
    syscall
    move $t0, $v0
    bltz $t0, invalid_max_attempts_config
    sw $t0, current_max_attempts
    beq $t0, $zero, set_zen_mode_true_config
    sw $zero, zen_mode_active
    j get_allow_duplicates_config_loop
set_zen_mode_true_config:
    lw $t1, TRUE
    sw $t1, zen_mode_active
    j get_allow_duplicates_config_loop
invalid_max_attempts_config:
    li $v0, 4
    la $a0, str_invalid_setting
    syscall
    j get_max_attempts_config_loop

get_allow_duplicates_config_loop:
    li $v0, 4
    la $a0, str_prompt_allow_duplicates
    syscall
    li $v0, 5
    syscall
    move $t0, $v0
    beq $t0, $zero, store_allow_duplicates_config
    lw $t1, TRUE # Compare with 1 explicitly
    beq $t0, $t1, store_allow_duplicates_config # Changed from beq $t0, 1
    li $v0, 4
    la $a0, str_invalid_setting
    syscall
    j get_allow_duplicates_config_loop
store_allow_duplicates_config:
    sw $t0, allow_duplicates_in_secret

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

run_game_loop_main:
    addi $sp, $sp, -28
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    sw $s5, 24($sp)

    lw $s0, current_num_digits
    lw $s1, current_max_attempts
    lw $s2, allow_duplicates_in_secret
    lw $s3, zen_mode_active
    li $s4, 0

    li $v0, 4
    la $a0, str_generating_secret
    syscall
    move $a0, $s0
    move $a1, $s2
    jal generate_secret_number_internal

game_turn_loop:
    li $v0, 4
    la $a0, str_attempt_prefix
    syscall
    li $v0, 1
    addi $a0, $s4, 1
    syscall
    
    lw $t0, TRUE
    beq $s3, $t0, print_zen_suffix_and_continue # If zen_mode_active, branch
    
    # Not Zen Mode Path
    li $v0, 4
    la $a0, str_attempt_infix
    syscall
    li $v0, 1
    move $a0, $s1 # This is where $s1 (max_attempts) is used
    syscall
    li $v0, 4 # Explicitly load 4 for print_string
    la $a0, str_attempt_suffix
    syscall
    j prompt_for_guess_turn

print_zen_suffix_and_continue:
    li $v0, 4
    la $a0, str_attempt_zen_suffix
    syscall
    # Fall through to prompt_for_guess_turn is intended.

prompt_for_guess_turn:
    lw $t0, TRUE
    bne $s3, $t0, check_attempt_limit_turn # If not zen, check limit
    j attempt_limit_ok_turn                # If zen, skip check
check_attempt_limit_turn:
    beq $s4, $s1, game_over_lose_internal  # Compare current attempts ($s4) with max ($s1)
attempt_limit_ok_turn:
    addi $s4, $s4, 1 # Increment current attempt count for this turn

    move $a0, $s0
    move $a1, $s2
    jal get_player_guess_internal

    la $a0, secret_digits
    la $a1, guess_digits
    move $a2, $s0
    move $a3, $s2
    jal calculate_bulls_cows_enhanced_internal
    move $s5, $v0 # bulls

    li $v0, 4
    la $a0, str_feedback_bulls
    syscall
    li $v0, 1
    move $a0, $s5
    syscall
    li $v0, 4 # Explicitly load 4 for print_string
    la $a0, str_feedback_cows
    syscall
    li $v0, 1
    move $a0, $v1 # cows
    syscall
    li $v0, 4 # Explicitly load 4 for print_string
    la $a0, str_newline
    syscall

    beq $s5, $s0, game_over_win_internal # if bulls == num_digits
    j game_turn_loop

game_over_win_internal:
    li $v0, 4
    la $a0, str_win_msg_1
    syscall
    move $a0, $s0
    la $a1, guess_digits # On win, guess_digits == secret_digits
    jal print_digit_array_internal
    j game_end_cleanup_internal

game_over_lose_internal:
    li $v0, 4
    la $a0, str_lose_msg_1
    syscall
    move $a0, $s0
    la $a1, secret_digits
    jal print_digit_array_internal
    j game_end_cleanup_internal

game_end_cleanup_internal:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    lw $s5, 24($sp)
    addi $sp, $sp, 28
    jr $ra

generate_secret_number_internal:
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)

    move $s0, $a0 # local s0 = num_digits from arg $a0
    move $s1, $a1 # local s1 = allow_duplicates from arg $a1
    la $t5, secret_digits
    li $s2, 0     # digit_idx

gen_digit_loop_internal:
    beq $s2, $s0, gen_done_internal # if digit_idx == num_digits

    li $v0, 42    # random int
    li $a0, 0     # rng id (unused by MARS)
    li $a1, 10    # upper bound exclusive (0-9)
    syscall
    move $s3, $a0 # s3 = random_digit

    lw $t0, TRUE
    beq $s1, $t0, store_this_digit_internal # if allow_duplicates is TRUE, skip uniqueness check
    
    # Check uniqueness
    li $t0, 0 # inner loop counter i
check_unique_loop_internal:
    beq $t0, $s2, store_this_digit_internal # if i == current digit_idx, unique so far

    mul $t1, $t0, 4     # offset = i * 4
    addu $t2, $t5, $t1  # address = secret_digits_base + offset
    lw $t3, 0($t2)      # value of secret_digits[i]
    beq $t3, $s3, gen_digit_loop_internal # if secret_digits[i] == random_digit, try new random

    addi $t0, $t0, 1
    j check_unique_loop_internal

store_this_digit_internal:
    mul $t1, $s2, 4     # offset = digit_idx * 4
    addu $t2, $t5, $t1  # address = secret_digits_base + offset
    sw $s3, 0($t2)      # secret_digits[digit_idx] = random_digit

    addi $s2, $s2, 1    # next digit_idx
    j gen_digit_loop_internal

gen_done_internal:
    lw $ra, 0($sp)
    lw $s0, 4($sp) # Restore caller's s0
    lw $s1, 8($sp) # Restore caller's s1
    lw $s2, 12($sp)# Restore caller's s2
    lw $s3, 16($sp)# Restore caller's s3
    addi $sp, $sp, 20
    jr $ra

get_player_guess_internal:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)  # num_digits from arg $a0
    sw $s1, 8($sp)  # allow_duplicates_rule from arg $a1
    sw $s2, 12($sp) # player_input_int
    sw $s3, 16($sp) # temp_digits_parsing base
    sw $s4, 20($sp) # digit_count / loop counter

    move $s0, $a0
    move $s1, $a1

get_guess_input_loop_internal:
    li $v0, 4
    la $a0, str_prompt_guess_part1
    syscall
    li $v0, 1
    move $a0, $s0 # Print num_digits
    syscall
    li $v0, 4
    la $a0, str_prompt_guess_part2
    syscall
    li $v0, 5 # Read integer
    syscall
    move $s2, $v0 # player_input_int

    # Validate approx range for N digits
    la $t0, powers_of_10
    mul $t1, $s0, 4     # offset for 10^N
    addu $t0, $t0, $t1
    lw $t2, 0($t0)      # t2 = 10^N
    bltz $s2, invalid_guess_input_format_internal # if input < 0
    bge $s2, $t2, invalid_guess_input_format_internal # if input >= 10^N
    
parse_guess_digits_internal:
    la $s3, temp_digits_parsing
    move $t0, $s2 # number to parse
    li $s4, 0     # digit_count

parse_digit_loop_internal:
    # This loop extracts digits. If N=4 and input is 23, it extracts 3 then 2. s4 becomes 2.
    # It needs to ensure N digits are produced for guess_digits, padding with leading zeros if necessary.
    # The current loop will stop once $t0 (number to parse) becomes 0.
    beq $t0, $zero, check_parsed_digit_count # If number is 0, all significant digits parsed
    beq $s4, $s0, check_parsed_digit_count   # Or if we've already got N digits (e.g. input 12345 for N=4) - handled by range check mostly

    rem $t1, $t0, 10 # digit = number % 10
    div $t0, $t0, 10 # number = number / 10
    
    mul $t2, $s4, 4
    addu $t3, $s3, $t2
    sw $t1, 0($t3)   # temp_digits_parsing[s4] = digit (stores LSB first)
    
    addi $s4, $s4, 1 # increment digit_count
    j parse_digit_loop_internal

check_parsed_digit_count:
    blt $s4, $s0, pad_leading_zeros_internal # If fewer than N digits were extracted (e.g. input "23" for N=4)
    # If $s4 > $s0, means input was like "12345" for N=4, but range check should catch this.
    # If $s4 == $s0, exactly N digits were extracted.
    j copy_parsed_guess_internal

pad_leading_zeros_internal: # Pad remaining slots in temp_digits_parsing with 0
    beq $s4, $s0, copy_parsed_guess_internal
    mul $t2, $s4, 4
    addu $t3, $s3, $t2
    sw $zero, 0($t3) # temp_digits_parsing[s4] = 0
    addi $s4, $s4, 1
    j pad_leading_zeros_internal

copy_parsed_guess_internal:
    la $t5, guess_digits
    li $t0, 0 # Index for guess_digits (i)
copy_parsed_loop_internal:
    beq $t0, $s0, copy_parsed_done_internal_guess
    
    sub $t1, $s0, $t0   # num_digits - i
    addi $t1, $t1, -1   # num_digits - 1 - i (index for reversed temp_digits_parsing)
    mul $t2, $t1, 4
    addu $t3, $s3, $t2  # address of temp_digits_parsing[num_digits-1-i]
    lw $t4, 0($t3)      # digit_value

    mul $t2, $t0, 4     # offset for guess_digits
    addu $t6, $t5, $t2  # address of guess_digits[i]
    sw $t4, 0($t6)      # guess_digits[i] = digit_value
    
    addi $t0, $t0, 1
    j copy_parsed_loop_internal
copy_parsed_done_internal_guess:

    lw $t7, TRUE
    beq $s1, $t7, guess_input_valid_internal # if allow_duplicates is TRUE, skip uniqueness check

    # Check uniqueness for guess_digits
    la $a0, guess_digits
    move $a1, $s0 # num_digits
    jal check_array_uniqueness_internal_proc
    lw $t7, TRUE
    beq $v0, $t7, guess_input_valid_internal # if unique, valid
    
    # Not unique, print error and retry
    li $v0, 4
    la $a0, str_error_guess_duplicates
    syscall
    j get_guess_input_loop_internal

invalid_guess_input_format_internal:
    li $v0, 4
    la $a0, str_error_guess_format
    syscall
    j get_guess_input_loop_internal

guess_input_valid_internal:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra

check_array_uniqueness_internal_proc:
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp) # array_base from arg $a0
    sw $s1, 8($sp) # num_elements from arg $a1
    sw $s2, 12($sp)# outer loop index i
    sw $s3, 16($sp)# digit_i

    move $s0, $a0
    move $s1, $a1
    li $s2, 0 # i = 0
outer_unique_check_loop:
    addi $t0, $s1, -1 # if i == num_elements - 1, outer loop done
    beq $s2, $t0, array_is_unique 
    
    mul $t1, $s2, 4
    addu $t2, $s0, $t1
    lw $s3, 0($t2) # s3 = array[i]

    addi $t3, $s2, 1 # j = i + 1
inner_unique_check_loop:
    beq $t3, $s1, next_outer_unique_check # if j == num_elements, inner loop done
    
    mul $t1, $t3, 4
    addu $t2, $s0, $t1
    lw $t4, 0($t2) # t4 = array[j]
    
    beq $s3, $t4, array_not_unique # if array[i] == array[j], not unique
    
    addi $t3, $t3, 1
    j inner_unique_check_loop

next_outer_unique_check:
    addi $s2, $s2, 1
    j outer_unique_check_loop

array_not_unique:
    lw $t0, FALSE
    move $v0, $t0 # Return 0 (false)
    j unique_check_done
array_is_unique:
    lw $t0, TRUE
    move $v0, $t0 # Return 1 (true)
unique_check_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra

calculate_bulls_cows_enhanced_internal:
    addi $sp, $sp, -32
    sw $ra, 0($sp)
    sw $s0, 4($sp)   # secret_base
    sw $s1, 8($sp)   # guess_base
    sw $s2, 12($sp)  # num_digits
    sw $s3, 16($sp)  # allow_duplicates
    sw $s4, 20($sp)  # bulls_count
    sw $s5, 24($sp)  # cows_count
    sw $s6, 28($sp)  # base for secret_digit_bull_marked

    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
    li $s4, 0 # bulls_count = 0
    li $s5, 0 # cows_count = 0

    la $s6, secret_digit_bull_marked
    la $t0, guess_digit_bull_marked
    la $t1, secret_digit_cow_marked

    li $t2, 0 # index i
init_markers_loop_calc:
    beq $t2, $s2, markers_initialized_calc # if i == num_digits
    mul $t3, $t2, 4 # offset = i * 4
    
    addu $t4, $s6, $t3  # addr of secret_digit_bull_marked[i]
    sw $zero, 0($t4)    # secret_digit_bull_marked[i] = 0
    addu $t4, $t0, $t3  # addr of guess_digit_bull_marked[i]
    sw $zero, 0($t4)    # guess_digit_bull_marked[i] = 0
    addu $t4, $t1, $t3  # addr of secret_digit_cow_marked[i]
    sw $zero, 0($t4)    # secret_digit_cow_marked[i] = 0

    addi $t2, $t2, 1
    j init_markers_loop_calc
markers_initialized_calc:

    li $t2, 0 # index i
calc_bulls_loop_internal:
    beq $t2, $s2, bulls_done_calc # If i == num_digits

    mul $t3, $t2, 4         # offset = i * 4
    addu $t4, $s0, $t3      # address of secret[i]
    lw $t5, 0($t4)          # secret_digit = secret[i]
    addu $t4, $s1, $t3      # address of guess[i]
    lw $t6, 0($t4)          # guess_digit = guess[i]

    bne $t5, $t6, next_bull_check_calc # If secret_digit != guess_digit

    addi $s4, $s4, 1        # bulls_count++
    lw $t7, TRUE            # 1 (true)
    addu $t4, $s6, $t3      # addr of secret_digit_bull_marked[i]
    sw $t7, 0($t4)          # secret_digit_bull_marked[i] = 1
    addu $t4, $t0, $t3      # addr of guess_digit_bull_marked[i]
    sw $t7, 0($t4)          # guess_digit_bull_marked[i] = 1

next_bull_check_calc:
    addi $t2, $t2, 1        # i++
    j calc_bulls_loop_internal
bulls_done_calc:

    li $t2, 0 # outer loop index i (for guess_digits)
calc_cows_outer_loop_internal:
    beq $t2, $s2, cows_done_calc # If i == num_digits

    mul $t3, $t2, 4         # offset_i = i * 4
    addu $t4, $t0, $t3      # addr of guess_digit_bull_marked[i]
    lw $t5, 0($t4)          # guess_digit_bull_marked[i]
    lw $t7, TRUE
    beq $t5, $t7, next_cows_outer_digit_calc # If true, this guess digit was a bull

    addu $t4, $s1, $t3      # address of guess[i]
    lw $t6, 0($t4)          # current_guess_digit = guess[i]

    li $t8, 0 # inner loop index j (for secret_digits)
calc_cows_inner_loop_internal:
    beq $t8, $s2, next_cows_outer_digit_calc # If j == num_digits

    mul $t9, $t8, 4         # offset_j = j * 4

    addu $a0, $s6, $t9      # addr of secret_digit_bull_marked[j]
    lw $a1, 0($a0)          # secret_digit_bull_marked[j]
    lw $t7, TRUE
    beq $a1, $t7, next_cows_inner_digit_calc # If true, this secret digit was a bull

    addu $a0, $t1, $t9      # addr of secret_digit_cow_marked[j]
    lw $a1, 0($a0)          # secret_digit_cow_marked[j]
    lw $t7, TRUE
    beq $a1, $t7, next_cows_inner_digit_calc # If true, this secret digit already formed a cow

    addu $a0, $s0, $t9      # address of secret[j]
    lw $a2, 0($a0)          # current_secret_digit = secret[j]

    bne $t6, $a2, next_cows_inner_digit_calc # If guess_digit != secret_digit

    addi $s5, $s5, 1        # cows_count++
    lw $t7, TRUE
    addu $a0, $t1, $t9      # addr of secret_digit_cow_marked[j]
    sw $t7, 0($a0)          # secret_digit_cow_marked[j] = 1
    j next_cows_outer_digit_calc # Found cow for guess_digit[i], move to next guess_digit

next_cows_inner_digit_calc:
    addi $t8, $t8, 1        # j++
    j calc_cows_inner_loop_internal

next_cows_outer_digit_calc:
    addi $t2, $t2, 1        # i++
    j calc_cows_outer_loop_internal
cows_done_calc:

    move $v0, $s4 # return bulls
    move $v1, $s5 # return cows

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    lw $s5, 24($sp)
    lw $s6, 28($sp)
    addi $sp, $sp, 32
    jr $ra

print_digit_array_internal:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp) # num_digits
    sw $s1, 8($sp) # array_base
    
    move $s0, $a0 
    move $s1, $a1 
    li $t0, 0 # index i

print_digit_loop_internal:
    beq $t0, $s0, print_digit_done_internal # if i == num_digits
    mul $t1, $t0, 4         # offset = i * 4
    addu $t2, $s1, $t1      # address = array_base + offset
    lw $a0, 0($t2)          # $a0 = array[i]
    li $v0, 1               # print integer
    syscall
    addi $t0, $t0, 1        # i++
    j print_digit_loop_internal

print_digit_done_internal:
    li $v0, 4
    la $a0, str_newline
    syscall
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra
