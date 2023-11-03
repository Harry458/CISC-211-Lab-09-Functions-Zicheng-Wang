/*** asmMult.s   ***/
/* SOLUTION; used to test C test harness
 * VB 10/14/2023
 */
    
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

#include <xc.h>

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */

.global a_Multiplicand,b_Multiplier,rng_Error,a_Sign,b_Sign,prod_Is_Neg,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0 
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0 
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

 /* Make the following functions globally visible */
.global asmUnpack, asmAbs, asmMult, asmFixSign, asmMain
.type asmUnpack,%function
.type asmAbs,%function
.type asmMult,%function
.type asmFixSign,%function
.type asmMain,%function

/* function: asmUnpack
 *    inputs:   r0: contains the packed value. 
 *                  MSB 16bits is signed multiplicand (a)
 *                  LSB 16bits is signed multiplier (b)
 *              r1: address where to store unpacked, 
 *                  sign-extended 32 bit a value
 *              r2: address where to store unpacked, 
 *                  sign-extended 32 bit b value
 *    outputs:  r0: No return value
 *              memory: 
 *                  1) store unpacked A value in location
 *                     specified by r1
 *                  2) store unpacked B value in location
 *                     specified by r2
 */
asmUnpack:   
    
    /*** STUDENTS: Place your asmUnpack code BELOW this line!!! **************/
    
    PUSH {R4-R11,LR}	@ Push registers R4-R11 and the Link Register (LR) onto the stack.

    MOV R4, R0, ASR 16  @Move the value in R0(packed value) right-shifted (arithmetic) by 16 bits into R4.

    MOV R5, R0, LSL 16  @Move the value in R0(packed value) left-shifted by 16 bits into R5.
    ASR R5, R5, 16	@Right-shift R5 by 16 bits to sign-extend the value.

    STR R4, [R1]        @Store the value in R4 to the memory location pointed to by R1(unpacked A value).
    STR R5, [R2]        @Store the value in R5 to the memory location pointed to by R2(unpacked B value)

    POP {R4-R11,LR}	@Pop the saved registers (R4-R11) and LR from the stack.
    BX LR		@Branch and exchange (return) to the address stored in LR.
    /*** STUDENTS: Place your asmUnpack code ABOVE this line!!! **************/


    /***************  END ---- asmUnpack  ************/

 
/* function: asmAbs
 *    inputs:   r0: contains signed value
 *              r1: address where to store absolute value
 *              r2: address where to store sign bit:
 *                  0 = "+", 1 = "-"
 *    outputs:  r0: Absolute value of r0 input. Same value
 *                  as stored to location given in r1
 *              memory: 
 *                  1) store absolute value in location
 *                     given by r1
 *                  2) store sign bit in location 
 *                     given by r2
 */
asmAbs:  
    /*** STUDENTS: Place your asmAbs code BELOW this line!!! **************/
    PUSH {R4-R11,LR}	@Push registers R4-R11 and the Link Register (LR) onto the stack.

    CMP R0, #0		@Compare the value in signed value with 0.
    BLT negative_number @Branch to negative_number if the result of the comparison is less than (negative).

    MOV R3, #0          @Load the value 0 into R3.
    STR R3, [R2]        @Store the value in R3 to the memory location pointed to by sign bit.

    continus:           @Label for the continuation of the code.

    STR R0, [R1]        @Store the value in abs signed value to the memory location pointed to by R1(absolute value).

    POP {R4-R11,LR}	@Pop the saved registers (R4-R11) and LR from the stack.
    BX LR		@Branch and exchange (return) to the address stored in LR.

    negative_number:	@Label for the negative_number code.

    MOV R3, #1		@Load the value 1 into R3.
    STR R3, [R2]	@Store the value in R3 to the memory location pointed to by sign bit.

    RSB R0, R0, #0	@Reverse subtract R0(signed value) from 0, effectively negating the value in R0.

    B continus         @Unconditional branch to the "continus" label, continuing the code.



    /*** STUDENTS: Place your asmAbs code ABOVE this line!!! **************/


    /***************  END ---- asmAbs  ************/

 
