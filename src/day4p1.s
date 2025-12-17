    .section .text
    .globl _start
_start:
    nop

.macro save
    addi    sp, sp, -30*8
    sd      x1, 0*8(sp)
    sd      x3, 1*8(sp)
    sd      x4, 2*8(sp)
    sd      x5, 3*8(sp)
    sd      x6, 4*8(sp)
    sd      x7, 5*8(sp)
    sd      x8, 6*8(sp)
    sd      x9, 7*8(sp)
    sd      x10, 8*8(sp)
    sd      x11, 9*8(sp)
    sd      x12, 10*8(sp)
    sd      x13, 11*8(sp)
    sd      x14, 12*8(sp)
    sd      x15, 13*8(sp)
    sd      x16, 14*8(sp)
    sd      x17, 15*8(sp)
    sd      x18, 16*8(sp)
    sd      x19, 17*8(sp)
    sd      x20, 18*8(sp)
    sd      x21, 19*8(sp)
    sd      x22, 20*8(sp)
    sd      x23, 21*8(sp)
    sd      x24, 22*8(sp)
    sd      x25, 23*8(sp)
    sd      x26, 24*8(sp)
    sd      x27, 25*8(sp)
    sd      x28, 26*8(sp)
    sd      x29, 27*8(sp)
    sd      x30, 28*8(sp)
    sd      x31, 29*8(sp)
.endm

.macro restore
    ld      x1, 0*8(sp)
    ld      x3, 1*8(sp)
    ld      x4, 2*8(sp)
    ld      x5, 3*8(sp)
    ld      x6, 4*8(sp)
    ld      x7, 5*8(sp)
    ld      x8, 6*8(sp)
    ld      x9, 7*8(sp)
    ld      x10, 8*8(sp)
    ld      x11, 9*8(sp)
    ld      x12, 10*8(sp)
    ld      x13, 11*8(sp)
    ld      x14, 12*8(sp)
    ld      x15, 13*8(sp)
    ld      x16, 14*8(sp)
    ld      x17, 15*8(sp)
    ld      x18, 16*8(sp)
    ld      x19, 17*8(sp)
    ld      x20, 18*8(sp)
    ld      x21, 19*8(sp)
    ld      x22, 20*8(sp)
    ld      x23, 21*8(sp)
    ld      x24, 22*8(sp)
    ld      x25, 23*8(sp)
    ld      x26, 24*8(sp)
    ld      x27, 25*8(sp)
    ld      x28, 26*8(sp)
    ld      x29, 27*8(sp)
    ld      x30, 28*8(sp)
    ld      x31, 29*8(sp)
    addi    sp, sp, 30*8
.endm

.macro dbg r=a0
    save
    mv      a0, \r
    call    .println_u64
    restore
.endm

    la      a1, file
    li      a2, 0
    call    .open

    addi    sp, sp, -4
    sw      a0, 0(sp)

    call    .main

    lw      a0, 0(sp)
    call    .close

    li      a0, 0
    j       .exit


.main:  # a0: input fd
    addi    sp, sp, -10*8
    sd      ra, 0*8(sp)
    sd      s0, 1*8(sp) # input fd
    sd      s1, 2*8(sp) # map buf
    sd      s2, 3*8(sp) # map buf.len
    sd      s3, 4*8(sp) # accessible count
    sd      s4, 5*8(sp) # 
    sd      s5, 6*8(sp) # 
    sd      s6, 7*8(sp) #
    sd      s7, 8*8(sp) #
    sd      s8, 9*8(sp) #
    mv      s0, a0
    mv      s3, zero

    call    .mmap_file_read
    mv      s1, a0
    mv      s2, a1

    li      a0, 1
    mv      a1, s1
    mv      a2, s2
    call    .write

    mv      a0, s1
    mv      a1, s2
    call    .get_map_size

    # dbg     a1
    # dbg     a2
    mv      a3, zero
    mv      a4, zero
    j       .main.loop_body

