//UCID:30120288 Name:Aoqi Li

fp      .req x29
lr      .req x30
								                        // Declear string
                                                        // Message to print out
Initail_mes: .string "Initial box value:\n"     
print_box: .string "Box %s origin = (%d, %d) width = %d height = %d area = %d\n"
change_value: .string "\nChanged box values:\n"
name_first: .string "first"
name_second: .string "second"
.balign 4                                               // Ensure that instructions are stored at addresses divisible by 4
define(FALSE,0)
define(TRUE,1)

define(w19,deltaX)
define(w20,deltay)

	rec_x  = 0					    					    // 4 bytes,offset = 0
	rec_y  = 4					    					    // 4 bytes,offset = 4
	point_struct_size = 8				 	    		    // 8 bytes

	rec_width = 0                                           // 4 bytes,offset = 0
	rec_height = 4                                          // 4 bytes,offset = 0
	dimension_struct__size  = 8                             // 8 bytes

	area_size = 4                                           // 4 bytes
	box_struct_size = 8 + 8 + 4                             // struct size of box

	alloc = -(16 + box_struct_size) & -16                   // alloc size 
	dealloc = -alloc
// offset in struct box
origin_in_box_s = 0                                     // 8 bytes,offset = 0
dimension_in_box_s = 8                                  // 8 bytes,offset = 8
area_in_box_s = 16

newBox:                                                 // define newBox function
	stp 	fp,lr,[sp,alloc]!                           // Save frame pointer (fp) and link register (lr) to the stack
	mov 	fp,sp                                       // Set fp to the top of the stack

	add 	x9,fp,box_struct_size						// Compute the base address of box struct
	
	mov 	w0,0										// Store x and y
	str 	w0,[x9,origin_in_box_s + rec_x]				// b.origin.x = 0
	str 	w0,[x9,origin_in_box_s + rec_y]				// b.origin.y = 0

	mov 	w0,1										// Store width and height
	str 	w0,[x9,dimension_in_box_s + rec_width]		// b.size.width = 1
	str 	w0,[x9,dimension_in_box_s + rec_height]		// b.size.height = 1
	
	ldr 	w0,[x9,dimension_in_box_s + rec_width]		// load b.size.width
	ldr 	w1,[x9,dimension_in_box_s + rec_height]		// load b.size.height
	
	mul 	w0,w0,w1									// b.size.width * b.size.height
	str 	w0,[x9,area_in_box_s]						// store b.area = b.size.width * b.size.height into area_in_box_s memory
	
	// will copy all elements of the struct into the address pointed to x8
	ldr 	w10,[x9,origin_in_box_s + rec_x]			// Load x
	str 	w10,[x8,origin_in_box_s + rec_x]			// store x
	ldr 	w10,[x9,origin_in_box_s + rec_y]			// Load y
	str 	w10,[x8,origin_in_box_s + rec_y]			// Store y
	ldr 	w10,[x9,dimension_in_box_s + rec_width]		// Load width
	str 	w10,[x8,dimension_in_box_s + rec_width]		// Store width
	ldr 	w10,[x9,dimension_in_box_s + rec_height]	// Load height
	str 	w10,[x8,dimension_in_box_s + rec_height]	// Store height
	ldr 	w10,[x9,area_in_box_s]						// Load height
	str 	w10,[x8,area_in_box_s]						// Store height

	ldp 	fp,lr,[sp],dealloc                          // Restore the stack
	ret                                                 // Return to OS

//define int varibles
define(deltaX,w2)
define(deltay,w3)
move:                                                   // define move function
	stp 	fp,lr,[sp,alloc]!                           // Save frame pointer (fp) and link register (lr) to the stack
	mov 	fp,sp                                       // Set fp to the top of the stack

    mov     deltaX,w0                                   // set value to deltaX (passed as parameter to function)
    mov     deltay,w1                                   // set value to deltaY (passed as parameter to function)

	ldr		w0,[x8,origin_in_box_s + rec_x]				// Load the x in b.origin
	add 	w0,w0,deltaX                                // b->origin.x += deltaX;
	str		w0,[x8,origin_in_box_s + rec_x]             // store/change the x in b.origin

	ldr		w0,[x8,origin_in_box_s + rec_y]             // Load the y in b.origin
	add 	w0,w0,deltay                                // b->origin.y += deltaY;
	str 	w0,[x8,origin_in_box_s + rec_y]             // store/change the y in b.origin

	ldp 	fp,lr,[sp],dealloc                          // Restore the stack
	ret                                                 // Return to OS

