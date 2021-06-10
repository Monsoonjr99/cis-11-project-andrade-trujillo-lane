;CIS 11, Finals Project
;Team Members: Alejandra Andrade, Allen Trujillo, Ryan Lane
;Design based heavily off of the Github submission from the following people:
; Alberto Gonzalez, Cameron Westlake, & Jonathan Espinoza
;Program: Test Score Calculator
;Description: Create an LC-3 program that displays the minimum, maximum,
;and average grade of 5 test scores and display the letter grade 
;associated with the test scores. 
;Input: User is prompted to input the test scores.
;Output: Display the Minimum, Average, & Maximum score with appropriate letter grade.
;(0~59 == F, 60~69 == D, 70~79 == C, 80~89 == B, 90~100 == A)
;Side Effects: None
;
;Criteria:	Appropriate addresses: .ORIG, .FILL, array, Input/Output.
;			Minimum, max, average values/grades in console.
;			Appropriate labels and comments.
;			Instructions for arithmetic, data move, & conditional operations. 
; 			2 or more subroutines & implement subroutine calls.
;			Branching for control - conditional and interative.
;			Manage overflow and storage allocation.
;			Manage stack - include PUSH-POP operation on stack.
;			Save-Restore operation.
;			Inclusion of Pointer.
;			ASCII conversion operations.
;			Appropriate use of System Call directives.
;			Test the program with following value combination: 52, 87, 96, 79, 61.
;	
;Anti self-plagerism disclaimer: this piece of work is a modified version of
;a C++ grade calculator that I was working on for another class years ago.

