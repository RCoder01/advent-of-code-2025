Setup (for arch linux)

Download virt disk image from https://people.debian.org/~gio/dqib/

Create image overlay with
```
qemu-img create -f qcow2 -F qcow2 -o backing_file=./dqib_riscv64-virt/image.qcow2 overlay.qcow2
```

Get uboot.elf with
```
wget http://ftp.us.debian.org/debian/pool/main/u/u-boot/u-boot-qemu_2025.01-3_all.deb \
    && ar -x u-boot-qemu_2025.01-3_all.deb \
    && tar -xvf data.tar.xz \
    && cp usr/lib/u-boot/qemu-riscv64_smode/uboot.elf ./uboot.elf
```

Run with
```
qemu-system-riscv64 -machine 'virt' -cpu 'rv64' -m 1G -device virtio-blk-device,drive=hd -drive file=./system/overlay.qcow2,if=none,id=hd -device virtio-net-device,netdev=net -netdev user,id=net,hostfwd=tcp:127.0.0.1:2222-:22 -bios /usr/share/qemu/opensbi-riscv64-generic-fw_dynamic.bin -kernel ./system/uboot.elf -object rng-random,filename=/dev/urandom,id=rng -device virtio-rng-device,rng=rng -nographic -append "root=LABEL=rootfs console=ttyS0" -virtfs local,path=src,mount_tag=host0,security_model=passthrough,id=host0
```

To install sudo, login with user and pass `root`; run `apt update` and `apt install sudo`; add `debian` to sudoers with `usermod -aG debian sudo`

User and pass are `debian`

For file sharing:

Add to /etc/fstab in the VM:
```
host0           /home/debian/src        9p      trans=virtio,version=9p2000.L   0       0
```

Exit qemu with ctrl+a, x