define(factor,w2)
expand:                                                 // define expand function
	stp 	fp,lr,[sp,alloc]!                           // Save frame pointer (fp) and link register (lr) to the stack
	mov 	fp,sp                                       // Set fp to the top of the stack

    mov     factor,w0                                   // set value to factor (passed as parameter to function)
	ldr		w0,[x8,dimension_in_box_s + rec_width]		// Load the width in b.dimension
	mul 	w0,w0,factor                                // b->size.width *= factor
	str		w0,[x8,dimension_in_box_s + rec_width]      // store the width in b.dimension

	ldr		w0,[x8,dimension_in_box_s + rec_height]     // Load the height in b.dimension
	mul 	w0,w0,factor                                // b->size.height *= factor
	str 	w0,[x8,dimension_in_box_s + rec_height]     // store the height in b.dimension

	ldr 	w0,[x8,dimension_in_box_s + rec_width]      // Load the width in b.dimension
	ldr 	w1,[x8,dimension_in_box_s + rec_height]     // Load the height in b.dimension
	mul 	w0,w0,w1                                    // b->area = b->size.width * b->size.height
	str 	w0,[x8,area_in_box_s]                       // store the height in b.area

	ldp 	fp,lr,[sp],dealloc                          // Restore the stack
	ret                                                 // Return to OS

printBox:                                               // define printBox function
	stp 	fp,lr,[sp,alloc]!                           // Save frame pointer (fp) and link register (lr) to the stack
	mov 	fp,sp                                       // Set fp to the top of the stack
    
	ldr 	w2,[x8,origin_in_box_s + rec_x]				// Third arg: x
	ldr 	w3,[x8,origin_in_box_s + rec_y]				// Third arg: y
	ldr 	w4,[x8,dimension_in_box_s + rec_width]		// Fourth  arg: width
	ldr 	w5,[x8,dimension_in_box_s + rec_height]		// Fourth  arg: height
	ldr 	w6,[x8,area_in_box_s]						// 5th arg: area

	mov 	x1,x0										// Second arg: Format string we were given
	adrp 	x0, print_box                				// Get address of format string
	add 	x0, x0, :lo12:print_box      				//  + lower bits
	bl 		printf                                      // call function:printf

	ldp 	fp,lr,[sp],dealloc                          // Restore the stack
	ret                                                 // Return to OS
define(result,w22)
equal:                                                  // define printBox function
	stp 	fp,lr,[sp,alloc]!                           // Save frame pointer (fp) and link register (lr) to the stack
	mov 	fp,sp                                       // Set fp to the top of the stack
    // x8 is the first_s, x9 is the second_s
	ldr		w0,[x8,origin_in_box_s + rec_x]		        // load b1->origin.x
	ldr 	w1,[x9,origin_in_box_s + rec_x]             // load b2->origin.x
	Cmp 	w0,w1                                       // compare b1->origin.x and b2->origin.x
	b.ne 	set_false                                   // if not equal,then exit with FALSE

	ldr		w0,[x8,origin_in_box_s + rec_y]             // load b1->origin.y
	ldr 	w1,[x9,origin_in_box_s + rec_y]	            // load b2->origin.y
	cmp 	w0,w1                                       // compare b1->origin.y and b2->origin.y
	b.ne	set_false                                   // if not equal,then exit with FALSE

	ldr 	w0,[x8,dimension_in_box_s + rec_width]      // load b1->size.width
	ldr 	w1,[x9,dimension_in_box_s + rec_width]      // load b2->size.width
	cmp 	w0,w1                                       // compare b1->size.width and b2->size.width
	b.ne	set_false                                   // if not equal,then exit with FALSE

	ldr 	w0,[x8,dimension_in_box_s + rec_height]     // load b1->size.height
	ldr 	w1,[x9,dimension_in_box_s + rec_height]     // load b2->size.height
	cmp 	w0,w1                                       // compare b1->size.height and b2->size.height
	b.ne	set_false                                   // if not equal,then exit with FALSE

	mov 	result,TRUE                                 // set result TRUE
    mov     w0,result                                   // return by w0
	b 		end                                         // jump to end