.ORIG x3000

    AND R1, R1, #0				;clears Register 1, preparing it as the loop counter
    AND R2, R2, #0				;clears Register 2, preparing it as the digit counter

    ;main input
    LOOPSTART
    JSR CLEARS                  		;clear the console
    LEA R0, ASK					;Load Effective Address with string ASK to R0
    PUTS					;print
    ADD R0, R1, #1				;add one to R1 and place in R0 (for user, grades count from 1 instead of 0)
    JSR DISPLAYNUMBER           		;display counter (of which grade is being entered) to console
    LEA R0, ENDCHECK				;for presentation purposes
    PUTS
    ;now we display the current entered number
    ADD R0, R2, #0				;this handles the number of digits to read from Stack
    JSR DIGITNUMBER				;this turns content within Stack into a number
    JSR DISPLAYNUMBER				;this displays that number

    GETC					;GETs the Character input
    ADD R6, R0, x-A				;a check of if the user has pushed 'Enter'
    BRz NEXTGRADE				;if they have, then stop receiving characters
    ADD R6, R0, x-8				;a check for if the user has pushed 'Backspace'
    BRnp NOBACKSPACE
    ADD R2, R2, #0				;a check for if the current digit is 0
    BRnz LOOPSTART
    JSR POP					;removes item from top of Stack
    ADD R2, R2, #-1				;decrement of Stack digit count	
    BRnzp LOOPSTART
    NOBACKSPACE

    ADD R6, R2, #-3				;a check of if the Stack digits is maxed out
    BRzp LOOPSTART 
    LD R3, NEGCHARACTEROFFSET			;conversion from characters to actual numbers being used
    ADD R0, R0, R3
    BRn LOOPSTART				;BRanch Negative. If negative, its not a valid number. Prompts to get new char
    ADD R3, R6, #-9				;otherwise check if its above last previous inputted number
    BRp LOOPSTART				;if it is, hold as new character to test against
    JSR PUSH					;otherwise, PUSH it onto the Stack
    ADD R2, R2, #1				;then we increment the digit count
    BRnzp LOOPSTART				;and then we receive the next character
    NEXTGRADE
    ;obtain the number that will be put onto the Stack instead of the individual digits
    ADD R0, R2, #0
    JSR DIGITNUMBER 				;a redirect over to the subroutine DIGITNUMBER
    ADD R6, R0, #0				;serves as a temporary backpeddle

    ;now we are going to clear the digits within the Stack
    DIGITCLEAR
    ADD R2, R2, #-1				;a check for if digits left is now 0
    BRn CLEAR
    JSR POP					;JuMP to POP
    BRnzp DIGITCLEAR
    CLEAR
    ADD R0, R6, #0              		;copy value temporarily placed in R6 back to R0
    JSR PUSH					;meant to put the added value onto the Stack, ready for later
    ADD R1, R1, #1		        	;increment loop counter
    AND R2, R2, #0				;clears the digit counter
    LD R3, LOOPCOUNT
    ADD R3, R3, R1
    BRn LOOPSTART				;checks if negative. If yes then get next grade, otherwise proceed to end

    ;once it proceeds to the end, this will serve to display the results
    LD R1, STACKSTART
    LD R3, STACKSIZE
    NOT R3, R3
    ADD R3, R3, #1				;negatve Stack size
    AND R6, R6, #0				;offset for the Stack pointer 
    ADD R6, R6, #1
    AND R4, R4, #0				;Average counter
    ;sets Min and Max to 100 and 0
    LD R2, BASEMINIMUM		
    ST R2, MIN
    LD R2, BASEMAXIMUM
    ST R2, MAX
    JSR CLEARS                  		;clear console

    ;main output
    OUTPUTLOOP
    ADD R2, R6, R3				;checks for if its top of Stack
    BRp ENDOUTPUTLOOP
    LEA R0, OUTPUTGRADE         		;display standard output string for each grade
    PUTS
    ADD R0, R6, #0				;copy contents of Register 6 into Register 0
    JSR DISPLAYNUMBER           		;display index of grade
    LEA R0, ENDCHECK            		;display formatting string
    PUTS
    ADD R2, R1, R6              		;add offset (R6) to stack base address (R1) to get stack pointer (R2)
    LDR R0, R2, #0				;LoaD offsetteR 
    JSR DISPLAYNUMBER				;redirects to DISPLAYNUMBER
    ADD R2, R0, #0				;moves contents of Register 0 into Register 2
    LD R0, SPACE				;prints a 'Space' between DISPLAYNUMBER and upcoming DISPLAYSGRADE
    OUT						;
    ADD R0, R2, #0				;now print the grade
    JSR DISPLAYSGRADE 				;redirects to DISPLAYSGRADE

    ;output for Minimum, Average & Maximum
    ;quick check for Minimum
    LD R2, MIN
    NOT R2, R2
    ADD R2, R2, #1              		;negate R2
    ADD R2, R2, R0              		;subtract minimum from grade
    BRzp NOT_MIN                		;if negative, grade is the new minimum
    ST R0, MIN
    NOT_MIN

    ;quick check for Maximum
    LD R2, MAX
    NOT R2, R2
    ADD R2, R2, #1              		;negate R2
    ADD R2, R2, R0              		;subtract maximum from grade
    BRnz NOT_MAX                		;if positive, grade is the new maximum
    ST R0, MAX
    NOT_MAX

    ;Average adder
    ADD R4, R4, R0              		;add grade to sum
    ADD R6, R6, #1              		;increment stack offset
    LD R0, EMPTYROW             		;display line feed
    OUT
    BRnzp OUTPUTLOOP            		;continue loop
    ENDOUTPUTLOOP
    LD R0, EMPTYROW             		;display line feed
    OUT

    ;calculates Average
    LD R1, LOOPCOUNT
    NOT R1, R1
    ADD R1, R1, #1              		;negate R1 (make LOOPCOUNT positive)
    ADD R0, R4, #0              		;copy sum to R0
    JSR DIV
    ST R0, AVG

    ;displays Minimum
    LEA R0, MINTEXT				;Load Effective Address of MINTEXT into Register 0
    PUTS					;
    LD R0, MIN					;LoaD MIN into Register 0 
    JSR DISPLAYNUMBER 				;redirects to DISPLAYNUMBER
    ADD R2, R0, #0				;moves content of Register 0 into Register 2
    LD R0, SPACE				;prints a 'Space' between DISPLAYNUMBER and upcoming DISPLAYSGRADE
    OUT						;
    ADD R0, R2, #0				;prints the grade
    JSR DISPLAYSGRADE				;redirects to DISPLAYSGRADE
    LD R0, EMPTYROW 				;LoaD EMPTYROW into Register 0
    OUT						;

    ;displays Maximum
    LEA R0, MAXTEXT 				;Load Effective Address of MAXTEXT into Register 0
    PUTS 					;
    LD R0, MAX 					;LoaD MAX into Register 0
    JSR DISPLAYNUMBER				;redirects to DISPLAYNUMBER
    ADD R2, R0, #0				;moves content of Register 0 into Register 2
    LD R0, SPACE				;prints a 'Space' between DISPLAYNUMBER and upcoming DISPLAYSGRADE
    OUT						;
    ADD R0, R2, #0				;prints the grade
    JSR DISPLAYSGRADE				;redirects to DISPLAYSGRADE
    LD R0, EMPTYROW 				;LoaD EMPTYROW into Register 0
    OUT						;

    ;displays Average
    LEA R0, AVERAGETEXT				;Load Effective Address of AVERAGETEXT into Register 0
    PUTS					;
    LD R0, AVG					;LoaD AVBG into Register 0
    JSR DISPLAYNUMBER				;redirects to DISPLAYNUMBER
    ADD R2, R0, #0				;moves contents of Register 0 into Register 2
    LD R0, SPACE				;prints a Space between DISPLAYNUMBER and upcoming DISPLAYSGRADE
    OUT						;
    ADD R0, R2, #0				;prints the grade
    JSR DISPLAYSGRADE				;redirects to DISPLAYSGRADE
    LD R0, EMPTYROW				;LoaD EMPTYROW into Register 0
    OUT						;
    HALT					;stop program

