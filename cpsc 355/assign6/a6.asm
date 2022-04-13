fp      .req    x29
lr      .req    x30

                .data
loop_m:         .double 0r1.0
zero_m:         .double 0r0.0
one_m:          .double 0r1.0
nOne_m:         .double 0r-1.0
check_m:        .double 0r1.0e-10

                .text
open_error:     .string "Cannot open %s for reading\n"
close_error:    .string "File fail to close\n"
read_str:       .string "The x is %0.10f "
format_ex:      .string "| e^x = %0.10f. "
format_enx:     .string "| e^(-x) = %0.10f. \n"
                .balign 4

base_size = 16
fd_size = 4
bytes_read_size = 4
value_size = 8

fd_s    = base_size
bytes_read_s = fd_s + fd_size
value_s = bytes_read_s + bytes_read_size

alloc   = -(base_size + fd_size + bytes_read_size + value_size) & -16
dealloc = -alloc

calc_ex:
        stp     fp, lr, [sp, -16]!      // Save frame pointer (fp) and link register (lr) to the stack
        mov     lr, sp                  // Set fp to the top of the stack

        // d0:x
        adrp    x20, zero_m             // Load address of zero_m 
        add     x20, x20, :lo12:zero_m  // lower bit
        ldr     d2, [x20]               // Load zero_m  into d1

        fadd    d2,d2,d1                // 0 + 1:sum = 1


        fmov    d3,d1                   // set d3 = 1:term(t)
        fmov    d4,d1                   // set d4 = 1:i
exAdd_loop:
        fmul    d3,d3,d0                // t = t * x
        fdiv    d3,d3,d4                // t = t * x / i
        fadd    d2,d2,d3                // sum = sum + t

        adrp    x20, zero_m             // Load address of zero_m 
        add     x20, x20, :lo12:zero_m  // lower bit
        ldr     d6, [x20]               // Load zero_m  into d1

        fcmp    d3,d6                   // if current term < 0 
        b.ge    check                   // if >0,then do nothing
        fsub    d6,d6,d1                // d6 = -1
        fmul    d6,d3,d6                // store the change value into d6 = -t * -1

n_check:
        fcmp    d6,d5                   // if term < 10e-10
        b.lt    ex_exit                 // exit
        b       end_loop                // skip nexr label

check:
        fcmp    d3,d5                   // if term < 10e-10
        b.lt    ex_exit                 // exit

end_loop:
        fadd    d4,d4,d1                // i = i + 1
        b       exAdd_loop              // keep loop

ex_exit:
        fmov    d0,d2
        ldp     fp, lr, [sp], 16        // Restore the stack
        ret                             // Return to OS

        .global main
main:   stp     fp, lr, [sp, alloc]!    // Save frame pointer (fp) and link register (lr) to the stack
        mov     lr, sp                  // Set fp to the top of the stack

        mov     x19,x1                  // save argv 
        
        mov     w0,-100                 // get file descriptor and AT_FDCWD = -100

        mov     w2,1                    // get command line argument
        ldr     x1, [x19, w2, SXTW 3]   // load into x1
        mov     w2,0                    // O_RDONLY = 0
        mov     w3,0666                 // w3 = permission flags
        mov     x8,56                   // 56 = openat
        svc     0                       // make syscall

        str     w0, [fp, fd_s]          // Store fd on the stack

        str     wzr, [fp, bytes_read_s] // initialize bytes_read
        str     xzr, [fp, value_s]      // initialize value

        cmp     w0,0                    // if fd > 0
        b.ge    open_pass               // open success

        // If there were some errors, print a message to the user and exit
        adrp    x0,open_error           // Get address of format string
        add     x0, x0, :lo12:open_error// + lower bits
        mov     w2,1                    // set w2 to 1
        ldr     x1, [x19, w2, SXTW 3]   // load into x1
        bl      printf                  // Call function printf

        mov     w0,-1                   // Return code will be -1
        b       exit                    // Branch to exit

open_pass:
        // Setup & call read
        ldr     w0, [fp, fd_s]          // x0: fd
        add     x1,fp,value_s           // x1:&value
        mov     w2,8                    // x3: sizeof(double)
        mov     x8,63                   // 63 = read
        svc     0                       // Make syscall

        str     w0, [fp, bytes_read_s]  // Store the number of bytes read on the stack
        
        ldr     x0, =read_str           // load the x0 equal to the string            
        ldr     d0, [fp, value_s]       // d0 is a floating point register
        bl      printf

        ldr     d0, [fp, value_s]       // x = d0

        adrp    x20, one_m              // Load address of one_m
        add     x20, x20, :lo12:one_m   // lower bit
        ldr     d1, [x20]               // Load one_m into d1

        adrp    x20, check_m            // Load address of check_m
        add     x20, x20, :lo12:check_m // lower bit
        ldr     d5, [x20]               // Load check_m  into d6

        bl      calc_ex                 // call function calc_ex
        adrp    x0, format_ex           // Load format string
        add     x0, x0, :lo12:format_ex
        bl      printf                  // Call printf

        ldr     d0, [fp, value_s]       // x = d0

        adrp    x20, nOne_m             // Load address of nOne_m
        add     x20, x20, :lo12:nOne_m  // lower bit
        ldr     d1, [x20]               // Load -1.0 into d1

        fmul    d0,d0,d1                // let x * -1 = -x

        adrp    x20, one_m              // Load address of one_m
        add     x20, x20, :lo12:one_m   // lower bit
        ldr     d1, [x20]               // Load 1.0 into d1

        adrp    x20, check_m            // Load address of check_m
        add     x20, x20, :lo12:check_m // lower bit
        ldr     d5, [x20]               // Load check_m  into d6

        bl      calc_ex                 // call function calc_ex
        adrp    x0, format_enx          // Load format string
        add     x0, x0, :lo12:format_enx// lower bit
        bl      printf                  // Call printf

loop_test:
        ldr     w0, [fp, bytes_read_s]  // Load the number of bytes read
        cmp     w0, 0                   // If bytes_read > 0...
        b.gt    open_pass               // Continue to read from the file

file_close:
        ldr     w0, [fp, fd_s]          // x0: fd
        mov     x8, 57                  // 57: close
        svc     0                       // Make syscall

        mov     w0,0                    // Return code is 0
exit:
        ldp     fp, lr, [sp], dealloc   // Restore the stack
        ret                             // Return to OS
