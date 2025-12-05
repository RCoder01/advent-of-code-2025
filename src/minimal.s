    .section .text
    .globl _start
_start:
    li      a0, 1
    la      a1, msg
    li      a2, 14
    jal     ra, .write

    li      a0, 0
    j       .exit

.write: /* a0: fd       */
        /* a1: buf      */
        /* a2: buf.len  */
    li      a7, 64
    ecall
    ret

.exit:  /* a0: exit code */
    li      a7, 93
    ecall

    .section .rodata
msg:
    .ascii "Hello, World!\n"

