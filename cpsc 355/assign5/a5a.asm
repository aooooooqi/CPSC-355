define(top_r,w19)
define(stack_r,x20)
define(STACKSIZE,5)
define(FALSE,0)
define(TRUE,1)

        .data
        .global stack
		.global top
top:    .word   -1
stack:  .skip   STACKSIZE*4

	.text
overflow: 	.string	"\nStack overflow! Cannot push value onto stack.\n"
underflow:  .string "\nStack underflow! Cannot pop an empty stack.\n"
empty: 		.string "\nEmpty stack\n"
current: 	.string "\nCurrent stack contents:\n"
topStack: 	.string " <-- top of stack"
fmt1: 		.string " %d"
fmt2: 		.string "\n"

fp      .req    x29
lr      .req    x30

        .balign 4                       	// Ensure that instructions are stored at addresses divisible by 4 (the word length of the machine)
											// make sure that the main label is picked by the linker
							        		// make sure that the main label is picked by the linker
		.global push						// make "push" a global symbol
		.global pop							// make "pop" a global symbol 
		.global display						// make "display" a global symbol
		.global stackFull					// make "stackFull" a global symbol
											// make sure that the main label is picked by the linker
//Define push function
define(value,w1)
push:   
    stp     fp, lr, [sp, -16]!      		// Save frame pointer (fp) and link register (lr) to the stack
    mov     lr, sp                  		// Set fp to the top of the stack
											// argment pass by w0
	mov 	value,w0						// copy the argment value to w1

	mov 	w0,0							// set w0 back to 0
    bl      stackFull						// call function stackFull
	cmp 	w0,TRUE							// check 
	b.ne 	storeValue_inStack

    adrp 	x0, overflow                	// Get address of format string
	add 	x0, x0, :lo12:overflow	    	//  + lower bits
	bl 		printf                          // call function:printf
	b 		push_exit

storeValue_inStack:
	adrp 	x21,top							// Calculate the address of label
	add		x21,x21, :lo12:top				// + lower bits

    ldr     top_r,[x21]						// top_r = top
    add     top_r,top_r,1					// ++top
    str     top_r,[x21]						// change global value top to top_r

	adrp	stack_r,stack					// Calculate the address of label
	add 	stack_r,stack_r, :lo12:stack	//  + lower bits

    str     value,[stack_r,top_r,sxtw 2]	//  store value into global value stack arrary

push_exit:
    ldp     fp, lr, [sp], 16        		// Restore the stack
    ret                             		// Return to OS

//define pop function
define(r_value,w1)
pop:
	stp 	fp,lr,[sp,-16]!                 // Save frame pointer (fp) and link register (lr) to the stack
	mov 	fp,sp                           // Set fp to the top of the stack

	mov 	w0,0							// initialize
	bl 		stackEmpty						// call function stackEmpty
	cmp 	w0,TRUE							// if is TRUE
	b.ne	pop_else						// else:jump to pop_else

	adrp  	x0,underflow					// Get address of format string
	add 	x0,x0, :lo12:underflow			//  + lower bits
	bl 		printf							// call function:printf

	mov		w0,-1							// return by -1
	b 	 	pop_exit						// jump to exit

pop_else:
	adrp 	x21,top							// Calculate the address of label
	add		x21,x21, :lo12:top				// + lower bits

	ldr     top_r,[x21]						// load global value top to top_r

	adrp	stack_r,stack					// Calculate the address of label
	add 	stack_r,stack_r, :lo12:stack	// + lower bits

	ldr		r_value,[stack_r,top_r,sxtw 2]	// load value form stack_r

	ldr     top_r,[x21]						// load global top to top_r
    add     top_r,top_r,-1					// top--
    str     top_r,[x21]						// change the global value top

	mov 	w0,r_value						// return by w0
pop_exit:	
	ldp 	fp,lr,[sp],16                 	// Restore the stack
	ret                                     // Return to OS
//define function stack stackEmpty
stackEmpty:
	stp     fp, lr, [sp, -16]!      		// Save frame pointer (fp) and link register (lr) to the stack
    mov     lr, sp                  		// Set fp to the top of the stack

	adrp 	x21,top							// Calculate the address of label
	add		x21,x21, :lo12:top				//  + lower bits

	ldr     top_r,[x21]						// load global value top to top_r
	
	cmp 	top_r,-1						// if top == -1
	b.ne	stackEmpty_else					// else:jump to stackEmpty_else	

	mov 	w0,TRUE							// return TRUE
	b 		stackEmpty_exit					// exit

stackEmpty_else:
	mov 	w0,FALSE						// return FALSE

stackEmpty_exit:
	ldp     fp, lr, [sp], 16        		// Restore the stack
    ret                             		// Return to OS
	
//define function stack stackFull
stackFull:
    stp     fp, lr, [sp, -16]!     	 		// Save frame pointer (fp) and link register (lr) to the stack
    mov     lr, sp                  		// Set fp to the top of the stack

	mov		w0,STACKSIZE					// Set w0,STACKSIZE
	add 	w0,w0,-1						// STACKSIZE - 1

	adrp 	x21,top							// Calculate the address of label
	add		x21,x21, :lo12:top				// + lower bits

	ldr     top_r,[x21]						// load global value top to top_r

	cmp 	w0,top_r						// if (top == STACKSIZE - 1)
	b.ne 	stackFull_else					// else: jump to stackFull_else

	mov 	w0,TRUE							// return TRUE
	b 	 	stackFull_exit					// exit

