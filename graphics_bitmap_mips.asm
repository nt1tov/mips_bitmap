
.data

SEP:	.ascii "."		#special macros for cheicking if dot

.eqv	BASE	0x10040000
	
.eqv	IMG_WIDTH 1024
.eqv	IMG_HEIGHT 512
.eqv	IMG_WIDTH_NEW 512
.eqv	BGND_COLOR 0x00F00000		#background color
.eqv	IMG_COLOR 0x00FFFF00		#image color

matrix:		
			.ascii "..................................................................................."
row_end:		.ascii "..................................................................................."	
			.ascii "................########.####.########..#######..##.....##........................."
	               	.ascii "...................##.....##.....##....##.....##.##.....##........................."
                	.ascii "...................##.....##.....##....##.....##.##.....##........................."
                	.ascii "...................##.....##.....##....##.....##.##.....##........................."
                	.ascii "...................##.....##.....##....##.....##..##...##.........................."
                	.ascii "...................##.....##.....##....##.....##...##.##..........................."
                	.ascii "...................##....####....##.....#######.....###............................"
                	.ascii "..................................................................................."
         		.ascii "................##....##.####.##....##..#######..##..........###....##....##......."
         		.ascii "................###...##..##..##...##..##.....##.##.........##.##....##..##........"
         		.ascii "................####..##..##..##..##...##.....##.##........##...##....####........."
         		.ascii "................##.##.##..##..#####....##.....##.##.......##.....##....##.........."
         		.ascii "................##..####..##..##..##...##.....##.##.......#########....##.........."
         		.ascii "................##...###..##..##...##..##.....##.##.......##.....##....##.........."
         		.ascii "................##....##.####.##....##..#######..########.##.....##....##.........."
         		.ascii "..................................................................................."
                	.ascii ".................#######....#####....#######....#####.............................."
                	.ascii "................##.....##..##...##..##.....##..##...##............................."
                	.ascii ".......................##.##.....##........##.##.....##............................"
                	.ascii ".................#######..##.....##..#######..##.....##............................"
                	.ascii "................##........##.....##.##........##.....##............................"
                	.ascii "................##.........##...##..##.........##...##............................."
                	.ascii "................#########...#####...#########...#####.............................."	
                	.ascii "..................................................................................."
                	.ascii "..................................................................................."
matrix_end:





.text
	la 	$t0	matrix		#image begin addr data
	la 	$t1	row_end		#end of one 1st line addr
	la 	$t2 	matrix_end	#end of text img data addr
	
	sub	$s3 	$t1 	$t0	# calc matrix W
	
	sub 	$t2 	$t2	$t0	# calc matrix H
	div	$s4	$t2	$s3 	# calc matrix H
	
	
	li	$s1	0		#rows iterator i
	li 	$s2	0		#cols iterator j
	
	


for_i:					#for in range	(0,  DISPLAY_WIDTH)
	li	$t0	IMG_HEIGHT	#check condition for i
	beq	$t0	$s1	end_all	#check condition for i
	
for_j:					#for in range	(0, DISPLAY_HEIGHT)
	li	$t0	IMG_WIDTH	#check condition for j
	beq	$t0	$s2	next_line	#check condition for j
	
	move	$a0	$s1		#cur coord I in Image 
	li	$a1	IMG_HEIGHT	#load interval [0, a] of Image Height
	move	$a2	$s4		#load interval [0, A] of Matrix Height 
	jal Img2Matrix
	move	$s5	$v0		#save I_scaled  coord of matrix in s5
	

	
	
	move	$a0	$s2		#load cur J coord in Image
	li	$a1	IMG_WIDTH	#load interval [0, a] of Image WIDTH
	move	$a2	$s3		#load interval [0, A] of Matrix WIDTH 
	jal Img2Matrix	
	move	$s6	$v0		#save J_scaled coord of matrix in s6
	
	
	
	mul	$t0	$s5	$s3	#  i_scaled * W 
	add	$t0	$t0	$s6	#  i_scaled * W + j_scaled
	
	lb	$t1	SEP		#load separator from memory
	lb 	$t2	matrix($t0)	#load scaled index matrix value
	
	
	move	$a0	$s1
	move	$a1	$s2
	jal	GMemShift		#check shift in graphic memory mapping
	move	$s0	$v0
	
	
	beq	$t1	$t2	background	#if symbol is '.' draw background, else draw words
	
	li	$t0	IMG_COLOR
	sw	$t0 	($s0)	
	j end_iter
	
background:
	
	#li	$t0	BGND_COLOR
	move	$a0	$s1
	move	$a1	$s2
	li	$a2	IMG_HEIGHT
	li	$a3	IMG_WIDTH
	jal	NormalDistanse
	move	$t1	$v0

	sw	$t1 	($s0)	

	
end_iter:
	add	$s2	$s2	1
	j	for_j	
	
	
next_line:

	li	$s2	0
	add	$s1	$s1	1
	j  for_i 
	
end_all:
        li      $v0	10          
        syscall
	
		
Img2Matrix: # x(a0) in [0, a(a1)] -> X(v0) in [0, A(a2)] X = (x-0)/(a-0) * (A-0) == (x/a)* A
	mtc1	$a0	$f1
	cvt.s.w	$f1	$f1
	
	mtc1	$a1	$f2
	cvt.s.w	$f2	$f2
	
	mtc1	$a2	$f3
	cvt.s.w	$f3	$f3
	
	
	div.s	$f1	$f1	$f2 # x/a
	mul.s	$f1	$f1	$f3 # (x/a) * A
	
	cvt.w.s	$f1	$f1
	mfc1	$v0	$f1
	
	jr	$ra
	
GMemShift:	
	move	$v0	$a0
	mul	$v0	$v0	IMG_WIDTH
	add	$v0	$v0	$a1
	mul	$v0	$v0	4
	add	$v0	$v0	BASE
	jr	$ra

	

NormalDistanse:
	mtc1	$a0	$f1	#y
	cvt.s.w	$f1	$f1	
	mtc1	$a1	$f2	#x
	cvt.s.w	$f2	$f2
	mtc1	$a2	$f3	#H
	cvt.s.w	$f3	$f3
	mtc1	$a3	$f4	#W
	cvt.s.w	$f4	$f4
	
	li	$t0	2	#2 const
	mtc1	$t0	$f5
	cvt.s.w	$f5	$f5
	
	div.s	$f3	$f3	$f5 #	H/2
	div.s	$f4	$f4	$f5 # W/2
	
	sub.s	$f1	$f1	$f3 #(y - H/2)
	sub.s	$f2	$f2	$f4 #(x - W/2)
	
	mul.s	$f1	$f1	$f1 	#y - H/2) **2
	mul.s	$f2	$f2	$f2	#x - W/2)**2
	add.s	$f6	$f1	$f2	#(x - H/2) **2 + (y - W/2)**2
		
	mul.s	$f3	$f3	$f3	# (H/2)**2
	mul.s	$f4	$f4	$f4	# (W/2)**2
	add.s	$f4	$f4	$f3
	
	div.s	$f6	$f6	$f4	# ((y - H/2) **2 + (x - W/2)**2) / ((H/2)**2 + (W/2)**2)
	
	li $t0	0x000000FF
	mtc1	$t0	$f7	#W
	cvt.s.w	$f7	$f7
	
	mul.s	$f6	$f7	$f6
	
	
	cvt.w.s	$f6	$f6
	mfc1	$v0	$f6
	sll	$v0	$v0	8
	
	jr $ra