.main.loop_col:
    addi    a3, a3, 1
    blt     a3, a1, .main.loop_body
.main.loop_row:
    mv      a3, zero
    addi    a4, a4, 1
    bge     a4, a2, .main.end
.main.loop_body:
    # dbg     a3
    # dbg     a4
    call    .check_cell_accessible
    # dbg     a5
    add     s3, s3, a5
    j       .main.loop_col

.main.end:
    mv      a0, s3
    call    .println_u64
    ld      ra, 0*8(sp)
    ld      s0, 1*8(sp)
    ld      s1, 2*8(sp)
    ld      s2, 3*8(sp)
    ld      s3, 4*8(sp)
    ld      s4, 5*8(sp)
    ld      s5, 6*8(sp)
    ld      s6, 7*8(sp)
    ld      s7, 8*8(sp)
    ld      s8, 9*8(sp)
    addi    sp, sp, 10*8
    ret

.get_map_size:  # a0: map
                # a1: map.len
                # ---
                # a0: map
                # a1: map cols
                # a2: map rows
    addi    sp, sp, -3*8
    sd      ra, -0*8(sp)
    sd      s0, -1*8(sp)
    sd      s1, -2*8(sp)
    mv      s0, a0
    mv      s1, a1
    
    li      a2, '\n'
    call    .find
    bltz    a0, .get_map_size.error

    addi    t0, a0, 1
    div     a1, s1, t0

    mv      a2, a1
    mv      a1, a0
    mv      a0, s0

    ld      ra, -0*8(sp)
    ld      s0, -1*8(sp)
    ld      s1, -2*8(sp)
    addi    sp, sp, 3*8
    ret
.get_map_size.error:
    li      a0, 2
    la      a1, get_map_size_error_msg
    la      a2, get_map_size_error_msg_len
    call    .writeln

    li      a0, 1
    call    .exit

.check_cell_accessible: # a0: map
                        # a1: map cols
                        # a2: map rows
                        # a3: query col
                        # a4: query row
                        # ---
                        # a0: map
                        # a1: map cols
                        # a2: map rows
                        # a3: query col
                        # a4: query row
                        # a5: 0 if inaccessible or unoccupied, 1 if accessible and occupied
    addi    sp, sp, -2*8
    sd      ra, -0*8(sp)
    sd      s0, -1*8(sp)
    mv      s0, zero

    call    .get_cell_occupied
    beqz    a5, .check_cell_accessible.unoccupied

    addi    a3, a3, -1

    addi    a4, a4, -1
    call    .get_cell_occupied
    add     s0, s0, a5

    addi    a4, a4, 1
    call    .get_cell_occupied
    add     s0, s0, a5

    addi    a4, a4, 1
    call    .get_cell_occupied
    add     s0, s0, a5

    addi    a3, a3, 1

    addi    a4, a4, -2
    call    .get_cell_occupied
    add     s0, s0, a5

    addi    a4, a4, 2
    call    .get_cell_occupied
    add     s0, s0, a5

    addi    a3, a3, 1

    addi    a4, a4, -2
    call    .get_cell_occupied
    add     s0, s0, a5

    addi    a4, a4, 1
    call    .get_cell_occupied
    add     s0, s0, a5

    addi    a4, a4, 1
    call    .get_cell_occupied
    add     s0, s0, a5

    sltiu   a5, s0, 4
    addi    a3, a3, -1
    addi    a4, a4, -1
.check_cell_accessible.ret:
    ld      ra, -0*8(sp)
    ld      s0, -1*8(sp)
    addi    sp, sp, 2*8
    ret
.check_cell_accessible.unoccupied:
    li      a5, 0
    j       .check_cell_accessible.ret