;constants
ASK		            .STRINGZ "Enter grade #"
ENDCHECK		    .STRINGZ ": "
OUTPUTGRADE	        .STRINGZ "Grade "
MINTEXT		        .STRINGZ "Lowest:  "
MAXTEXT		        .STRINGZ "Highest: "
AVERAGETEXT	        .STRINGZ "Average: "
CHARACTEROFFSET 	.FILL x30
NEGCHARACTEROFFSET 	.FILL x-30
LOOPCOUNT	        .FILL #-5
BASEMINIMUM	        .FILL #10000
BASEMAXIMUM	        .FILL #0

;variables
MIN	                .FILL #0
MAX	                .FILL #0
AVG	                .FILL #0
EMPTYROW	        .FILL xA
SPACE	            .FILL x20
STACKSIZE	        .FILL x0
STACKSTART	        .FILL x4000

;<START> swift multiplication handler
MULT1
;Register 0 & R1 serve as input, with Register 0 also handles output
;Registers 2, 3, 4, & 5 are also used but will be later restored
    ST R1, REGISTERSAVE1		;R1 is the input handler
    ST R2, REGISTERSAVE2		;R2 is the the dump Register to be used for checks
    ST R3, REGISTERSAVE3		;R3 is the temporary output
    ST R4, REGISTERSAVE4		;R4 is the activates negative flag
    ST R6, REGISTERSAVE6		;R6 is the bit counter
    AND R3, R3, #0				;clears the output
    AND R4, R4, #0				;clears the negative flag
    AND R6, R6, #0				;clears the counter
    ADD R6, R6, #1				;adds a value of 1 to counter to initiate process

    ;negative check
    ADD R2, R0, #0
    BRzp MULT_INPUTNOTNEG		;if the input returned after 0 is not negative, skip this
    ADD R4, R4, #1				;add a value of 1 to the flag
    NOT R0, R0					;convert to positive temporarily
    ADD R0, R0, #1
    MULT_INPUTNOTNEG
    ADD R2, R1, #0
    BRzp MULT_LOOP				;if the input returned after 1 is not negative, skip this
    ADD R4, R4, #1				;add a value of 1 to the flag
    NOT R1, R1					;convert to positive temporarily
    ADD R1, R1, #1

    ;the main loop
    MULT_LOOP
    AND R2, R6, R1				;checks if the bits match
    BRz MULT_SKIPADD			;if not, skip addition
    ADD R3, R0, R3				;add current contents of Register 0 to Register 3
    MULT_SKIPADD
    ADD R0, R0, R0				;doubles the value curently held inside Register 0
    ADD R6, R6, R6				;doubles the value currently held inside Register 6
    BRz MULT_END				;if contents of Register 6 equals 0, skip to end
    BRnzp MULT_LOOP				;otherwise loop again
    MULT_END

    ;checks if the negative flag has been set
    AND R4, R4, #1
    BRz MULT_NOTNEG
    NOT R3, R3					;1s Complement (inversion, pt. 1)
    ADD R3, R3, #1				;2s Complement (inversion, pt. 2)
    MULT_NOTNEG
    ;now move R3 to R0
    ADD R0, R3, #0

    ;LoaDing Registers
    LD R1, REGISTERSAVE1
    LD R2, REGISTERSAVE2
    LD R3, REGISTERSAVE3
    LD R4, REGISTERSAVE4
    LD R6, REGISTERSAVE6
    RET							;finally we RETurn to prior sequential location
