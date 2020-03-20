FLASH_CMD := openocd \
	-f interface/stlink-v2.cfg \
	-f target/stm32f4x_stlink.cfg \
	-c "init" \
	-c "reset init" \
	-c "flash probe 0" \
	-c "flash info 0" \
	-c "flash write_image erase $(uboot_target)  0x08000000" \
	-c "flash write_image erase $(kernel_target) 0x08020000" \
	-c "flash write_image erase $(rootfs_target) 0x08140000" \
	-c "reset run" -c shutdown

FLASH_CMD_UBOOT := openocd \
	-f interface/stlink-v2.cfg \
	-f target/stm32f4x_stlink.cfg \
	-c "init" \
	-c "reset init" \
	-c "flash probe 0" \
	-c "flash info 0" \
	-c "flash write_image erase $(uboot_target)  0x08000000" \
	-c "reset run" -c shutdown

FLASH_CMD_KERN := openocd \
	-f interface/stlink-v2.cfg \
	-f target/stm32f4x_stlink.cfg \
	-c "init" \
	-c "reset init" \
	-c "flash probe 0" \
	-c "flash info 0" \
	-c "flash write_image erase $(kernel_target) 0x08020000" \
	-c "reset run" -c shutdown

FLASH_CMD_ROOTFS := openocd \
	-f interface/stlink-v2.cfg \
	-f target/stm32f4x_stlink.cfg \
	-c "init" \
	-c "reset init" \
	-c "flash probe 0" \
	-c "flash info 0" \
	-c "flash write_image erase $(rootfs_target) 0x08140000" \
	-c "reset run" -c shutdown
