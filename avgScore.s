.data 

orig: .space 100	# In terms of bytes (25 elements * 4 bytes each)
sorted: .space 100

str0: .asciiz "Enter the number of assignments (between 1 and 25): "
str1: .asciiz "Enter score: "
str2: .asciiz "Original scores: "
str3: .asciiz "Sorted scores (in descending order): "
str4: .asciiz "Enter the number of (lowest) scores to drop: "
str5: .asciiz "Average (rounded down) with dropped scores removed: "
space: .asciiz " "
new_line: .asciiz "\n"
str_all: .asciiz "All scores dropped!"

.text 

# This is the main program.
# It first asks user to enter the number of assignments.
# It then asks user to input the scores, one at a time.
# It then calls selSort to perform selection sort.
# It then calls printArray twice to print out contents of the original and sorted scores.
# It then asks user to enter the number of (lowest) scores to drop.
# It then calls calcSum on the sorted array with the adjusted length (to account for dropped scores).
# It then prints out average score with the specified number of (lowest) scores dropped from the calculation.
main: 
	addi $sp, $sp -4
	sw $ra, 0($sp)
user_prompt:
	la $a0, str0 
	li $v0, 4 
	syscall 
	li $v0, 5	# Read the number of scores from user
	syscall
	# Your code here to handle invalid number of scores (can't be less than 1 or greater than 25)

	li $t0,1
	slt $t1, $v0, $t0
	bne $t1, $zero, user_prompt

	li $t0,25
	slt $t1, $t0, $v0
	bne $t1,$zero,user_prompt

	
	move $s0, $v0	# $s0 = numScores
	move $t0, $0
	la $s1, orig	# $s1 = orig
	la $s2, sorted	# $s2 = sorted
loop_in:
	li $v0, 4 
	la $a0, str1 
	syscall 
	sll $t1, $t0, 2
	add $t1, $t1, $s1
	li $v0, 5	# Read elements from user
	syscall
	sw $v0, 0($t1)
	addi $t0, $t0, 1
	bne $t0, $s0, loop_in
	
	move $a0, $s0
	jal selSort	# Call selSort to perform selection sort in original array
	
	li $v0, 4 
	la $a0, str2 
	syscall
	move $a0, $s1	# More efficient than la $a0, orig
	move $a1, $s0
	jal printArray	# Print original scores
	li $v0, 4 
	la $a0, str3 
	syscall 
	move $a0, $s2	# More efficient than la $a0, sorted
	jal printArray	# Print sorted scores

valid_prompt:
	li $v0, 4 
	la $a0, str4 
	syscall 
	li $v0, 5	# Read the number of (lowest) scores to drop
	syscall
	# Your code here to handle invalid number of (lowest) scores to drop (can't be less than 0, or 
	# greater than the number of scores). Also, handle the case when number of (lowest) scores to drop 
	# equals the number of scores. 
	
	slt $t0,$v0,$zero
	bne $t0, $zero, valid_prompt
	slt $t0, $s0, $v0
	bne $t0, $zero, valid_prompt
	beq $v0,$s0,equalScore
	
	
	move $a1, $v0
	sub $a1, $s0, $a1	# numScores - drop
	addi $sp, $sp, -4
	sw $a1, 0($sp)		# Save remaining count for average calculation
	move $a0, $s2
	jal calcSum	# Call calcSum to RECURSIVELY compute the sum of scores that are not dropped
	
	# Your code here to compute average and print it (you may also end up having some code here to help 
	# handle the case when number of (lowest) scores to drop equals the number of scores
	lw $t0, 0($sp)
	addi $sp, $sp, 4
	div $v0, $t0
	mflo $t1
	li $v0, 4
	la $a0, str5
	syscall
	li $v0, 1
	move $a0, $t1
	syscall
	beq $zero, $zero, end
	
equalScore:
	li $v0,4
    	la $a0,str_all    
   	syscall
    	j end
    