;<FINISH> swift multiplication handler

;<START> display number subroutine
;uses Register 0 for the input
;the variables
DISPLAYNUMBER
    ST R0, DISPLAYREGISTERSAVE0	;STore contents of Register 0 into DISPLAYREGISTERSAVE0
    ST R1, DISPLAYREGISTERSAVE1	;STore contents of Register 1 into DISPLAYREGISTERSAVE1
    ST R2, DISPLAYREGISTERSAVE2	;STore contents of Register 2 into DISPLAYREGISTERSAVE2
    ST R3, DISPLAYREGISTERSAVE3	;STore contents of Register 3 into DISPLAYREGISTERSAVE3
    ST R4, DISPLAYREGISTERSAVE4	;STore contents of Register 4 into DISPLAYREGISTERSAVE4
    ST R5, DISPLAYREGISTERSAVE5	;STore contents of Register 5 into DISPLAYREGISTERSAVE5
    ST R6, DISPLAYREGISTERSAVE6	;STore contents of Register 6 into DISPLAYREGISTERSAVE6
    ST R7, DISPLAYREGISTERSAVE7	;STore contents of Register 7 into DISPLAYREGISTERSAVE7

    ;initializes the values
    LD R4, CHARACTEROFFSET		;LoaD character offset
    AND R3, R3, #0				;clears the 0 flag
    LD R5, NUM10000				;the current digit to be divided by
    ADD R2, R0, #0
    BRzp DISPLAYNUMBER_LOOP		;BRanch if this is zero or positive to DISPLAYNUMBER_LOOP
    LD R0, DASH
    OUT
    NOT R2, R2					;1s Complement (inversion, pt. 1)
    ADD R2, R2, #1 				;2s Complement (inversion, pt. 2)

    DISPLAYNUMBER_LOOP
    ADD R6, R5, #-1				;checks if the current digit is 1
    BRz DISPLAYNUMBER_END		;if it is, goto end
    ADD R0, R2, #0				;otherwise, divide the number by contents within Register 1
    ADD R1, R5, #0
    JSR DIV						;Register 0 has the digit to output, with contents of Register 1 leftover
    ADD R3, R3, R0				;checks if either the 0 flag or Register 0 is greater than zero
    BRz DISPLAYNUMBER_SKIP		;if not, bypass OUT
    ADD R0, R0, R4				;moves the digit counter + character offset into Register 0
    OUT							;OUTputs results

    DISPLAYNUMBER_SKIP
    ADD R2, R1, #0				;moves contents of Register 1 into Register 2
    ADD R0, R5, #0				;readies procedure to divide by 10
    AND R1, R1, #0
    ADD R1, R1, #10
    JSR DIV						;
    ADD R5, R0, #0				;
    BRnzp DISPLAYNUMBER_LOOP	;repeats process
    DISPLAYNUMBER_END
    ADD R0, R2, R4				;adds character offset towards Register 0
    OUT							;OUTputs results

    LD R0, DISPLAYREGISTERSAVE0	;LoaD contents of Register 0 into DISPLAYREGISTERSAVE0
    LD R1, DISPLAYREGISTERSAVE1	;LoaD contents of Register 1 into DISPLAYREGISTERSAVE1
    LD R2, DISPLAYREGISTERSAVE2	;LoaD contents of Register 2 into DISPLAYREGISTERSAVE2
    LD R3, DISPLAYREGISTERSAVE3	;LoaD contents of Register 3 into DISPLAYREGISTERSAVE3
    LD R4, DISPLAYREGISTERSAVE4	;LoaD contents of Register 4 into DISPLAYREGISTERSAVE4
    LD R5, DISPLAYREGISTERSAVE5	;LoaD contents of Register 5 into DISPLAYREGISTERSAVE5
    LD R6, DISPLAYREGISTERSAVE6	;LoaD contents of Register 6 into DISPLAYREGISTERSAVE6
    LD R7, DISPLAYREGISTERSAVE7	;LoaD contents of Register 7 into DISPLAYREGISTERSAVE7
    RET							;finally we RETurn to prior sequential location
