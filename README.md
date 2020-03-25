uClinux for STM32F429IDISCO
===========================

This is a fork from from jserv/stm32f429-linux-builder, a bunch of Makefile
stuff to build UBoot+uClinux+BusyBox+rootfs for STM32F429IDISCO board.

The goal is to integrate Robutest source stuff :
* [U-Boot bootloader](https://github.com/robutest/u-boot)
* [uClinux 2.6.33 kernel](https://github.com/robutest/uclinux)
* [Busybox](https://github.com/robutest/busybox)
in one place to play with, adding stuff, change default configuration...

Changes from jserv and Robutest/tmk versions :

* add 5s default **bootdelay** to U-Boot
* switch **console** from ``ttyS2`` to ``ttyS0`` (uboot & uClinux & login) : PA10 = RX / PA09 = TX
* add missing ``/sys`` mount point in rootfs
* change ``/etc/start`` comment out ``/sys/class/gpio/*`` export on GPIO 109 and 110.
* add ``/sys/class/leds`` support for **LD3** and **LD4** (this one default to ``heartbeat``)
* add **i2c bus support** (``/dev/i2c-2``). ``i2cdetect`` show onboard STMPE811 (4-wire resistive touch screen controller) :
```
# i2cdetect 2
WARNING! This program can confuse your I2C bus, cause data loss and worse!
I will probe file /dev/i2c-2.
I will probe address range 0x03-0x77.
Continue? [Y/n]
     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
00:          -- -- -- -- -- -- -- -- -- -- -- -- --
10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
40: -- 41 -- -- -- -- -- -- -- -- -- -- -- -- -- --
50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
60: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
70: -- -- -- -- -- -- -- --
```
* add **SPI** and **spi-dev** support on SPI5 (with CS on PC1). Onboard ST L3GD20 MEMS motion sensor 3-axis digital gyroscope reply on ``/dev/spi0`` (153:0) to WHOAMI (0001111) with L3GD20 id (11010100) :

```
 # spidev_test -D /dev/spi0
 spi mode: 0
 bits per word: 8
 max speed: 500000 Hz (500 KHz)

 FF D4
```
* add little **blue button** to get an interrupt when pushed
* add external **SPI4 support** (SCK/NSS/MISO/MOSI on PE2/PE4/PE5/PE6) with **MMC** SPI (default in kernel config) or spi-dev (if MMC SPI disabled). Not perfect because card detection on PA5 use polling (not IRQ, i'm not very happy with this), but it works :

```
spi_stm32 spi_stm32.4: SPI Controller 4 at 40015000,hz=90000000
mmc_spi spi3.0: ASSUMING SPI bus stays unshared!
mmc_spi spi3.0: ASSUMING 3.2-3.4 V slot power
INFO: enabling interrupt on SD detect
mmc_spi spi3.0: SD/MMC host mmc0, no DMA, no WP, no poweroff
mmc0: new MMC card on SPI
mmcblk0: mmc0:0001 AF HMP 490 MiB
 mmcblk0: p1
[...]

~ # mount /dev/mmcblk0p1 /mnt/sdcard/
~ # df
Filesystem           1K-blocks      Used Available Use% Mounted on
/dev/root                  415       415         0 100% /
/dev/ram0                 1003        17       986   2% /var
/dev/mmcblk0p1          484898      2364    457498   1% /mnt/sdcard
~ # ls /mnt/sdcard/
gpg.conf      pubring.gpg   random_seed   trustdb.gpg
lost+found    pubring.gpg~  secring.gpg
~ # umount /mnt/sdcard/
```

* add more code to ``exti.c`` to manage STM32 EXTI and a push button support on PC3 (just to play with). ``stm32_exti_set_gpio(port,pin)`` can now be used to choose wich GPIO can trigger an interrupt, in addition to ``stm32_exti_enable_int(line, edge)`` and ``stm32_exti_disable_int(line)`` (replace EmCraft ``stm32_exti_enable_int(line,enable)``) to set EXTI registers/configuration. This will soon change MMC card detection from polling to IRQ managed. For more information on EXTI/NVIC read [RM0090](http://www.st.com/web/en/resource/technical/document/reference_manual/DM00031020.pdf) page 368.

* add Ethernet support with ENC28J60 board on external SPI5 (SCK/CS/SO/SI/INT on PF7/PF6/PF8/PF9/PC3). MAC address is set at boot time in ```rootfs/etc/start``` and static IP address set is in ``rootfs/etc/network/interfaces`` (DHCP too heavy). Note : with ET-MINI ENC28J60 from www.etteam.com SO is "SDI" and SO is "SDO" on the PCB.

```
~ # dmesg
[...]
spi_stm32 spi_stm32.3: SPI Controller 3 at 40013400,hz=90000000
spi_stm32 spi_stm32.4: SPI Controller 4 at 40015000,hz=90000000
enc28j60 spi4.0: enc28j60 Ethernet driver 1.01 loaded
net eth0: enc28j60 driver registered
i2c /dev entries driver
[...]
Freeing init memory: 16K
net eth0: link down
net eth0: link up - Half duplex
[...]

~ # ifconfig eth0
eth0      Link encap:Ethernet  HWaddr DE:AD:BE:EF:FE:ED
          inet addr:192.168.0.17  Bcast:192.168.0.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:470 errors:0 dropped:0 overruns:0 frame:0
          TX packets:107 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:42104 (41.1 KiB)  TX bytes:14004 (13.6 KiB)
          Interrupt:9
```

* Added i2c bitbang bus SDA/SCL on PC4/PC5 for DS1338 RTC. Trying to use I2C2 (PB11/PB10) not working because PB11 is G5 and PB10 G4 : green 5 & 4 for LCD driving. Same apply to bitbang i2c on PB11/PB10. Added DS1307 support and hwclock fron BusyBox. We now get time/date at boot time ! PC4/PC5 are OTG pins, this will be a problem later...

TODO:

* more cleaning
* replace sourceless ``fbtest`` with nyancat
* add ST L3GD20 gyroscope userspace tool
* STMPE811 as input device
* add ADC support
* add audio (?)
* add RTC (?)
* add USB (?)

Note : you may need to go back to bootloader to be able to use OpenOCD and stop CPU to access flash for writer. So, just reboot and stop U-Boot in delay count before you ``make install``.

Original README from jserv follow.

stm32f429-linux-builder
=======================
This is a simple tool designed to create a uClinux distribution for STM32f429
Discovery board from [STMicroelectronics](http://www.st.com/). STM32F429 MCU
offers the performance of ARM Cortex M4 core (with floating point unit) running
at 180 MHz while reaching reasonably lower static power consumption.


Prerequisites
=============
The builder requires that various tools and packages be available for use in
the build procedure:

* [OpenOCD](http://openocd.sourceforge.net/)
```
    git clone git://git.code.sf.net/p/openocd/code openocd
    cd openocd
    ./bootstrap
    ./configure --prefix=/usr/local --enable-stlink
    echo -e "all:\ninstall:" > doc/Makefile
    make
    sudo make install
```
* Set ARM/uClinux Toolchain:
  - Download [arm-2010q1-189-arm-uclinuxeabi-i686-pc-linux-gnu.tar.bz2](http://www.codesourcery.com/sgpp/lite/arm/portal/package6503/public/arm-uclinuxeabi/arm-2010q1-189-arm-uclinuxeabi-i686-pc-linux-gnu.tar.bz2) from CodeSourcery
  - only arm-2010q1 is known to work; don't use SourceryG++ arm-2011.03
```
    tar jxvf arm-2010q1-189-arm-uclinuxeabi-i686-pc-linux-gnu.tar.bz2
    export PATH=`pwd`/arm-2010q1/bin:$PATH
```
* [genromfs](http://romfs.sourceforge.net/)
```
    sudo apt-get install genromfs
```


Build Instructions
==================
* Simply execute ``make``, and it will fetch and build u-boot, linux kernel, and busybox from scratch:
```
    make
```
* Once STM32F429 Discovery board is properly connected via USB wire to Linux host, you can execute ``make install`` to flash the device. Note: you have to ensure the installation of the latest OpenOCD in advance.
```
    make install
```
Be patient when OpenOCD is flashing. Typically, it takes about 55 seconds.
Use `make help` to get detailed build targets.


USART Connection
================
The STM32F429 Discovery is equipped with various USARTs. USART stands for
Universal Synchronous Asynchronous Receiver Transmitter. The USARTs on the
STM32F429 support a wide range of serial protocols, the usual asynchronous
ones, plus things like IrDA, SPI etc. Since the STM32 works on 3.3V levels,
a level shifting component is needed to connect the USART of the STM32F429 to
a PC serial port.

Most PCs today come without an native RS232 port, thus an USB to serial
converter is also needed.

For example, we can simply connect the RX of the STM32 USART3 to the TX of
the converter, and the TX of the USART3 to the RX of the converter:
* pin PC10 -> TXD
* pin PC11 -> RXD


Reference Boot Messages
=======================
```
U-Boot 2010.03-00003-g934021a ( Feb 09 2014 - 17:42:47)

CPU  : STM32F4 (Cortex-M4)
Freqs: SYSCLK=180MHz,HCLK=180MHz,PCLK1=45MHz,PCLK2=90MHz
Board: STM32F429I-DISCOVERY board,Rev 1.0
DRAM:   8 MB
Using default environment

Hit any key to stop autoboot:  0 
## Booting kernel from Legacy Image at 08020000 ...
...

Starting kernel ...

Linux version 2.6.33-arm1 (jserv@venux) (gcc version 4.4.1 (Sourcery G++ Lite 2010q1-189) ) #2 Sun Feb 9 17:54:20 CST 2014
CPU: ARMv7-M Processor [410fc241] revision 1 (ARMv7M)
CPU: NO data cache, NO instruction cache
Machine: STMicro STM32
...
VFS: Mounted root (romfs filesystem) readonly on device 31:0.
Freeing init memory: 16K
starting pid 25, tty '/dev/ttyS2': '/bin/login -f root'
Welcome to
          ____ _  _
         /  __| ||_|                 
    _   _| |  | | _ ____  _   _  _  _ 
   | | | | |  | || |  _ \| | | |\ \/ /
   | |_| | |__| || | | | | |_| |/    \
   |  ___\____|_||_|_| |_|\____|\_/\_/
   | |
   |_|

For further information check:
http://www.uclinux.org/
```
