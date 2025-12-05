    .section .text
    .globl _start
_start:
    nop

.macro save
    addi    sp, sp, -240
    sd      x1, (sp)
    sd      x3, 8(sp)
    sd      x4, 16(sp)
    sd      x5, 24(sp)
    sd      x6, 32(sp)
    sd      x7, 40(sp)
    sd      x8, 48(sp)
    sd      x9, 56(sp)
    sd      x10, 64(sp)
    sd      x11, 72(sp)
    sd      x12, 80(sp)
    sd      x13, 88(sp)
    sd      x14, 96(sp)
    sd      x15, 104(sp)
    sd      x16, 112(sp)
    sd      x17, 120(sp)
    sd      x18, 128(sp)
    sd      x19, 136(sp)
    sd      x20, 144(sp)
    sd      x21, 152(sp)
    sd      x22, 160(sp)
    sd      x23, 168(sp)
    sd      x24, 176(sp)
    sd      x25, 184(sp)
    sd      x26, 192(sp)
    sd      x27, 200(sp)
    sd      x28, 208(sp)
    sd      x29, 216(sp)
    sd      x30, 224(sp)
    sd      x31, 232(sp)
.endm

.macro restore
    ld      x1, (sp)
    ld      x3, 8(sp)
    ld      x4, 16(sp)
    ld      x5, 24(sp)
    ld      x6, 32(sp)
    ld      x7, 40(sp)
    ld      x8, 48(sp)
    ld      x9, 56(sp)
    ld      x10, 64(sp)
    ld      x11, 72(sp)
    ld      x12, 80(sp)
    ld      x13, 88(sp)
    ld      x14, 96(sp)
    ld      x15, 104(sp)
    ld      x16, 112(sp)
    ld      x17, 120(sp)
    ld      x18, 128(sp)
    ld      x19, 136(sp)
    ld      x20, 144(sp)
    ld      x21, 152(sp)
    ld      x22, 160(sp)
    ld      x23, 168(sp)
    ld      x24, 176(sp)
    ld      x25, 184(sp)
    ld      x26, 192(sp)
    ld      x27, 200(sp)
    ld      x28, 208(sp)
    ld      x29, 216(sp)
    ld      x30, 224(sp)
    ld      x31, 232(sp)
    addi    sp, sp, 240
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
    addi    sp, sp, -80
    sd      ra, (sp)
    sd      s0, 8(sp)   # input fd
    sd      s1, 16(sp)  # buffer start
    sd      s2, 24(sp)  # buffer head
    sd      s3, 32(sp)  # buffer end
    sd      s4, 40(sp)  # line end
    sd      s5, 48(sp)  # sep index
    sd      s6, 56(sp)  # first battery value
    sd      s7, 56(sp)  # battery sum
    sd      s8, 64(sp)  #

    mv      s0, a0 
    li      s7, 0

    addi    sp, sp, -128
    mv      s1, sp
    mv      s2, s1
.main.get_input:
    mv      a0, s0
    mv      a1, s2
    addi    a2, s1, 128
    sub     a2, a2, s2
    call    .read
    blt     a0, zero, .main.readline_error
    beq     a0, zero, .main.end
    add     s3, s2, a0
    mv      s2, s1

.main.process_line:
    mv      a0, s2
    sub     a1, s3, s2
    li      a2, '\n'
    call    .find
    blt     a0, zero, .main.reset_read_buffer
    beqz    a0, .main.end
    mv      s4, a0

    mv      a0, s2
    addi    a1, s4, -1
    call    .max_u8
    mv      s6, a0

    add     a0, s2, a1
    addi    a0, a0, 1
    sub     a1, s4, a1
    addi    a1, a1, -1
    call    .max_u8

    addi    t0, s6, -'0'
    addi    t1, a0, -'0'
    li      t3, 10
    mul     t0, t0, t3
    add     t0, t0, t1
    add     s7, s7, t0

    add     s2, s2, s4
    addi    s2, s2, 1

    j       .main.process_line

.main.reset_read_buffer:
    sub     a0, s3, s2
    mv      a1, s2
    mv      a2, s1
    add     s2, s1, a0 # set buffer ptr as start of free buffer
    call    .byte_copy
    j       .main.get_input

.main.end:
    mv      a0, s7
    call    .println_u64
    addi    sp, sp, 128
    ld      ra, (sp)
    ld      s0, 8(sp)
    ld      s1, 16(sp)
    ld      s2, 24(sp)
    ld      s3, 32(sp)
    ld      s4, 40(sp)
    ld      s5, 48(sp)
    ld      s6, 56(sp)
    ld      s7, 56(sp)
    ld      s7, 64(sp)
    addi    sp, sp, 80
    ret

.main.readline_error:
    li      a0, 2
    la      a1, read_fail
    la      a2, read_fail_len
    call    .writeln
    li      a0, 1
    call    .exit

.main.find_sep_error:
    li      a0, 2
    la      a1, find_sep_error_msg
    la      a1, find_sep_error_msg_len


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
    sb      t0, (t3)
    addi    t1, t1, -1
    bne     t1, zero, .int_to_dec.digit_loop
.int_to_dec.digit_loop.break:
    mv      a0, a2
    addi    a0, a0, 1
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
    addi    sp, sp, -32
    sd      ra, (sp)
    sd      s0, 8(sp) # fd
    sd      s1, 16(sp) # ptr
    sd      s2, 24(sp) # end

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
    ld      ra, (sp)
    ld      s0, 8(sp)
    ld      s1, 16(sp)
    ld      s2, 24(sp)
    addi    sp, sp, 8
    ret


.read:  # a0: fd
        # a1: dest_buf
        # a2: dest_buf.len
        # ---
        # a0: read count or -1 if error
    li      a7, 63
    ecall
    ret


.exit:  # a0: exit code
    li      a7, 93
    ecall


    .section .rodata
file:
    .ascii  "data/day3d\0"
    .set    file_len, .-file
read_fail:
    .ascii  "Failed to read from file"
    .set    read_fail_len, .-read_fail
find_sep_error_msg:
    .ascii  "Failed to find separator"
    .set    find_sep_error_msg_len, .-find_sep_error_msg