;<FINISH> display number subroutine

;<START> division & modulus subroutine
;Register 0 & 1 serve as input as well as output
;Register 0 will serve as the quotient, Register 1 as the modulus
DIV
    ST R2, REGISTERSAVE2		;saves contents of Register 2
    ST R3, REGISTERSAVE3		;saves contents of Register 3
    ST R6, REGISTERSAVE6		;saves contents of Register 6

    AND R3, R3, x0				;clears Register 3 
    AND R6, R6, x0				;clears Register 6,  will be used for the sign
    AND R2, R2, x0				;serves as the modulus operator

    ;zero checker
    ADD R1, R1, #0
    BRnp DIVISIONNOTZERO
    AND R0, R0, x0
    AND R1, R1, x0
    BRnzp DIVEND 
    DIVISIONNOTZERO

    ;negative checker
    ADD R0, R0, #0
    BRzp DIVISIONNOTNEG0		;if results is not negative, bypass this part
    ADD R6, R6, #1				;
    NOT R0, R0					;1s Complement (inversion, pt. 1)
    ADD R0, R0, #1				;2s Complement (inversion, pt. 2)
    DIVISIONNOTNEG0
    ADD R1, R1, #0
    BRnz DIVISIONNEG1			;if results is negative, bypass this part
    NOT R1, R1					;1s Complement (inversion, pt. 1)
    ADD R1, R1, #1				;2s Complement (inversion, pt. 2)
    BRnzp DIVLOOP
    DIVISIONNEG1
    ADD R6, R6, #1

    DIVLOOP						;begin main multiplication loop
    ADD R0, R0, R1				;subtracts value within Register 1 from Register 0
    BRn DIVEND					;if Register 0 becomes negative, bypass
    ADD R3, R3, #1				;otherwise, add a value of 1 to quotient
    BRnzp DIVLOOP				;repeat using BRanch for 'N,P, & Z' because it uses labels without modifying Register 7
    DIVEND
    NOT R1, R1					;1s Complement (inversion, pt. 1)
    ADD R1, R1, #1				;2s Complement (inversion, pt. 2)
    ADD R2, R1, R0				;Add conents of Register 0 and Register 1 together to get the modulus
    AND R6, R6, x1				;checks if the 1s bit in Register 6 is active/on
    BRnz DIVISIONNEGPRODUCT		;if it is not, bypass the product inversion step
    NOT R3, R3
    ADD R3, R3, #1
    NOT R2, R2
    ADD R2, R2, #1
    DIVISIONNEGPRODUCT
        
    ;uses to move the values
    ADD R0, R3, #0
    ADD R1, R2, #0

    ;reloads the older values
    LD R2, REGISTERSAVE2
    LD R3, REGISTERSAVE3
    LD R6, REGISTERSAVE6

    RET							;finally we RETurn to prior sequential location
;<FINISH> division & modulus subroutine

;<START> Stack PUSH subroutine
;uses Register 0 to handle the input
PUSH
    ST R1, REGISTERSAVE1		;saves contents of Register 1
    ST R3, REGISTERSAVE3		;saves contents of Register 3
    LD R1, STACKSIZE			;takes note of the current Stack size
    ADD R1, R1, #1				;adds a value of 1 to Stack size
    ST R1, STACKSIZE			;sets as the new Stack size
    LD R3, STACKSTART			;LoaD starting position
    ADD R1, R1, R3				;adds the values within Register 1 & Register 3 together
    STR R0, R1, #0				;STore offsetteR data at new top of the Stack
    LD R1, REGISTERSAVE1		;restores value previously assigned to Register 1
    LD R3, REGISTERSAVE3 		;restores value previously assigned to Register 3
    RET							;now we RETurn to prior sequential location
;<FINISH> Stack PUSH subroutine

