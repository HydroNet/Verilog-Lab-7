# Verilog-Lab-7
1 Introduction
In this lab, you will develop assembly programs which consist of loops and branches.
You will simulate them with the µVision IDE and run them on the LPC2148 Education
board. The main objectives are:
 to practice on writing loops with comparison and branch instructions
 to get familiar with the instructions that change the program flow
 to work with characters
 to write delays for flashing LEDs
2 Lab Preparation
Please prepare the lab (e.g., read this section, write the needed code, and assemble
them to eliminate any syntax error) before you come to the laboratory. This helps you to
complete the required tasks on time.  
2.1 STARTUP CODE
Starting from this lab experiment, you will be using the following startup code to
replace the previous one:
; Standard definitions of Mode bits and Interrupt (I & F) flags in PSR s   
Mode_USR EQU   0x10
I_Bit     EQU   0x80       ; when I bit is set, IRQ is disabled   
F_Bit EQU   0x40       ; when F bit is set, FIQ is disabled   
;Defintions of User Mode Stack and Size
USR_Stack_Size    EQU   0x00000100
SRAM EQU   0X40000000
Stack_Top  EQU   SRAM+USR_Stack_Size
AREA RESET, CODE, READONLY
ENTRY
ARM
IMPORT user_code
VECTORS
LDR    PC,Reset_Addr
LDR    PC,Undef_Addr
LDR    PC,SWI_Addr
LDR    PC,PAbt_Addr
LDR    PC,DAbt_Addr
California State University, Northridge ECE425L
ECE Department By: Xiaojun Geng
2 
NOP
LDR    PC,IRQ_Addr
LDR    PC,FIQ_Addr
Reset_Addr    DCD   user_code
Undef_Addr    DCD   UndefHandler
SWI_Addr   DCD   SWIHandler
PAbt_Addr DCD   PAbtHandler
DAbt_Addr    DCD   DAbtHandler
DCD   0
IRQ_Addr   DCD   IRQHandler
FIQ_Addr    DCD   FIQHandler
SWIHandler    B   SWIHandler
PAbtHandler    B    PAbtHandler
DAbtHandler    B   DAbtHandler
IRQHandler    B    IRQHandler
FIQHandler    B    FIQHandler
UndefHandler   B   UndefHandler
; Enter User Mode with interrupts enabled
MOV r14, #Mode_USR
BIC    r14,r14,#(I_Bit+F_Bit)
MSR   cpsr_c, r14
;initialize the stack, full descending
LDR   SP, =Stack_Top
;load start address of user code into PC
LDR    pc, =user_code
END
New lines are added to the previous startup code you used in the previous lab
experiments. They are enclosed in boxes. You may use the same name for this code as
mystartup.s. In addition, you need to pay attend to the following formatting:
 The AREA name for the above code is RESET, which is capitalized
 The AREA names for your own code need to be lower case
 The label for the first line of your own code should be user_code
2.2 BRANCHES
You need to write branch instructions in situations when your program needs to  
 jump backwards to form a loop
 jump forwards in conditional structure;
 jump to a subroutine
 change the processor between ARM state and Thumb state
