//UCID:30120288 Name:Aoqi Li
.text                                               //Declear string
                                                    //Number to print out
initialvalues: .string "multiplier = 0x%08x (%d)  multiplicand = 0x%08x (%d)\n\n"
productandmultiplier_print: .string "product = 0x%08x multiplier = 0x%08x\n"
results_print: .string "64-bit result = 0x%016lx (%ld)\n"

.balign 4                                           //Find the first address that appears as an integer multiple of 4
.global main                                        //make "main" a global symbol
                                                    //define registers
                                                    // 32-bit registers
define(multiplier,w19)                              //multiplier
define(multiplicand,w20)                            //multiplicand
define(product,w21)                                 //product
define(i,w22)                                       //a number for iteration
define(negative,w23)                                //check for if is negative
                                                    // 64-bit registers
define(result,x19)                                  //result
define(temp1,x20)                                   //temp1
define(temp2,x21)                                   //temp2

main:
    stp x29, x30, [sp, -16]!                        //Store the fp and lr values at the sp.
    mov x29, sp                                     //copy the value of sp to x29
                                                    //Initialize variables
    mov multiplicand,-16843010                      //Given value 522133279  to variable multiplicand
    mov multiplier,70                               //Given value 200 to variable multiplier
    mov product,0                                   //Given value 0 to product
                                                    //Print out initial values of variables
    adrp x0,initialvalues                           //address of the string
    add x0,x0, :lo12:initialvalues                  //Put arguments into x0 before the call
    mov w1,multiplier                               //Put arguments of multiplier into w1 before the call
    mov w2,multiplier                               //Print the multiplier 
    mov w3,multiplicand                             //Print the multiplicand in 0x%08x
    mov w4,multiplicand                             //Print the multiplicand
    bl printf                                       //Print the initial values of variables

    cmp multiplier,0                                //if (multiplier < 0)
    b.lt negative_check                             //otherwise

    mov negative,0                                  //negative = FALSE
    b loop                                          //Skip the next label
negative_check:                                     //else:
    mov negative,1                                  //negative = TRUE
loop:
    tst multiplier,0x1                              //And multiplier 0001
    b.eq shift_right                                //if results in zero,then do nothing

    add product,product,multiplicand                //product = product + multiplicand
shift_right:            
    asr multiplier,multiplier,1                     //Arithmetic shift right the multiplier
    
    tst product,0x1                                 //And product 0001
    b.eq otherwise                                  //if results in zero,then go to the otherwise label

    orr multiplier,multiplier,0x80000000            //Or multiplier 0x80000000
    b sright_product                                //Skip the next label
otherwise:
    and multiplier,multiplier,0x7FFFFFFF            //And multiplier 0x7FFFFFFF
    
sright_product:
    asr product,product,1                           //Arithmetic shift right the combined product

    add i,i,1                                       //Each iteration add 1
    cmp i,32                                        //Loop up to 32 times
    b.ge adjust                                     //If over 32 times then end the loop
    b loop                                          //go back to the loop label

adjust:                                             //Adjust product register if multiplier is negative
    cmp negative,1                                  //if negative is true
    b.ne printout                                   //otherwise do nothing
    
    sub product,product,multiplicand                //then product = product - multiplicand
printout:
    adrp x0,productandmultiplier_print                           //address of the string
    add x0,x0, :lo12:productandmultiplier_print                  //Put arguments into x0 before the call
    mov w1,product                                  //Put arguments of product into w1 before the call
    mov w2,multiplier
    bl printf                                       //Print  product value in %08x
                                                    //Combine product and multiplier together
    sxtw temp1,product                              //Sign-extends bit 31 product to bits 32-63
    and temp1,temp1,0xFFFFFFFF                      //and temp1 0xFFFFFFFF
    lsl temp1,temp1,32                              //logical shift left 32 

    sxtw temp2,multiplier                           //Sign-extends bit 31 multiplier to bits 32-63
    and temp2,temp2,0xFFFFFFFF                      //and temp2 0xFFFFFFFF
    add result,temp1,temp2                          //result = temp1 + temp2

    adrp x0,results_print                          //address of the string
    add x0,x0, :lo12:results_print                //Put arguments into x0 before the call
    mov x1,result                                   //Put arguments of result into x1 before the call
    mov x2,result
    bl printf                                       //Print result value in 0x%016lx

end:
    ldp x29, x30, [sp], 16                          //Get the origianl values of x29 and x30 from back
    mov x0,0                                        //Set back to zero
    ret                                             //Free 16 bytes