end:	lw $ra, 0($sp)
	addi $sp, $sp 4
	li $v0, 10 
	syscall
	
	
# printList takes in an array and its size as arguments. 
# It prints all the elements in one line with a newline at the end.
printArray:
	# Your implementation of printList here	
	move $t0,$a0
	li $t1, 0
	move $t2, $a1

printing_loop:
	bge $t1,$t2,post_print
	lw $a0 0($t0)
	li $v0, 1
	syscall

	la $a0, space
	li $v0, 4
	syscall
	addi $t0, $t0, 4
	addi $t1, $t1, 1
	j printing_loop



post_print:
	la $a0, new_line
	li $v0, 4
	syscall

	jr $ra
	
	
# selSort takes in the number of scores as argument. 
# It performs SELECTION sort in descending order and populates the sorted array
selSort:
	# Your implementation of selSort here
	la $t0, orig		# $t0 = base address of orig
	la $t1, sorted		# $t1 = base address of sorted
	addi $t2, $zero, 0	# $t2 = i

copy_loop:
	slt $t3, $t2, $a0	# while (i < len)
	beq $t3, $zero, sort_setup
	sll $t4, $t2, 2
	add $t5, $t0, $t4
	lw $t6, 0($t5)
	add $t7, $t1, $t4
	sw $t6, 0($t7)
	addi $t2, $t2, 1
	j copy_loop

sort_setup:
	slti $t3, $a0, 2	# Arrays of size 0 or 1 are already sorted
	bne $t3, $zero, sel_done
	addi $t2, $zero, 0	# i = 0

outer_loop:
	addi $t3, $a0, -1
	slt $t4, $t2, $t3	# while (i < len - 1)
	beq $t4, $zero, sel_done
	add $t5, $t2, $zero	# maxIndex = i
	addi $t6, $t2, 1	# j = i + 1

inner_loop:
	slt $t3, $t6, $a0	# while (j < len)
	beq $t3, $zero, do_swap
	sll $t4, $t6, 2
	add $t7, $t1, $t4
	lw $t8, 0($t7)		# sorted[j]
	sll $t4, $t5, 2
	add $t9, $t1, $t4
	lw $t3, 0($t9)		# sorted[maxIndex]
	slt $t4, $t3, $t8	# if sorted[maxIndex] < sorted[j]
	bne $t4, $zero, update_max
	j next_j

update_max:
	add $t5, $t6, $zero	# maxIndex = j

next_j:
	addi $t6, $t6, 1
	j inner_loop

do_swap:
	beq $t5, $t2, next_i	# No swap needed if maxIndex == i
	sll $t4, $t2, 2
	add $t7, $t1, $t4
	lw $t8, 0($t7)		# temp = sorted[i]
	sll $t4, $t5, 2
	add $t9, $t1, $t4
	lw $t3, 0($t9)		# sorted[maxIndex]
	sw $t3, 0($t7)
	sw $t8, 0($t9)

next_i:
	addi $t2, $t2, 1
	j outer_loop
	
sel_done:
	jr $ra
	
	
# calcSum takes in an array and its size as arguments.
# It RECURSIVELY computes and returns the sum of elements in the array.
# Note: you MUST NOT use iterative approach in this function.
calcSum:
	# Your implementation of calcSum here
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	sw $a1, 0($sp)

	slti $t0, $a1, 1	# if (len <= 0)
	bne $t0, $zero, calc_base

	addi $a1, $a1, -1
	jal calcSum		# calcSum(arr, len - 1)

	lw $a0, 4($sp)
	lw $a1, 0($sp)
	addi $t0, $a1, -1
	sll $t0, $t0, 2
	add $t1, $a0, $t0
	lw $t2, 0($t1)		# arr[len - 1]
	add $v0, $v0, $t2
	j calc_done

calc_base:
	addi $v0, $zero, 0
	
calc_done:
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	