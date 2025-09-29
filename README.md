# rtl8196e_stage1_bootloader
This is a stage 1 bootloader made for a D-Link DIR-600M Router.

It does the following:
1. Disable interrupts
2. Setup Watchdog
3. Setup UART
4. Setup and Test DRAM
5. Copy 1048576 bytes from label `instr_bytes` (start of stage 2) to 0x80100000 (start of DRAM)
6. Jump to 0x80100004 (Start of Stage 2 in RAM)

## Known issues
1. The Copy Loop copies an invalid instruction to 0x80100000 and then copies the code after that. So the jump MUST be to 0x80100004