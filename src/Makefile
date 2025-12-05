%.o: %.s
	riscv64-linux-gnu-as -o $@ $< -march=rv64imafdch_zicbom_zicbop_zicboz_ziccrse_zicntr_zicsr_zifencei_zihintntl_zihintpause_zihpm_zaamo_zalrsc_zawrs_zfa_zca_zcd_zba_zbb_zbc_zbs_sstc_svadu

%.elf: %.o link.ld
	riscv64-linux-gnu-ld -T link.ld -o $@ $<

clean:
	rm -f *.elf *.o
