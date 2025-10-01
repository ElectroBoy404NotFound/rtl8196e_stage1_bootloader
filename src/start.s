    .section .init
    .globl _start

    .set noat
    .set noreorder
    .set mips1
    
_start:
    # Disable interrupts / clear Status register
    mtc0 $zero, $12
    nop

    #-----------------------------------------
    # Check if SoC is RTL8196E and set Intel NOR Flash reset type
    #-----------------------------------------

    # Check SoC ID
    lui     $t7, 0xb800          # $t7 = 0xb8000000
    lw      $t6, 0($t7)          # $t6 = *(volatile uint32_t*)0xb8000000
    lui     $at, 0x8196          # high 16 bits of SoC ID
    ori     $at, $at, 0xe000     # $at = 0x8196e000
    bne     $t6, $at, skip_nor
    nop                          # delay slot

    # Access Watchdog/strap register
    lui     $t7, 0xb800
    ori     $t7, $t7, 0x8        # $t7 = 0xb8000008
    lw      $t6, 0($t7)          # read current value
    li      $at, 0x00080000
    or      $t6, $t6, $at
    sw      $t6, 0($t7)          # write back
    nop

skip_nor:
    # Setup UART

    # Set UART0_LCR
    li $t0, 0xB800200c
    
    li $t1, 0x03000000
    sw $t1, 0($t0)
    nop

    # Set UART0_IIR
    li $t0, 0xB8002008
    
    li $t1, 0xc7000000
    sw $t1, 0($t0)
    nop

    # Set UART0_DLM
    li $t0, 0xB8002004
    
    li $t1, 0x00000000
    sw $t1, 0($t0)
    nop

    # Set UART0_LCR
    li $t0, 0xB800200c
    
    li $t1, 0x83000000
    sw $t1, 0($t0)
    nop

    # Set UART0_RBR
    li $t0, 0xB8002000
    
    li $t1, 0x6b000000
    sw $t1, 0($t0)
    nop

    # Set UART0_DLM
    li $t0, 0xB8002004
    
    li $t1, 0x00000000
    sw $t1, 0($t0)
    nop

    # Set UART0_LCR
    li $t0, 0xB800200c
    
    li $t1, 0x03000000
    sw $t1, 0($t0)
    nop

    li $t0, 0xb8002000
    li $t1, 0x43000000
    sw $t1, 0($t0)

    li $t0, 0xb8002000
    li $t1, 0x44000000
    sw $t1, 0($t0)

    li $t0, 0xb8002000
    li $t1, 0x45000000
    sw $t1, 0($t0)

    # SDRAM Stuff
    li $t0, 0x3fffff80
    li $t1, 0xb8001040
    sw $t0, 0($t1)
    nop

    li $t0, 0x7fffff80
    li $t1, 0xb8001040
    sw $t0, 0($t1)
    nop

    # Set DRAM Calibration Register
    li $t0, 0xe3100000
    li $t1, 0xb8001050
    sw $t0, 0($t1)
    nop

    # NOTE: 0xb8000010 is not a DRAM register... Probably NOR related?
    li $t0, 0x000002ca
    li $t1, 0xb8000010
    sw $t0, 0($t1)
    nop

    # Set DRAM Timing Register
    li $t0, 0x48c26190
    li $t1, 0xb8001008
    sw $t0, 0($t1)
    nop

    # Set DRAM Configuration Register
    li $t0, 0x52080000
    li $t1, 0xb8001004
    sw $t0, 0($t1)
    nop

    # NOTE: 0xb8000048 is also not a DRAM register... Probably Pin Mux 2 related?
    li $t0, 0x0002dfb0
    li $t1, 0xb8000048
    sw $t0, 0($t1)
    nop

    # NOTE: Idk what this does...
    li  $t7, 0xb8000088
    lw  $t6, 0($t7)
    li  $at, 0x9fffffff
    and $t6, $t6, $at
    sw  $t6, 0($t7)
    nop

    li  $t7, 0xb800008c
    lw  $t6, 0($t7)
    li  $at, 0xffffff83
    and $t6, $t6, $at
    ori $t6, $t6, 0x7c
    sw  $t6, 0($t7)
    nop

    li $t0, 0xb8002000
    li $t1, 0x46000000
    sw $t1, 0($t0)

    # DRAM Calibration
    li      $t3, 0xa0000000     # memory base
    li      $v0, 0x5a5aa5a5     # test pattern
    li      $t2, 0xb8001050     # DDR calibration register
    li      $t1, 0x80000000
    li      $a2, 0x0
    li      $t6, 0x21
    li      $t5, 0x0
    li      $t7, 0x21

    sw      $v0, 0($t3)         # write test pattern
    li      $v1, 1
    li      $t4, 0xffff          # mask
    li      $t0, 0x5aa5          # expected lower half pattern
    move    $a0, $t1
    move    $a3, $t4
    move    $a1, $t0

loop_test:
    li $t0, 0xb8002000
    li $t8, 0x46000000
    sw $t8, 0($t0)
    
    lw      $v0, 0($t3)
    and     $v0, $v0, $a3
    bne     $v0, $a1, skip_update
    nop
skip_update:
    addiu   $v1, $v1, 1
    sltiu   $v0, $v1, 0x21
    bne     $v0, $zero, loop_test
    nop

    # final DDR value calculation
    addiu   $t8, $v1, -1
    li      $v0, 0xc000
    and     $t1, $t1, $v0
    add     $v0, $t8, $a2
    srl     $v0, $v0, 1
    move    $t9, $v0
    sll     $v0, $v0, 25         # sll v0, 0x19
    sll     $t9, $t9, 20          # sll t9, 0x14
    or      $t1, $t1, $v0
    or      $t1, $t1, $t9
    sw      $t1, 0($t2)

    li $t0, 0xb8002000
    li $t8, 0x47000000
    sw $t8, 0($t0)

    # Initialize XContext register (CP0)
    mtc0    $zero, $4      # XContext = 0
    nop
    li      $t0, 0x3
    mtc0    $t0, $4        # XContext = 3
    nop
    mtc0    $zero, $4      # XContext = 0 again
    nop

    li $t0, 0xb8002000
    li $t1, 0x42000000
    sw $t1, 0($t0)

    li $t0, 0xb8002000
    li $t1, 0x30000000
    sw $t1, 0($t0)
    nop

    la $sp, _stack_top

    li $t0, 0xb8002000
    li $t1, 0x4A000000
    sw $t1, 0($t0)
    nop

    li $t0, 0xb8002000
    li $t1, 0x40000000
    sw $t1, 0($t0)
    nop

    jal cmain
    nop

    li $t0, 0xb8002000
    li $t1, 0x4C000000
    sw $t1, 0($t0)
    nop

hang:
    j hang
    nop