California State University, Northridge ECE425L
ECE Department By: Xiaojun Geng
3 
Several branch instructions are available for ARM7TDMI processor; in this lab we only
practice the following type of instructions:
B<suffix>     destination address
B without any suffix is the simplest branch. When this instruction is executed, the ARM
processor will load the destination address to its program counter, and start executing
from there. The actual execution of this branch instruction can be examined using the
debugging tool in the Keil µVision IDE. In your lab report, describe in detail how the branch
instructions used in your program are actually executed.  
B can be executed unconditionally and conditionally. The conditional execution is
done by adding a condition code as suffix. The condition codes are listed in Table 8.1 on
page 129 of the textbook. The following conditional branches may be used in this lab:
BEQ        branch if equal or zero; branch if the condition code flag Z = 1
BNE    branch if not equal or zero; branch if Z = 0
BGE  branch if the signed result is greater than or equal to zero; the result from the
previous instruction will be interpreted by this instruction to be signed numbers.  
BGT  branch if the signed result is greater than zero; the result from the previous
instruction will be interpreted by this instruction to be signed numbers.  
2.3 LOOPS
We have built the simplest loop (endless or unconditionally) in previous lab
experiments, which is
stop    B   stop
However, most of loops need to check if a terminating condition is met. A loop in C
language is shown below with a terminating condition:
#define  COUNT_VAL   10000;
int i;
for (i=0; i< COUNT_VAL; i++)  ;
where the code increase the counter i from 0 to 10000, then stop.  In assembly language,
we prefer counting down to counting up, that is
#define  COUNT_VAL    10000;
int i;
for (i= COUNT_VAL; i<=0; i‐‐)  ;
This piece of code can be used to implement a delay. As one part of your pre‐lab, you will
write equivalent code in ARM assembly to implement both a counting‐up delay and a
counting‐down delay. Note that “S” could be appended to many ARM instructions to
influence the condition code flags.  For example,  
SUBS   r0, r1,r0   ;r0=r1‐r0, and set the condition code flags  
;according to the results  
California State University, Northridge ECE425L
ECE Department By: Xiaojun Geng
4 
ADDS   r0, r1,r2   ;r0=r1+r2, and set the condition code flags  
;according to the results  
Without “S”, SUB and ADD instructions don’t affect the condition code flags.  
2.4 DATA SECTION
Note that addresses ranging from 0 to 0x7FFFF are mapped to the on‐chip 512 KB
flash memory, which cannot be modified by the store instructions such as STR. To
allocate RAM memory locations to your code or data, you may use, for example:
AREA mydata, DATA, READWRITE
sum   DCD  0    ;reserve 4‐byte location for “sum” with initial value 0  
result SPACE 8    ;reserve 8‐bytes for “result” with initial value 0    
With this example, the 8‐bytes space allocated to “result” will be placed right after the 4‐
byte location for “sum”, and the “sum” will be placed in the beginning of this data
section. By default, this read/write data section starts from address 0x4000 0000 which is
assigned to on‐chip RAM. This default configuration is specified in the target option, as
illustrated in Figure 1.  
Figure 1. Target Option Window. 
The following will help you understand more on how to use the above reserved data
blocks in your program. The symbols sum and result are assigned with values by the
assembler, that is, sum = 0x4000 0000 and result = 0x4000 0004. The code below shows
examples of using these symbols:
California State University, Northridge ECE425L
ECE Department By: Xiaojun Geng
5 
LDR   r0,=sum   ; r0 = 0x4000 0000  
LDR   r0, sum    ; r0 = 0 which is the data at memory location sum
Note that the MDK‐ARM (Microcontroller Development Kit) tool used in the lab
initializes all the read/write memory locations with zeros after startup. In order to place
non‐zero data in read/write data section, you need to initialize values in your code.  
Also note that the current version of the Flash Magic tool does not display RAM
contents on LPC2148. To verify the results stored in RAM, use the Debugging tool in
µVision instead.  
2.5 CHARACTERS AND STRINGS
Characters can be stored in the memory with ASCII code. Strings can be pre‐stored in
the memory with the assembler directive DCB (Define Constant Byte), as shown in the
following example:
mystring     DCB   “This is an example of strings”,0   
message    DCB   “Attention please!”,0
ALIGN
Where are these strings stored in the memory? It depends on where you write the
code in your program. A good approach is to place these lines right after your program
code in the memory. For example,
myprogram  ⋮
⋮
stop    B    stop
mystring   DCB   “This is an example of strings”,0   
message    DCB   “Attention please!”,0
ALIGN
END
With the above code, each character in the strings takes up one‐byte location,
continuously in the memory. Notice that there is a directive, ALIGN, following the
memory allocation for strings. This is to ensure that the machine code placed after these
characters is aligned with the 4‐byte boundaries. Also note that each string is followed
with a terminating zero byte.  
Question : Why is ALIGN necessary to be placed after DCBs?  
3 Procedures
For each of the following tasks, you need to  
 Create and assemble your code to implement the task BEFORE coming to the lab.
 Simulate your code and verify the result with the simulator.
California State University, Northridge ECE425L
ECE Department By: Xiaojun Geng
6 
 Demonstrate the results to the lab instructor before you leave the lab.
Task 1: Develop an ARM assembly program which will find the sum of all numbers from
1 to num, where num is an arbitrarily given unsigned 16‐bit number. For example, given
num = 4, we would add the following: 1+2+3+4 = 10. Define num as a constant with
directive EQU so that its value can be changed easily. The sum should be stored in the
memory. Verify the answer with the Debugging tool in the µVision IDE.
In addition, from the disassembly window in the debugging session, find out the actual
ARM instructions being executed for the branches in your code, and explain why.
Questions:   (1) How many bytes should the result take in size?  
(2) Where in the memory and how do you reserve space for the result?
Task 2. With the startup code given in Section 2.1 of this handout and your code created
for Task 1, examine the program flow with the help of the Debugging tool in µVision, and
describe in detail how the program flow changes by the instructions from the beginning
to the end in your lab report.  
Task 3. Write a program in ARM assembly to look for an arbitrary character in a given
string and then return how many times the character was used in the string.  All strings
must be terminated with a zero byte which denotes the end of a string. For example, you
have a string “'If you are going to pass, you gotta love this class” which is followed by a
zero. Your program is going to find that there are six ‘o’s in this string. Verify the result
using the Debugging tool of the µVision IDE.  
Task 4:  Write a complete program to flash the eight LEDs five times. More specifically,
hold all the LEDs off initially, then, turn all the LEDs on for 1 second and off for 1 second,
and repeat five times. You may use an oscilloscope to check and adjust the delay
duration.  
Task 5. Write a program in ARM assembly to count the number of “1” bits in each of the
first 10 instructions of your program code (starting from label “user_code”). Note that
each instruction is 32‐bit long in the memory. The result should be stored in the memory,
consisting of 10 numbers, one for each 32‐bit instruction. For example, if the machine
code of your program starting from user_code is listed in Column 2 of Table 1, then, the
number of “1”s in each 32‐bit instruction is listed in Column 3 of the table.  
Hints: (1) Your program code will have two loops: an outer loop will sequence through the
10 32‐bit machine instructions, while the inner loop will count the number of “1” bits in
each instruction.  (2) The “1” bits could be counted by shifting to the Carry bit.  
California State University, Northridge ECE425L
ECE Department By: Xiaojun Geng
7 
Table 1. Exmaple of machine code and number of 1’s in each 32-bit machine code. 
Instruction Code 32‐bit Machine Code # of “1” bits
1st Instruction 0x FF00 AA00 10
2nd Instruction 0x 0011 2233 8
3rd Instruction 0x FFFF EEEE 28
4 Requirements:
A. It is very important to complete your pre‐lab.  You are required to show your
assembly code on paper for all the tasks.
B. Lab report is DUE right before the next lab time. The report should include your
names, experiment objectives, experiment problems, the print‐out of your work,
and explanation and discussion.
C. Demonstrate your results to the instructor before you leave. Failure to do so will
result in zero point for performance.