;<START> Stack POP subroutine
;Register 0 will serve as the output
POP
    ST R0, REGISTERSAVE0		;saves contents of Register 0
    ST R1, REGISTERSAVE1		;saves contents of Register 1
    ST R3, REGISTERSAVE3 		;saves contents of Register 3
    ST R7, REGISTERSAVE7		;saves contents of Register 7
    JSR ISEMPTY					;check if it is true, that it is empty
    ADD R0, R0, #0
    BRp POP_SKIP				;if instead it is positive, bypass this part
    LEA R0, POPERROR			;prints out an error message
    PUTS						;
    LD R7, REGISTERSAVE7		;restores value previously assigned to Register 7
    RET							;RETurn for now, otherwise it continues

    LD R0, REGISTERSAVE0		;restores value previously assigned to Register 0
    POP_SKIP				
    LD R1, STACKSIZE			;obtains the current Stack size
    LD R3, STACKSTART			;LoaD Stack starting position
    ADD R1, R1, R3				;add together the contents of Register 1 and Register 3
    LDR R0, R1, #0				;LoaD the data off the top of the Stack
    AND R3, R3, #0				;clears out Register 3
    STR R3, R1, #0				;sets the loading Stack position to 0
    LD R1, STACKSIZE			;reLoaDs Stack size
    ADD R1, R1, #-1				;subtracts 1 off the Stack
    ST R1, STACKSIZE			;sets as nes Stack size
    LD R1, REGISTERSAVE1		;restores value previously assigned to Register 1
    LD R3, REGISTERSAVE3 		;restores value previously assigned to Register 3
    LD R7, REGISTERSAVE7		;restores value previously assigned to Register 7
    RET							;finally we RETurn to prior sequential location
;<FINISH> Stack POP subroutine

;<START> Stack ISEMPTY subroutine
;Register 0 will serve as the output
ISEMPTY
    LD R0, STACKSIZE			;surveys current Stack size
    BRz #2						;if 0, it bypass these lines
    AND R0, R0, #0				;clears out Register 0
    ADD R0, R0, #1				;gives a value of 1 to Register 0
    RET							;now we RETurn to prior sequential location
;<FINISH> Stack ISEMPTY subroutine

;<START> clear Console subroutine
;just clears the console, with no input or output
CLEARSLINE	        .FILL #26		;lines to be CLEAR
CLEARS
    ST R0, REGISTERSAVE0		;saves contents of Register 0
    ST R1, REGISTERSAVE1		;saves contents of Register 1
    ST R7, REGISTERSAVE7		;saves contents of Register 7
    LD R0, EMPTYROW				;LoaD contents of EMPTYROW into Register 0
    LD R1, CLEARSLINE			;LoaD contents of CLEARSLINE into Register 1
    CLEARSLOOP
    OUT							;
    ADD R1, R1, #-1				;gives a value of -1 to Register 1
    BRp CLEARSLOOP
    LD R0, REGISTERSAVE0		;restores value previously assigned to Register 0
    LD R1, REGISTERSAVE1		;restores value previously assigned to Register 1
    LD R7, REGISTERSAVE7		;restores value previously assigned to Register 7
    RET							;now we RETurn to prior sequential location
;<FINISH> clear Console subroutine

;<START> digit-to-number subroutine
;using digits from the Stack and turning them into a number, start from the top of the Stack
;the digit's number is specified by input number. Example: x4000 with 0 becomes 4150
;Register 0 will serve as the input & output
DIGITNUMBER
    ST R1, DISPLAYREGISTERSAVE1	;saves contents of Register 1
    ST R2, DISPLAYREGISTERSAVE2	;saves contents of Register 2
    ST R3, DISPLAYREGISTERSAVE3	;saves contents of Register 3
    ST R4, DISPLAYREGISTERSAVE4	;saves contents of Register 4
    ST R6, DISPLAYREGISTERSAVE6	;saves contents of Register 6
    ST R7, DISPLAYREGISTERSAVE7	;saves contents of Register 7

    LD R1, STACKSTART			;LoaD contents of STACKSTART into Register 1
    LD R3, STACKSIZE			;LoaD contents of STACKSIZE into Register 3
    ADD R6, R1, R3				;gets digit from top of Stack
    AND R3, R3, #0				;Current output
    AND R1, R1, #0				;multiplication counter
    ADD R1, R1, #1
    ADD R2, R0, #0				;serves as a loop counter	
    DIGITNUMBER_LOOP			
    ADD R2, R2, #-1				;checks if process has ended
    BRn DIGITNUMBER_END
    LDR R0, R6, #0				;gets digit from top of Stack
    JSR MULT1					;redirects to MULT1
    ADD R3, R3, R0				;takes value from Register 0 and outputs to total
    LD R0, NUM10
    JSR MULT1					;multiplier, multiplies value by 10
    ADD R1, R0, #0
    ADD R6, R6, #-1				;decrement the Stack pointer by 1
    BRnzp DIGITNUMBER_LOOP		;repeats process until completed
    DIGITNUMBER_END
    ADD R0, R3, #0				;moves the output to Register 0

    LD R1, DISPLAYREGISTERSAVE1	;restores value previously assigned to Register 1
    LD R2, DISPLAYREGISTERSAVE2	;restores value previously assigned to Register 2
    LD R3, DISPLAYREGISTERSAVE3	;restores value previously assigned to Register 3
    LD R4, DISPLAYREGISTERSAVE4	;restores value previously assigned to Register 4
    LD R6, DISPLAYREGISTERSAVE6	;restores value previously assigned to Register 6
    LD R7, DISPLAYREGISTERSAVE7	;restores value previously assigned to Register 7
    RET							;now we RETurn to prior sequential location
