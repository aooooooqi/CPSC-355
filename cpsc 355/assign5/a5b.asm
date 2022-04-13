//Aoqi Li
//UCID:30120288
                .text                           // Store string formats in text section
Fst:            .string "st"
Snd:            .string "nd"
Trd:            .string "rd"
Nth:            .string "th"
fmt:            .string "%s %d"
fmt2:           .string " is %s\n"
error_msg:      .string "usage: a5b mm dd\n"
outofRange:     .string "invaild value\n"
test:           .string "\n 除数是 %d \n"

January_m:      .string "January"
February_m:     .string "February"
March_m:        .string "March"
April_m:        .string "April"
May_m:          .string "May"
June_m:         .string "June"
July_m:         .string "July"
August_m:       .string "August"
September_m:    .string "September"
October_m:      .string "October"
November_m:     .string "November"
December_m:     .string "December"

spr_m:          .string "spring"
sum_m:          .string "summer"
fal_m:          .string "fall"
win_m:          .string "winter"

                .data
                .balign 8                       // Must be doubleword aligned
                .global month
                .global season
month:          .dword January_m, February_m, March_m, April_m, May_m, June_m, July_m, August_m, September_m ,October_m ,November_m, December_m
season:         .dword spr_m, sum_m, fal_m, win_m
                .text                           // Program code is stored in text section
fp              .req    x29
lr              .req    x30

                .balign 4
                .global main                    // make main as global value

define(i_r, w19)
define(argc_r, w20)
define(argv_r, x21)
define(month_n,w22)
define(day_n,w23)
define(temp_r,w25)
define(remainde,w26)
main:   
        stp     fp, lr, [sp, -16]!              // Save frame pointer (fp) and link register (lr) to the stack
        mov     lr, sp                          // Set fp to the top of the stack

        mov     argc_r, w0                      // Copy argc: number of elements in array
        mov     argv_r, x1                      // Copy argv: base address of the array
input_check:
        cmp     argc_r,3                        // check if is two command-line arguments
        b.lt    error                           // if not,quit

        mov     i_r, 1                          // i = 0
        ldr     x0, [argv_r, i_r, sxtw 3]       // Load argv[i]
        bl      atoi                            // Call atoi
        mov     month_n,w0                      // copy value that stored w0
        add     month_n,month_n,-1              // because array start at 0,so -1

        mov     i_r, 2                          // i = 1
        ldr     x0, [argv_r,i_r,sxtw 3]         // load the argv_r[i]
        bl      atoi                            // Call atoi
        mov     day_n,w0                        // copy value that stored w0

        adrp    x0,fmt                          // Load first arg to printf
        add     x0,x0, :lo12:fmt                // + lower bits

        adrp    x24, month                      // Get array base address
        add     x24,x24, :lo12:month            // + Lower bits
        ldr     x1,[x24, month_n, sxtw 3]       // Second arg is month[month_n]. Multiply by 8 since the pointers in the array

        mov     w2,day_n                        // Third arg is day_n
        bl      printf                          // Call function printf
        add     month_n,month_n,1               // change back month

        mov     temp_r,10                       // temp_r number for get the Suffix
        udiv    remainde,day_n,temp_r           // get the quotient
	msub 	remainde,temp_r,remainde,day_n  // calcualte the remainde

check_f:
        cmp     remainde,1                      // if remainde == 1
        b.eq    set_frist                       // jump to set_frist
        b       check_s                         // if not,skip to the next part

set_frist:
        adrp    x0,Fst                          // Load first arg to printf
        add     x0,x0, :lo12:Fst                // + Lower bits
        b       Suffix_print                    // jump to label Suffix_print 

check_s:
        cmp     remainde,2                      // if remainde == 2
        b.eq    set_second                      // then jump to the set_second
        b       check_t                         // if not,skip to the next part

set_second:
        adrp    x0,Snd                          // Load first arg to printf
        add     x0,x0, :lo12:Snd                // + Lower bits
        b       Suffix_print                    // jump to label Suffix_print 

check_t:
        cmp     remainde,3                      // if remainde == 3
        b.eq    set_Third                       // then,jump to the set_Third
        b       set_th                          // if not,skip to next part

