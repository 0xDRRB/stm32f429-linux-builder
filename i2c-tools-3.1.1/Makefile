# I2C tools for Linux
#
# Copyright (C) 2007-2012  Jean Delvare <jdelvare@suse.de>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

#CROSS_COMPILE ?= /home/denis/tmp/STM/arm-2010q1/bin/arm-uclinuxeabi-

AS = $(CROSS_COMPILE)as
CC = $(CROSS_COMPILE)gcc
LD = $(CC) -nostdlib
CPP = $(CC) -E
AR = $(CROSS_COMPILE)ar
NM = $(CROSS_COMPILE)nm
STRIP = $(CROSS_COMPILE)strip
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

DESTDIR	=
prefix	= /usr/local
bindir	= $(prefix)/bin
sbindir	= $(prefix)/sbin
mandir	= $(prefix)/share/man
man8dir	= $(mandir)/man8
incdir	= $(prefix)/include

INSTALL		:= install
INSTALL_DATA	:= $(INSTALL) -m 644
INSTALL_DIR	:= $(INSTALL) -m 755 -d
INSTALL_PROGRAM	:= $(INSTALL) -m 755
RM		:= rm -f

CC	?= gcc

CFLAGS	?= -O2
# When debugging, use the following instead
#CFLAGS	:= -O -g
CFLAGS	+= -Wall

KERNELVERSION	:= $(shell uname -r)

.PHONY: all strip clean install uninstall

all:

EXTRA	:=
#EXTRA	+= py-smbus
SRCDIRS	:= include eeprom stub tools $(EXTRA)
include $(SRCDIRS:%=%/Module.mk)