/* function: asmMult
 *    inputs:   r0: contains abs value of multiplicand (a)
 *              r1: contains abs value of multiplier (b)
 *    outputs:  r0: initial product: r0 * r1
 */    
asmMult:   

    /*** STUDENTS: Place your asmMult code BELOW this line!!! **************/
    PUSH {R4-R11,LR}   @ Push registers R4-R11 and the Link Register (LR) onto the stack.
    MOV R5, #0         @ Initialize R5(temp initial product) to 0.

    multiply_loop:
    CMP R1, #0         @ Compare the value in multiplier with 0.
    BEQ multiply_done  @ If multiplier is 0, branch to the multiply_done label.

    ADD R5, R5, R0     @ Add the value in multiplicand to the running total in temp initial product.
    SUB R1, R1, #1     @ Decrement multiplier by 1 (effectively counting down).

    B multiply_loop    @ Branch back to the multiply_loop label to continue the loop.

    multiply_done:
    MOV R0, R5         @ Move the final result in temp initial product to R0(initial product).
    POP {R4-R11,LR}    @ Pop the saved registers (R4-R11) and LR from the stack.
    BX LR              @ Branch and exchange (return) to the address stored in LR.
       

    /*** STUDENTS: Place your asmMult code ABOVE this line!!! **************/
   
    /***************  END ---- asmMult  ************/


    
/* function: asmFixSign
 *    inputs:   r0: initial product: 
 *              (abs value of A) * (abs value of B)
 *              r1: sign bit of originally unpacked value
 *                  of A
 *              r2: sign bit of originally unpacked value
 *                  of B
 *    outputs:  r0: final product:
 *                  sign-corrected version of initial product
 */ 
asmFixSign:   
    
    /*** STUDENTS: Place your asmFixSign code BELOW this line!!! **************/
    PUSH {R4-R11,LR}   @ Push registers R4-R11 and the Link Register (LR) onto the stack.

    CMP R1, R2         @ Compare the values in sign bit a and sign bit b registers.
    BNE opposite_sign  @ Branch to opposite_sign if they are not equal (opposite signs).

    fix_done:          @ Label for the fix_done code.
    POP {R4-R11,LR}    @ Pop the saved registers (R4-R11) and LR from the stack.
    BX LR              @ Branch and exchange (return) to the address stored in LR.

    opposite_sign:     @ Label for the opposite_sign code.
    RSB R0, R0, #0     @ Reverse subtract R0 from 0, effectively negating the value in R0.
    B fix_done         @ Unconditional branch to the fix_done label, completing the operation.
      
    
    /*** STUDENTS: Place your asmFixSign code ABOVE this line!!! **************/


    /***************  END ---- asmFixSign  ************/



    
/* function: asmMain
 *    inputs:   r0: contains packed value to be multiplied
 *                  using shift-and-add algorithm
 *           where: MSB 16bits is signed multiplicand (a)
 *                  LSB 16bits is signed multiplier (b)
 *    outputs:  r0: final product: sign-corrected product
 *                  of the two unpacked A and B input values
 *    NOTE TO STUDENTS: 
 *           To implement asmMain, follow the steps outlined
 *           in the comments in the body of the function
 *           definition below.
 */