.get_cell_occupied: # a0: map
                    # a1: map cols
                    # a2: map rows
                    # a3: query col
                    # a4: query row
                    # ---
                    # a0: map
                    # a1: map cols
                    # a2: map rows
                    # a3: query col
                    # a4: query row
                    # a5: 0 if out of bounds or unoccupied, 1 if occupied
    bge     a3, a1, .get_cell_occupied.out_of_bounds
    bltz    a3, .get_cell_occupied.out_of_bounds
    bge     a4, a2, .get_cell_occupied.out_of_bounds
    bltz    a4, .get_cell_occupied.out_of_bounds

    # compute index in map
    addi    t0, a1, 1
    mul     t0, t0, a4
    add     t0, t0, a3

    add     t0, a0, t0
    lb      t0, (t0)

    addi    t0, t0, -'@'
    seqz    a5, t0

    ret
.get_cell_occupied.out_of_bounds:
    li      a5, 0
    ret
    

.max_u8:    # a0: buf
            # a1: buf.len
            # ---
            # a0: max value (0 if buf.len==0)
            # a1: max index (0 if buf.len==0)
    li      t0, 0 # i
    li      t1, 0 # argmax
    li      t2, 0 # max
    beqz    a1, .max_u8.return
.max_u8.loop:
    add     t3, a0, t0
    lbu     t4, (t3)
    bleu    t4, t2, .max_u8.loop.continue
    mv      t1, t0
    mv      t2, t4
.max_u8.loop.continue:
    addi    t0, t0, 1
    beq     t0, a1, .max_u8.return
    j       .max_u8.loop
.max_u8.return:
    mv      a0, t2
    mv      a1, t1
    ret

    
.byte_copy: # a0: len
            # a1: src
            # a2: dst
    add     t0, a1, a0
.byte_copy.loop:
    beq     a1, t0, .byte_copy.end
    lb      t1, (a1)
    sb      t1, (a2)
    addi    a1, a1, 1
    addi    a2, a2, 1
    j       .byte_copy.loop
.byte_copy.end:
    ret


.find:  # a0: buf
        # a1: buf.len
        # a2: val
        # ---
        # a0: index of first newline (or -1)
    mv      t0, a0
    add     t1, a0, a1
    beq     a1, zero, .find.not_found
.find.loop:
    lb      t2, (a0)
    beq     a2, t2, .find.return
    addi    a0, a0, 1
    blt     a0, t1, .find.loop
.find.not_found:
    li      a0, -1
    ret
.find.return:
    sub     a0, a0, t0
    ret


.println_u64: # a0: u64
    addi    sp, sp, -40
    sd      ra, 32(sp)

    mv      a1, sp
    li      a2, 32
    call    .int_to_dec

    mv      a1, sp
    mv      a2, a0
    li      a0, 1
    call    .writeln

    ld      ra, 32(sp)
    addi    sp, sp, 40
    ret


.ascii_decimal_to_int:  # a0: buf
                        # a1: buf.len
                        # ---
                        # a0: value
    add     t0, a0, a1
    mv      t2, zero
    li      t3, 10
.ascii_decimal_to_int.loop:
    lb      t1, (a0)
    addi    t1, t1, -'0' # ascii digit to value
    mul     t2, t2, t3
    add     t2, t2, t1
    addi    a0, a0, 1
    blt     a0, t0, .ascii_decimal_to_int.loop
    mv      a0, t2
    ret


.int_to_hex:    # a0: value
                # a1: buf
                # a2: buf.len
                # ---
                # a0: len or -1 if value exceeds buf.len
    beq     a0, zero, .int_to_hex.zero
    mv      t0, zero
    li      t2, 17
    mv      t3, a2
    li      t4, 10
.int_to_hex.loop:
    srli    t1, a0, 60
    slli    a0, a0, 4
    addi    t2, t2, -1
    beq     t2, zero, .int_to_hex.success
    or      t0, t0, t1
    beq     t0, zero, .int_to_hex.loop
    beq     a2, zero, .int_to_hex.buf_overflow
    bge     t1, t4, .int_to_hex.ascii_char
.int_to_hex.ascii_digit:
    addi    t1, t1, '0'
    j       .int_to_hex.append_to_buf
.int_to_hex.ascii_char:
    addi    t1, t1, 'A' - '\n'
