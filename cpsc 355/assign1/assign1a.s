//UCID:30120288 Name:Aoqi Li                
.text                                               //Declear string
x_number: .string "Current x value: %d  "           //x value to print
y_number: .string "Current y value: %d  "           //y value to print
min_number: .string "Current minumun: %d\n"         //Current min value to print
number: .string "The minumun of y is :%d\n"         //Number to print out

.balign 4                                           //Ensure that instructions are stored at addresses divisible by 4(the word length of the machine)
.global main                                        //Make "main" visible to linker

main:
    stp x29, x30, [sp, -16]!                        //Store the fp and lr values at the sp.
    mov x29, sp                                     //copy the value of sp to x29
start:
    mov x19,-10                                     //Set x start at -10
    mov x20,0                                       //set y start at 0
    mov x21,0                                       //Min value of y
    mov x22,0                                       //a temporary number to sum the value while the calculating
    mov x23,1                                       //Set a value for iteration
    mov x24,0                                       //a number guarantee is the first value of y set as the start of min value

y_equation:                                         //y = 3x^4-287x^2-63x+37
    add x19,x19,x23                                 //add 1 to x for each iteration

    cmp x19,10                                      //range -10<=x<=10,if out of range(x>10):pre-test loop at top
    b.gt goto_end                                   //then end the loop

    mov x20,0                                       //set y back to 0
    add x20,x20,37                                  //Add the 37 to y:+37

    mov x22,-63                                     //Set value to -63
    mul x22,x19,x22                                 //multiple x by -63
    add x20,x20,x22                                 //Add above value to y:-63x

    mov x22,0                                       //Set temporary number back to 0
    mov x22,-287                                    //Set value to 287
    mul x22,x22,x19                                 //multiple x by 287
    mul x22,x22,x19                                 //multiple 287x by x
    add x20,x20,x22                                 //Add above value to y:-287x^2

    mov x22,0                                       //Set temporary number back to 0
    mov x22,3                                       //Set value to 3
    mul x22,x22,x19                                 //multiple x by 3
    mul x22,x22,x19                                 //multiple 3x by x
    mul x22,x22,x19                                 //multiple 3x^2 by x
    mul x22,x22,x19                                 //multiple 3x^3 by x
    add x20,x20,x22                                 //Add above value to y:3x^4

    cmp x24,0                                       //check if is the first time value set to the min value
    b.ne min_valuecheck                             //if not,then do noting

    mov x21,x20                                     //otherwise,give the first y value given to min value of y
min_valuecheck:                                     //A check for min value

    add x24,x24,x23                                 //Add one each time to check is the first time to give y value to min_value
                                                    //Pre-test loop at bottom
    cmp x20,x21                                     //if y greater than or equal min value
    b.ge loop                                       //then do noting

    mov x21,x20                                     //otherwise change min value to y value
loop:
    adrp x0,x_number                                //address of the string
    add x0,x0, :lo12:x_number                       //Put arguments into x0 before the call
    mov x1,x19                                      //Put arguments of x_value into x1 before the call
    bl printf                                       //Print x value

    adrp x0,y_number                                //address of the string
    add x0,x0, :lo12:y_number                       //Put arguments into x0 before the call
    mov x1,x20                                      //Put arguments of y_value into x1 before the call
    bl printf                                       //Print y value

    adrp x0,min_number                              //address of the string
    add x0,x0, :lo12:min_number                     //Put arguments into x0 before the call
    mov x1,x21                                      //Put arguments of min_value into x1 before the call
    bl printf                                       //Print minumun value

    bl y_equation                                   //Keep going
goto_end:
    adrp x0,number                                  //address of the string
    add x0,x0, :lo12:number                         //Put arguments into x0 before the call
    mov x1,x21                                      //Put arguments of min_value into x1 before the call
    bl printf                                       //print the number min value of y
end:
//Programe clean_up and exit
    ldp x29, x30, [sp], 16                           //Get the origianl values of x29 and x30 from back
    mov x0,0                                         //Return code is 0(no errors)
    ret                                              //Free 16 bytes