
.text                                               //Declear string
x_number: .string "Current x value: %d  "           //x value to print
y_number: .string "Current y value: %d  "           //y value to print
min_number: .string "Current minumun: %d\n"         //Current min value to print
number: .string "The minumun of y is :%d\n"         //Number to print out

.balign 4                                           //Ensure that instructions are stored at addresses divisible by 4(the word length of the machine)
.global main                                        //Make "main" visible to linker

define(x_value,x19)                                 //define registers
define(y_value,x20)
define(min_value,x21)
define(t_num,x22)                                   //a temporary number to store the value
define(loop_num,x23)                                //a number for iteration
define(check_min_value,x24)                         //a number guarantee is the first value of y set as the start of min value

main:
    stp x29, x30, [sp, -16]!                        //Store the fp and lr values at the sp.
    mov x29, sp                                     //copy the value of sp to x29
start:
    mov x_value,-10                                 //Set x start at -10
    mov y_value,0                                   //set y start at 0
    mov t_num,0                                     //a temporary number to store the value while the calculating

y_equation:                                         //y = 3x^4-287x^2-63x+37
    mov y_value,0                                   //set y back to 0 in each iteration
    add y_value,y_value,37                          //Add the 37 to y:+37

    mov t_num,-63                                   //Set value to -63
    madd y_value,x_value,t_num,y_value              //Add  value(temporary number value) to y:multiple x by -63

    mov t_num,-287                                  //Set temporary number value to 287
    mul t_num,t_num,x_value                         //multiple x by 287                         
    madd y_value,x_value,t_num,y_value              //Add value(temporary number value) to y://multiple 287x by x

    mov t_num,3                                     //Set temporary number value to 3
    mul t_num,t_num,x_value                         //multiple x by 3
    mul t_num,t_num,x_value                         //multiple 3x by x
    mul t_num,t_num,x_value                         //multiple 3x^2 by x
    madd y_value,x_value,t_num,y_value              //Add above value(temporary number value) to y:multiple 3x^3 by x

    cmp check_min_value,0                           //check if is the first time value set to the min value
    b.ne min_valuecheck                             //if not,then do noting

    mov min_value,y_value                           //otherwise,give the first y value to min value of y to start
min_valuecheck:                                     //A check for min value

    add check_min_value,check_min_value,loop_num    //Add one each time to check is the first time to give y value to min_value

    cmp y_value,min_value                           //if y greater than or equal min value
    b.ge loop                                       //then do noting

    mov min_value,y_value                           //otherwise change min value to y value
loop:
    
    adrp x0,x_number                                //address of the string
    add x0,x0, :lo12:x_number                       //Put arguments into x0 before the call
    mov x1,x_value                                  //Put arguments of x_value into x1 before the call
    bl printf                                       //Print x value

    adrp x0,y_number                                //address of the string
    add x0,x0, :lo12:y_number                       //Put arguments into x0 before the call
    mov x1,y_value                                  //Put arguments of y_value into x1 before the call
    bl printf                                       //Print y value

    adrp x0,min_number                              //address of the string
    add x0,x0, :lo12:min_number                     //Put arguments into x0 before the call
    mov x1,min_value                                //Put arguments of min_value into x1 before the call
    bl printf                                       //Print minumun value

    mov loop_num,1                                  //Set a value for loop
    add x_value,x_value,loop_num                    //add 1 to x each time

    cmp x_value,10                                  //range -10<=x<=10,to see if out of range
    b.gt goto_end                                   //then end the loop                  

    bl y_equation                                   //otherwise,go back to top,Keeping loop
goto_end:
    adrp x0,number                                  //address of the string
    add x0,x0, :lo12:number                         //Put arguments into x0 before the call
    mov x1,x21                                      //Put arguments of min_value into x1 before the call
    bl printf                                       //print the number min value of y
end:
//Programe clean_up and exit
    ldp x29, x30, [sp], 16                          //Get the origianl values of x29 and x30 from back
    mov x0,0                                        //Return code is 0(no errors)
    ret                                             //Free 16 bytes