asmMain:   
    
    /*** STUDENTS: Place your asmMain code BELOW this line!!! **************/
    
    /* Step 1:
     * call asmUnpack. Have it store the output values in 
     * a_Multiplicand and b_Multiplier.
     */
    PUSH {R4-R11,LR}	     @ Push registers R4-R11 and the Link Register (LR) onto the stack.
    LDR R1,=a_Multiplicand   @ Load the address of the label "a_Multiplicand" into register R1
    LDR R2,=b_Multiplier     @ Load the address of the label "b_Multiplier" into register R2.
    BL asmUnpack	     @ This is a branch with link (BL) instruction to the subroutine called "asmUnpack."

    /* Step 2a:
     * call asmAbs for the multiplicand (A). Have it store the
     * absolute value in a_Abs, and the sign in a_Sign.
     */
    /*inputs:  r0: contains signed value
               r1: address where to store absolute value
               r2: address where to store sign bit:
               0 = "+", 1 = "-"*/
    LDR r0,[r1]		     @ Load the value from the memory address pointed to by r1 into r0.
    LDR r1, =a_Abs	     @ Load the address of a_Abs into R1
    LDR r2, =a_Sign	     @ Load the address of a_Sign into R2
    BL asmAbs		     @ Call asmAbs
    

    /* Step 2b:
     * call asmAbs for the multiplier (B). Have it store the
     * absolute value in b_Abs, and the sign in b_Sign.
     */
    LDR r2,=b_Multiplier     @ Load the address of the label "b_Multiplier" into register R2.
    LDR r0,[r2]		     @ Load the value from the memory address pointed to by r2 into r0.
    LDR r1, =b_Abs	     @ Load the address of b_Abs into R1
    LDR r2, =b_Sign	     @ Load the address of b_Sign into R2
    BL asmAbs                @ Call asmAbs

    /* Step 3:
     * call asmMult. Pass a_Abs as the multiplicand, 
     * and b_Abs as the multiplier.
     * asmMult returns the initial (positive) product in r0.
     * Store the value returned in r0 to mem location 
     * init_Product.
     */
    /*inputs:   r0: contains abs value of multiplicand (a)
    *           r1: contains abs value of multiplier (b)*/
    LDR r4, =a_Abs           @ Load the address of the label "a_Abs" into r4.
    LDR r5, =b_Abs           @ Load the address of the label "b_Abs" into r5.
    LDR r0, [r4]             @ Load the absolute value of the multiplicand (a) from memory into r0.
    LDR r1, [r5]             @ Load the absolute value of the multiplier (b) from memory into r1.
    
    BL asmMult               @ Call asmMult
    LDR R11, =init_Product   @ Load the address of init_Product into R11
    STR r0, [R11]            @ Store the initial product in mem location init_Product


    /* Step 4:
     * call asmFixSign. Pass in the initial product, and the
     * sign bits for the original a and b inputs. 
     * asmFixSign returns the final product with the correct
     * sign. 
     * Store the value returned in r0 to mem location 
     * final_Product.
     */
     /*    inputs:   r0: initial product: 
 *              (abs value of A) * (abs value of B)
 *              r1: sign bit of originally unpacked value
 *                  of A
 *              r2: sign bit of originally unpacked value
 *                  of B*/
    LDR r4, =init_Product     @ Load the address of the label "init_Product" into r4.
    LDR r5, =a_Sign           @ Load the address of the label "a_Sign" into r5.
    LDR r6, =b_Sign           @ Load the address of the label "b_Sign" into r6.
    LDR r0, [r4]              @ Load the initial product from memory into r0.
    LDR r1, [r5]              @ Load the sign bit of the originally unpacked value of a_Sign into r1.
    LDR r2, [r6]              @ Load the sign bit of the originally unpacked value of b_Sign into r2.
    
    BL asmFixSign             @ Call asmFixSign

    LDR R11, =final_Product   @ Load the address of final_Product into R11
    STR r0, [R11]             @ Store the final product in mem location final_Product


    /* Step 5:
     * END! Return to caller. Make sure of the following:
     * 1) Stack has been correctly managed.
     * 2) the final answer is stored in r0, so that the C call
     *    can access it.
     */
    POP {R4-R11,LR}    @ Pop the saved registers (R4-R11) and LR from the stack.
    BX LR	       @ Branch and exchange (return) to the address stored in LR.

    
    /*** STUDENTS: Place your asmMain code ABOVE this line!!! **************/


    /***************  END ---- asmMain  ************/

 
    
    
.end   /* the assembler will ignore anything after this line. */