.int_to_hex.append_to_buf:
    sb      t1, (a1)
    addi    a1, a1, 1
    addi    a2, a2, -1
    j       .int_to_hex.loop
.int_to_hex.success:
    sub     a0, t3, a2
    ret
.int_to_hex.buf_overflow:
    li      a0, -1
    ret
.int_to_hex.zero:
    beq     a2, zero, .int_to_hex.buf_overflow
    li      t0, '0'
    sb      t0, (a1)
    li      a0, 1
    ret

.int_to_dec:    # a0: value
                # a1: buf
                # a2: buf.len
                # ---
                # a0: len or -1 if value exceeds buf.len
    beq     a0, zero, .int_to_dec.zero
    li      t2, 10
    li      t4, 10000000000000000000
    bgeu    a0, t4, .int_to_dec.LARGE
    li      t0, 10
    li      t1, 1

.int_to_dec.size_loop:
    bltu    a0, t0, .int_to_dec.size_loop.break
    addi    t1, t1, 1
    mul     t0, t0, t2

    j       .int_to_dec.size_loop
.int_to_dec.LARGE:
    li      t1, 20
.int_to_dec.size_loop.break:
    blt     a2, t1, .int_to_dec.buf_overflow
    mv      a2, t1
.int_to_dec.digit_loop:
    divu    t3, a0, t2
    remu    t0, a0, t2
    mv      a0, t3

    addi    t0, t0, '0'
    add     t3, a1, t1
    sb      t0, -1(t3)
    addi    t1, t1, -1
    bgtz    t1, .int_to_dec.digit_loop
.int_to_dec.digit_loop.break:
    mv      a0, a2
    ret
.int_to_dec.buf_overflow:
    li      a0, -1
    ret
.int_to_dec.zero:
    beq     a2, zero, .int_to_dec.buf_overflow
    li      t0, '0'
    sb      t0, (a1)
    li      a0, 1
    ret

.open:  # a0: ignored
        # a1: fname (null-terminated)
        # a2: flags (0 for read, 1 for write, 2 for readwrite)
        # ---
        # a0: fd
    li      a7, 56
    li      a0, -100 # AT_FDCWD
    ecall
    ret


.close: # a0: fd
    li      a7, 57
    ecall
    ret


.get_file_size: # a0: fd
                # ---
                # a0: file size in bytes
                
    addi    sp, sp, -256

    li      a1, 0 # path
    li      a2, 0x1000|0x2000 # AT_EMPTY_PATH|AT_STATX_FORCE_SYNC
    li      a3, 0x00000200 # STATX_SIZE
    mv      a4, sp # &struct statx
    li      a7, 291
    ecall

    ld      a0, 40(sp) # stx_size
    addi    sp, sp, 256
    ret


.write: # a0: fd 
        # a1: buf
        # a2: buf.len
    li      a7, 64
    ecall
    ret


.write_char: # a0: fd
             # a1: char
    addi    sp, sp, -9
    sb      a1, 8(sp)
    sd      ra, (sp)

    /* a0 is already fd */
    addi    a1, sp, 8
    li      a2, 1
    call    .write

    ld      ra, (sp)
    addi    sp, sp, 9
    ret

.write_newline:
    li      a1, '\n'
    j       .write_char


.writeln:   # a0: fd
            # a1: buf
            # a2: buf.len
    addi    sp, sp, -16
    sd      ra, (sp)
    sd      s0, 8(sp)

    mv      s0, a0
    call    .write
    mv      a0, s0
    call    .write_newline

    ld      ra, (sp)
    ld      s0, 8(sp)
    addi    sp, sp, 16
    ret

.write_escaped: # a0: fd
                # a1: buf
                # a2: buf.len
    addi    sp, sp, -4*8
    sd      ra, 0*8(sp)
    sd      s0, 1*8(sp) # fd
    sd      s1, 2*8(sp) # ptr
    sd      s2, 3*8(sp) # end

    mv      s0, a0
    mv      a1, a1
    add     s2, a1, a2