stackFull_else:
	mov 	w0,FALSE						// Return FALSE

stackFull_exit:
    ldp     fp, lr, [sp], 16        		// Restore the stack
    ret                             		// Return to OS


//define display
define(i,w22)
display:
	stp 	fp,lr,[sp,-16]!                 // Save frame pointer (fp) and link register (lr) to the stack
	mov 	fp,sp                           // Set fp to the top of the stack
	
	bl 		stackEmpty						// call function stackEmpty
	cmp 	w0,TRUE							// if TRUE
	b.ne 	display_else					// else:jump to display_else

	adrp 	x0, empty                	    // Get address of format string
	add 	x0, x0, :lo12:empty	    	 	//  + lower bits
	bl 		printf                          // call function:printf
	b 		display_end						// jump to display_end

display_else:
	adrp 	x0, current               	   	// Get address of format string
	add 	x0, x0, :lo12:current	    	//  + lower bits
	bl 		printf                          // call function:printf

	adrp 	x21,top							// Calculate the address of label
	add		x21,x21, :lo12:top				// + lower bits

	ldr     top_r,[x21]						// load global value top to top_r
	mov 	i,top_r							// set i == top
i_loop:
	adrp 	x0, fmt1               	   		// Get address of format string
	add 	x0, x0, :lo12:fmt1 	    	 	//  + lower bits

	adrp	stack_r,stack					// Calculate the address of label
	add 	stack_r,stack_r, :lo12:stack	// + lower bits
	ldr 	w1,[stack_r,i,sxtw 2]			// load stack[i] into w1
	bl 		printf							// call function

	cmp 	i,top_r							// if i == top
	b.ne	print_n							// else:jump to print_n(skip to print topStack)

	adrp 	x0,topStack						// Get address of format string
	add 	x0,x0, :lo12:topStack			// + lower bits
	bl  	printf							// call function:printf

print_n:
	adrp 	x0,fmt2							// Get address of format string
	add 	x0,x0, :lo12:fmt2				// + lower bits
	bl  	printf							// call function:printf

	add 	i,i,-1							// i--
iLoop_test:
	cmp 	i,0								// check if i <= 0
	b.ge 	i_loop							// otherwise,keep loop
display_end:
	ldp 	fp,lr,[sp],16                   // Restore the stack
	ret                                     // Return to OS


// 下面的是正确使用call-saved 例子
define(TRUE, 1)
define(FALSE, 0)

define(top_base_r, x19)
define(stack_base_r, x20)
define(top_r, w21)

        .data
        .global top
top:    .word   -1
        .global stack
stack:  .skip 5 * 4

        .text
fmt:    .string "\nStack overflow! Cannot push value onto stack.\n"

fp      .req    x29
lr      .req    x30

        .balign 4
register_size = 8
alloc   = -(16 + 4 * register_size) & -16
x19_s   = 16
x20_s   = 24
x21_s   = 32
x22_s   = 40
dealloc = -alloc
        .global push 
push:   stp     fp, lr, [sp, alloc]!      // Save frame pointer (fp) and link register (lr) to the stack
        mov     lr, sp                  // Set fp to the top of the stack

        // We are going to use x19 to store the address of top,
        // x20 to store the address of stack, w21 to store the value of top,
        // and w22 to store the argument we were given in w0
        // As such, let's save their state on the stack in case somebody else wanted to use them
        str     x19, [fp, x19_s]
        str     x20, [fp, x20_s]
        str     x21, [fp, x21_s]
        str     x22, [fp, x22_s]

        mov     w22, w0                 // Save the argument we got to this function

        bl      stackFull               // Call stackFull
        cmp     w0, TRUE                // Compare return code to 0
        b.ne    else                    // If stackEmpty() != 0 skip the if-statment body

        // Print out the error message
        adrp    x0, fmt
        add     x0, x0, :lo12:fmt
        bl      printf

        b       push_end                // Branch to the end of the function

else:   
        // Load the address of top
        adrp    top_base_r, top
        add     top_base_r, top_base_r, :lo12:top

        ldr     top_r, [top_base_r]     // Get the current value of top
        
        // Load the address of 'stack'
        adrp    stack_base_r, stack
        add     stack_base_r, stack_base_r, :lo12:stack

        add     top_r, top_r, 1           // top++
        str     top_r, [top_base_r]       // Store top

        // stack[top] = value
        str     w22, [stack_base_r, top_r, sxtw 2]

push_end:
        // Restore the state of all calle-saved registers
        ldr     x19, [fp, x19_s]
        ldr     x20, [fp, x20_s]
        ldr     x21, [fp, x21_s]
        ldr     x22, [fp, x22_s]

        ldp     fp, lr, [sp], dealloc   // Restore the stack
        ret                             // Return to OS