set_false:
	mov 	result,FALSE                                // set result TRUE
    mov     w0,result                                   // return by w0

end:
	ldp 	fp,lr,[sp],dealloc                          // Restore the stack
	ret                                                 // Return to OS

        //define the size of box_struct_size to first and second
        first_size = box_struct_size
        second_size = box_struct_size
        alloc = -(16 + first_size + second_size)& -16
        dealloc = -alloc
        first_s = 16                                     // bytes = 20,offset = 16
        second_s  = 16 + box_struct_size                 // bytes = 20,offset = 36

.global main                                             // Make "main" a global symbol

main:
	stp 	fp, lr, [sp, alloc]!                         // Store the fp and lr values at the sp.
	mov 	fp, sp                                       // copy the value of sp to x29
	
	add 	x8,fp,first_s                                // Set indirect result register           
	bl 		newBox                                       // call the function: newBox

	add 	x8,fp,second_s                               // Set indirect result register 
	bl		newBox                                       // call the function: newBox

	adrp 	x0,Initail_mes                               // Set first arg: Initail_mes
	add 	x0,x0, :lo12:Initail_mes                     // + lower bits
	bl 		printf                                       // call function:printf 

	adrp    x0, name_first           				     // Set first arg: first name
    add     x0, x0, :lo12:name_first     		         //  + lower bits
    add     x8, fp, first_s      					     // Second arg is the address of the struct on the stack
    bl      printBox	              				     // Call printBox

	adrp    x0, name_second          				     // Set first arg: second name
    add     x0, x0, :lo12:name_second    		         //  + lower bits
    add     x8, fp, second_s      					     // Second arg is the address of the struct on the stack
    bl      printBox	              				     // Call printBox
    
box_dispose:
	add 	x8,fp,first_s                                // Pass argument struct box *b1
	add 	x9,fp,second_s                               // Pass argument struct box *b2
	bl		equal                                        // call the function:equal

	cmp 	w0,FALSE                                     // check the result is FALSE or TRUE
	b.eq 	changed_box                                  // if equal FALSE,then do not move or expand
	
	add 	x8,fp,first_s                                // Set indirect result register
	ldr 	w0, =-5                                      // set the deltaX value to -5
	ldr 	w1, =7                                       // set the deltaY value to 7
	bl 		move                                         // call the function: move

	add		x8,fp,second_s                               // Set indirect result register
	ldr 	w0, =3                                       // set the factor value to 3
	bl 		expand                                       // call the function: factor

changed_box:                                            
	adrp 	x0,change_value                              // Set first arg: change_value
	add 	x0,x0, :lo12:change_value                    // + lower bits
	bl 		printf                                  	 // call function:printf

	adrp    x0, name_first           				     // Set first arg: first name
    add     x0, x0, :lo12:name_first     		         //  + lower bits
    add     x8, fp, first_s      					     // Second arg is the address of the struct on the stack
    bl      printBox	              				     // Call printBox

	adrp    x0, name_second          				     // Set first arg: second name
    add     x0, x0, :lo12:name_second    		         //  + lower bits
    add     x8, fp, second_s      					     // Second arg is the address of the struct on the stack
    bl      printBox	              				     // Call printBox
	
    ldp 	fp, lr, [sp], dealloc                        // Get the origianl values of x29 and x30 from back                                         // Set back to zero
    ret   											     // Return to OS
