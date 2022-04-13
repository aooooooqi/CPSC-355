//UCID:30120288 Name:Aoqi Li
fp      .req x29
lr      .req x30
.text                                               // Declear string
                                                    // Number to print out
random_values: .string "v[%d]: %d\n"                // random value store in v
print_message: .string "\nSorted array:\n"          // print remaind
sorted_array: .string "v[%d]: %d\n"                 // Print out the sorted array

.balign 4                                           // Find the first address that appears as an integer multiple of 4
.global main                                        // Make "main" a global symbol
define(SIZE,50)
                                                    
define(base_address,x19)                            // base_address must be 64 bit
                                                    // define 32-bit registers
define(i,w20)                                       // i for iteration
define(j,w21)                                       // j for iteration
define(temp,w22)                                    // a temporary number
                                                    // Define equates for variable sizes
        i_size = 4                                  // 4 bit elements
        j_size = 4
        temp_size = 4
        v_size = SIZE*4                             // store 50 elements

        // Allocate enough memory for the array + frame record
        allocate = -(16 + i_size + j_size + temp_size + v_size) & -16
        deallocate = -allocate

        // Define equates for variable offsets
        i_s = 16
        j_s = 20
        temp_s = 24
        v_array = 28

main:
    stp fp, lr, [sp, allocate]!                      // Store the fp and lr values at the sp.
    mov fp, sp                                       // copy the value of sp to x29
                                                    
    add base_address,fp,v_array                      // Calculate array base address
set_i1:
    mov i,0                                          // set i = 0
    str i,[fp,i_s]                                   // i start at 0
rloop_top:

    bl random                                        // Call random function
                                                     // random value would store in w0 or x0,set v[i] = w0
    and w0,w0,0xFF                                   // And v[i] 0xFF
    str w0,[base_address,i,sxtw 2]                   // extend first

    adrp x0,random_values                            // Set first argument to printf
    add x0,x0, :lo12:random_values                   // Set the first argument to printf (lower bits)
    ldr w1,[fp,i_s]                                  // Second arg for printf
    ldr w2,[base_address,w1,sxtw 2]                  // load the the value v[i] from memory
    bl printf                                        // Call the function printf
                                                     // to read the array number by + i*4
    // i++
    ldr i,[fp,i_s]                                   // load the i in the memory
    add i,i,1                                        // add 1 for each time iteration
    str i,[fp,i_s]                                   // store i into memory

rloop_test:                                          // loop test
    ldr i,[fp,i_s]                                   // load i from memory
    cmp i,SIZE                                       // cmpare i with SIZE(50)
    b.lt rloop_top                                   // if less than SIZE, then keep loop

set_i2:
    mov i,1                                          // set i = 1
    str i,[fp,i_s]                                   // store i into memory ,i start at 1

sloop_top:                                           // sort loop 
    ldr i,[fp,i_s]                                   // load i from memory
    ldr temp,[base_address,i,sxtw 2]                 // load temp from memory
    str temp,[fp,temp_s]                             // store the temp  into memory in temp_s location

set_j:
    ldr i,[fp,i_s]                                   // load i from memory     
    str i,[fp,j_s]                                   // j = i;store i value into j_s location
jloop_top:                                           // loop for insertion
    
    ldr j,[fp,j_s]                                   // load j from memory
    cmp j,0                                          // compare j with 0
    b.le load_temp                                   // if <= 0,then stop the current loop

    ldr j,[fp,j_s]                                   // load j from memory
    sub j,j,1                                        // j = j -1
    str j,[fp,j_s]                                   // change value in the j_s in the memory
  
    ldr w0,[base_address,j,sxtw 2]                   // read the value v[j-1] store value in wo
    
    ldr j,[fp,j_s]                                   // load j from memory
    add j,j,1                                        // add back j,j = j + 1
    str j,[fp,j_s]                                   // save the change at j into memory
    ldr temp,[fp,temp_s]                             // load the temp from memory
    
    cmp temp,w0                                      // cmpare temp with v[j-1]
    b.ge load_temp                                   // stop the current loop  
    
    str w0,[base_address,j,sxtw 2]                   // stroe v[j-1] into v[j] in the memory
    // j--
    ldr j,[fp,j_s]                                   // load j from memory
    sub j,j,1                                        // j = j -1
    str j,[fp,j_s]                                   // store j into memory

    b jloop_top                                      // back to jloop_top

load_temp:                                           // set v[j] = temp
    ldr temp,[fp,temp_s]                             // load temp from memory
    ldr j,[fp,j_s]                                   // load j from memory for v[j]
    str temp,[base_address,j,sxtw 2]                 // store temp into v[j] in memory
    // i++
    ldr i,[fp,i_s]                                   // load i from memory
    add i,i,1                                        // i = i + 1
    str i,[fp,i_s]                                   // stroe i into memory

sloop_test:                                          
    ldr i,[fp,i_s]                                   // load i from memory
    cmp i,SIZE                                       // cmpare i with SIZE(50)
    b.lt sloop_top                                   // if b less than 50, then keep loop

print_array:
    adrp x0,print_message                            // Set first argument to printf
    add x0,x0, :lo12:print_message                   // Set the first argument to printf (lower bits)
    bl printf                                        // call function printf 
set_i3:
    mov i,0                                          // set i = 0
    str i,[fp,i_s]                                   // store i into memory,i start at 1

ploop_top:  
    adrp x0,sorted_array                             // Set first argument to printf
    add x0,x0, :lo12:sorted_array                    // Set the first argument to printf (lower bits)
    ldr w1,[fp,i_s]                                  // load Second arg for printf
    ldr w2,[base_address,w1,sxtw 2]                  // load the the value v[i] from memory
    bl printf                                        // call function printf
    // i++
    ldr i,[fp,i_s]                                   // load i from memory
    add i,i,1                                        // i = i + 1
    str i,[fp,i_s]                                   // stroe i into memory

ploop_test:
    ldr i,[fp,i_s]                                   // load i from memory
    cmp i,SIZE                                       // compare i with size
    b.lt ploop_top                                   // if i < 50,keep loop
end:
    ldp fp, lr, [sp], deallocate                     // Get the origianl values of x29 and x30 from back
    mov x0,0                                         // Set back to zero
    ret   