.write_escaped.loop:
    beq     s1, s2, .write_escaped.end
    lb      t0, (s1)
    addi    t1, t0, -'\n'
    beq     t1, zero, .write_escaped.write_newline
.write_escaped.write_char:
    mv      a0, s0
    mv      a1, t0
    call    .write_char
    j       .write_escaped.continue
.write_escaped.write_newline:
    mv      a0, s0
    li      a1, '\'
    call    .write_char
    mv      a0, s0
    li      a1, 'n'
    call    .write_char
.write_escaped.continue:
    addi    s1, s1, 1
    j       .write_escaped.loop

.write_escaped.end:
    ld      ra, 0*8(sp)
    ld      s0, 1*8(sp)
    ld      s1, 2*8(sp)
    ld      s2, 3*8(sp)
    addi    sp, sp, 4*8
    ret


.read:  # a0: fd
        # a1: dest_buf
        # a2: dest_buf.len
        # ---
        # a0: read count or -1 if error
    li      a7, 63
    ecall
    ret


.read_exact:    # a0: fd
                # a1: dest_buf
                # a2: dest_buf.len
                # ---
                # a0: read count (equal to dest_buf.len) or -1 if error
    addi    sp, sp, -8*5
    sd      s0, 8*0(sp) # fd
    sd      s1, 8*1(sp) # remaining_buf
    sd      s2, 8*2(sp) # remaining_buf.len
    sd      s3, 8*3(sp) # dest_buf
    sd      s4, 8*4(sp) # dest_buf.len

    mv      s0, a0
    mv      s1, a1
    mv      s2, a2

.read_exact.loop:
    mv      a0, s0
    mv      a1, s1
    mv      a2, s2
    call    .read
    bltz    a0, .read_exact.fail
    sub     s2, s2, a0
    beqz    s2, .read_exact.success
    add     s1, s1, a0
    j       .read_exact.loop
.read_exact.success:
    mv      a0, s4
.read_exact.fail:
.read_exact.return:
    ld      s0, 8*0(sp) # fd
    ld      s1, 8*1(sp) # remaining_buf
    ld      s2, 8*2(sp) # remaining_buf.len
    ld      s3, 8*3(sp) # dest_buf
    ld      s4, 8*4(sp) # dest_buf.len
    addi    sp, sp, 8*5
    ret


.alloc: # a0: size to allocate
        # ---
        # a0: start of allocated buffer or -1 if error
    mv      a1, a0
    li      a0, 0           # addr = NULL
    li      a2, 0x1|0x2     # PROT_READ|PROT_WRITE
    li      a3, 0x20|0x02   # MAP_ANONYMOUS|MAP_PRIVATE
    li      a4, -1          # anonymous file descriptor
    li      a5, 0           # zero offset
    li      a7, 222
    ecall


.mmap_file_read:    # a0: fd to map
                    # ---
                    # a0: start address of mapping
                    # a1: mapping len
    addi    sp, sp, -3*8
    sd      ra, 0*8(sp)
    sd      s0, 1*8(sp)
    sd      s1, 2*8(sp)
    mv      s0, a0

    call    .get_file_size
    mv      s1, a0

    li      a0, 0           # addr = NULL
    mv      a1, s1
    li      a2, 0x1         # PROT_READ
    li      a3, 0x02        # MAP_PRIVATE
    mv      a4, s0          # set fd
    li      a5, 0           # zero offset in file
    li      a7, 222         # mmap
    ecall

    mv      a1, s1

    ld      ra, 0*8(sp)
    ld      s0, 1*8(sp)
    ld      s1, 2*8(sp)
    addi    sp, sp, 3*8
    ret


.exit:  # a0: exit code
    li      a7, 93
    ecall


    .section .rodata
file:
    .ascii  "data/day4d\0"
    .set    file_len, .-file
get_map_size_error_msg:
    .ascii  "Couldn't find row end (\n) in map"
    .set    get_map_size_error_msg_len, .-get_map_size_error_msg