set_Third:
        adrp    x0,Trd                          // Load first arg to printf
        add     x0,x0, :lo12:Trd                // + Lower bits
        b       Suffix_print                    // jump to label Suffix_print 
set_th:
        adrp    x0,Nth                          // Load first arg to printf
        add     x0,x0, :lo12:Nth                // + Lower bits

Suffix_print:
        bl      printf                          // Call function printf

season_check:
        mov     w0,20                           // season end date
                                                // winter December 21 to March 20
        cmp     month_n,1                       // if month is 1
        b.eq    winter                          // then get the season winter

        cmp     month_n,2                       // if month is 2
        b.eq    winter                          // then get the season winter
                                                // date between spring and winter
Win_Spr:
        cmp     month_n,3                       // if month is 3
        b.eq    get_season1                     // check the data greater or smaller than 20

        b       month_spring                    // else: jump to next section
get_season1:
        cmp     day_n,w0                        // compare date with 20
        b.le    winter                          // if <=20,then is winter
        cmp     day_n,w0                        // compare date with 20
        b.gt    spring                          // if > 20,then is spring
                                                // spring  March 21 to June 20
month_spring:                   
        cmp     month_n,4                       // if month is 4
        b.eq    spring                          // then the season is spring

        cmp     month_n,5                       // if month is 5
        b.eq    spring                          // then the season is spring
                                                // date between spring and summer
Spr_Summ:
        cmp     month_n,6                       // if month is 6
        b.eq    get_season2                     // check for date 
        b       month_summer                    // otherwise,skip to next part
get_season2:
        cmp     day_n,w0                        // if date <= 20
        b.le    spring                          // then the season is spring
        cmp     day_n,w0                        // if date >20
        b.gt    summer                          // then the season is summer
                                                // summer June 21 to September 20
month_summer:
        cmp     month_n,7                       // if month is 7
        b.eq    summer                          // then the season is summer

        cmp     month_n,8                       // if month is 8
        b.eq    summer                          // then the season is summer
Summ_fall:
        cmp     month_n,9                       // if month is 9
        b.eq    get_season3                     // check for date

        b       month_fall                      // else:skip to next section
get_season3:
        cmp     day_n,w0                        // if date <= 20
        b.le    summer                          // then the season is summer
        cmp     day_n,w0                        // if data >20
        b.gt    fall                            // then the season is fall
                                                // fall  from September 21 to December 20
month_fall:
        cmp     month_n,10                      // if month is 10
        b.eq    fall                            // then the season is fall

        cmp     month_n,11                      // if month is 11
        b.eq    fall                            // then the season is fall
fall_Win:
        cmp     month_n,12                      // if month is 12
        b.eq    get_season4                     // then check for date
get_season4:
        cmp     day_n,w0                        // if date <= 20
        b.le    fall                            // then the season is fall
        cmp     day_n,w0                        // if data >20
        b.gt    winter                          // then the season is winter

spring:
        mov     i_r,0                           // season[0]:spring
        b       season_print                    // jump to season_print
summer:
        mov     i_r,1                           // season[1]:summer
        b       season_print                    // jump to season_print
fall:
        mov     i_r,2                           // season[2]:fall
        b       season_print                    // jump to season_print
winter:
        mov     i_r,3                           // season[3]:winter
        b       season_print                    // jump to season_print

season_print:
        adrp    x0,fmt2                         // Load first arg to printf
        add     x0,x0, :lo12:fmt2               // + lower bits
        adrp    x24,season                      // Get array base address
        add     x24,x24, :lo12:season           // + Lower bits
        ldr     x1,[x24,i_r,sxtw 3]             // Second arg is season[i]
        bl      printf                          // call function printf

        b       exit                            // exit
error:
        adrp    x0, error_msg                   // Load first arg to printf
        add     x0, x0, :lo12:error_msg         //  + lower bits
        bl      printf                          // Call printf
        b       exit                            // exit
exit:
        ldp     fp, lr, [sp], 16                // Restore the stack
        ret                                     // Return to OS