;<FINSIH> digit-to-number subroutine

;<START> display grade subroutine
;receives a grade number, assigning and display the appropriate grade letter
;only Register 0 serves as input, with no other output
;constants
GRADE_A	            .FILL #-90
GRADE_B	            .FILL #-80
GRADE_C	            .FILL #-70
GRADE_D	            .FILL #-60
CHAR_A	            .FILL x41
CHAR_B	            .FILL x42
CHAR_C	            .FILL x43
CHAR_D	            .FILL x44
CHAR_F	            .FILL x46

DISPLAYSGRADE
    ST R0, REGISTERSAVE0
    ST R1, REGISTERSAVE1
    ST R7, REGISTERSAVE7
    LD R1, GRADE_A
    ADD R1, R0, R1
    BRn DISPLAYSGRADE_A
    LD R0, CHAR_A
    OUT
    BRnzp DISPLAYSGRADE_END
    DISPLAYSGRADE_A
    LD R1, GRADE_B
    ADD R1, R0, R1
    BRn DISPLAYSGRADE_B
    LD R0, CHAR_B
    OUT
    BRnzp DISPLAYSGRADE_END
    DISPLAYSGRADE_B
    LD R1, GRADE_C
    ADD R1, R0, R1
    BRn DISPLAYSGRADE_C
    LD R0, CHAR_C
    OUT
    BRnzp DISPLAYSGRADE_END
    DISPLAYSGRADE_C
    LD R1, GRADE_D
    ADD R1, R0, R1
    BRn DISPLAYSGRADE_D
    LD R0, CHAR_D
    OUT
    BRnzp DISPLAYSGRADE_END
    DISPLAYSGRADE_D

    ;if none of the above are true, output F
    LD R0, CHAR_F
    OUT
    DISPLAYSGRADE_END
    LD R0, REGISTERSAVE0
    LD R1, REGISTERSAVE1
    LD R7, REGISTERSAVE7
    RET
;<FINISH> display grade subroutine

;value holder
REGISTERSAVE0	        .FILL #0
REGISTERSAVE1	        .FILL #0
REGISTERSAVE2	        .FILL #0
REGISTERSAVE3	        .FILL #0
REGISTERSAVE4	        .FILL #0
REGISTERSAVE5	        .FILL #0
REGISTERSAVE6	        .FILL #0
REGISTERSAVE7	        .FILL #0
DISPLAYREGISTERSAVE0	.FILL #0
DISPLAYREGISTERSAVE1	.FILL #0
DISPLAYREGISTERSAVE2	.FILL #0
DISPLAYREGISTERSAVE3	.FILL #0
DISPLAYREGISTERSAVE4	.FILL #0
DISPLAYREGISTERSAVE5	.FILL #0
DISPLAYREGISTERSAVE6	.FILL #0
DISPLAYREGISTERSAVE7	.FILL #0


;constants
NUM10000	            .FILL #10000
NUM10		            .FILL #10
POPERROR	            .STRINGZ "ERROR: Stack is empty!\n"
DASH	                .FILL x2D

.END