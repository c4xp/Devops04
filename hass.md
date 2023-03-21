# Hacking the Silvercrest (Lidl) Smart Home Gateway

![Pcb Top](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/lidlgateway.png)

## Overview

Here we present a quick teardown of the Lidl Smart Home Gateway and a quick introduction to gaining access to the Linux root shell of the device.

This device is plesantly "hackable," and gaining access to the device to load custom firmware and modifications is easy. (once you have physical access.) As a general point I think this is how it should always be. An electronic device that is totally locked down to the manufacturer provides no opportunites for further use and thus its potential for education, entertainment and utility beyond what the original manufacturer forsaw is lost.

One of the aspirations for this project is to turn this device into a simple ZigBee gateway, capable of running basic functions (light switches, etc) autonomously in offline mode but also supporting an online mode integrated with Home Assistant. If I have time I will develop this but no promises!

## Home Assistant Integration

You can use this hack to [directly integrate this gateway with Home Assistant](https://paulbanks.org/projects/lidl-zigbee/ha/). Click the link for more information.

## Disassembly

The home gateway uses a screwless design to hold the case together. There are 8 plastic clips spread equally around the case and you need to work carefully around about half of them until you can separate the lid from the case.
What's inside?

Inside the gateway there's a single PCB featuring a main CPU, some RAM, an SPI flash chip, a separate ZigBee CPU, ethernet magnetics, LEDs, connectors and other supporting components. A neat design overall.
PCB Top Side

## What's inside?

Inside the gateway there's a single PCB featuring a main CPU, some RAM, an SPI flash chip, a separate ZigBee CPU, ethernet magnetics, LEDs, connectors and other supporting components. A neat design overall.

## PCB Top Side

![Pcb Top](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/pcbtop.jpg)

Main components are detailed here:

U2 - A RealTek RTL8196E MIPS System-on-a-chip (SoC) CPU.
U3 - A 16MB SPI Flash (GD25Q127)
U5 - A 32MB SDRAM, EM6AA160.
CN1 - A TuYa ZigBee module (TYZS4) which is based on a Silicon Labs ARM-M4 CPU with integrated RF stack. (EFR32MG1B232.)

J1 - A Combined Serial port and ZigBee module ARM debug port. This is not usually populated - we added a header to ours. Pinout is:
    Pin 1 = Vcc (3.3V) (bottom pin in picture)
    Pin 2 = Ground
    Pin 3 = U2 Serial TX
    Pin 4 = U2 Serial RX
    Pin 5 = ZigBee module ARM Debug SWDIO
    Pin 6 = ZigBee module ARM Debug SWCLK

Serial port parameters are:
    Electrical: TTL 3.3V
    Baud Rate: 38400 bps
    Other: 8N1 (8-bit, No Parity, 1 stop bit)

## PCB Side B

The manufacturer has kindly labelled the test points.

## Firmware hacking

Warning Triangle Notes for newbies: You must use a 3.3V TTL serial port to connect to this device. Connect only Ground (GND), TX and RX. Do not connect Vcc. Do not be tempted to connect the device directly to a PC serial port. Failure to observe these notes may damage your device.

After connecting a 3.3V TTL Serial port to J1, the Linux Console is available. Note, this is password protected and the password is different for each device. More on this later.

## Bootloader

When starting the device, the bootloader is accessible by pressing ESC on the console very early on in the boot process. Doing this will stop the boot process and land you in the RealTek bootloader prompt.

Entering a ?, followed by enter will list out the available commands. Available features include the ability to read and write the FLASH, download from a TFTP server into memory, and inspect memory.

The bootloader has a default IP address of 192.168.1.6 and the TFTP server is set to 192.168.1.97.

## Flash layout

The bootlog helpfully shows the flash layout as follows:

```
0x000000000000-0x000000020000 : "boot+cfg"
0x000000020000-0x000000200000 : "linux"
0x000000200000-0x000000400000 : "rootfs"
0x000000400000-0x000000420000 : "tuya-label"
0x000000420000-0x000001000000 : "jffs2-fs"
```

Backup

It's always a good idea to backup devices, where possible, before playing around. To do this, rather than desolder the SPI, we created a script (dump.py) to repeatedly call the FLR and DB commands and we used that to create a backup copy of the flash. It took a long time for the script to run but it was overnight so we didn't care.
Gaining initial access

Note: Below is how we gained access initially. We have since created a script that reveals the root password without needing to do the below.

1 We pulled the SquashFS rootfs. This process took about 40 minutes.

```
python dump_flash.py --serial-port /dev/ttyUSB0 --output-file rootfs.bin --start-addr 0x200000 --end-addr 0x400000
```

2 We extracted the SquashFS

```
sudo unsquashfs rootfs.bin
```

3 We replaced the /etc/passwd symlink with a passwd file we created with a known root password. The password for this one is "password":

```
root:dMPfG7vdo8u1I:0:0:root:/:/bin/sh
```

5 We wrote a script [rootfs_tool.py](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/rootfs_tool.py) to modify the header to include the new length and fix up the 16-bit checksum on the end

```
python rootfs_tool.py build newroot.sqfs newroot.bin
```

6 Finally we TFTP'd the newroot.bin file to the device and used the bootloader command FLW to write it to flash.

After booting up, we were able to log into the device as root. Win.

## ZigBee module

Attaching an ARM debugger to pins 5 and 6 of J1 allows inspection and live debugging of the ZigBee module CPU and backing up the code if required. We used a Segger J-Link Edu Mini whih supports this part directly.

Security notes
Root password

The actual root password is set, each time the device boots, to the last 8 characters of the device's "auzkey". Running "/tuya/tuyamtd read auzkey" on the device will tell you this value. You can also read this value straight out of flash using this technique.

## SSH Server

The device runs an SSH server (dropbear) on port 2333. The server has some brute force protection whereby failed logins will cause the device to stop this server for an increasing amount of time. The device has to be left switched on for the anti-brute force timer to expire because the failure counter is stored persistently in the flash. If you already have filesystem access, you can reset this prematurely by deleting the /tuya/ssh/cnt file.

# Getting root password - Hacking the (Silvercrest) Lidl Smart Home Gateway 

## Revealing the root password

## Overview

The root password is set to the last 8 characters of AUSKEY which is some kind of identifier for the cloud services. The AUSKEY is stored, encrypted, in the SPI flash. (in the "tuya-label" partition.) The decryption key is also stored here so it is possible to recover the AUSKEY and thus also the root password for the device.

## Get the root password

Getting the root password comprises three steps. 1. Accessing the bootloader. 2. Using it to read the raw encoded values from the flash. 3. Decoding the values.

## Read the raw encoded values from flash.

Notes for newbies: You must use a 3.3V TTL serial port to connect to this device. Connect only Ground (GND), TX and RX. Do not connect Vcc. Do not be tempted to connect the device directly to a PC serial port. Failure to observe these notes may damage your device.

To get the required values, you need to have attached a TTY3v3 serial port to the J1 connector on the board. The serial port parameters are 38400 baud, 8, N, 1 and no flow control. (If you find you can't type, check flow control is turned off.)

## Accessing the bootloader

Power cycle the device whilst at the same time pressing the ESC key on the serial console. You should interrupt the boot process and end up at the RealTek bootloader prompt.

Press ENTER to get a fresh prompt.

It should look something like this:

```
---RealTek(RTL8196E)at 2020.04.28-13:58+0800 v3.4T-pre2 [16bit](400MHz)
P0phymode=01, embedded phy
check_image_header  return_addr:05010000 bank_offset:00000000
no sys signature at 00010000!

---Escape booting by user
P0phymode=01, embedded phy

---Ethernet init Okay!
<Real
<RealTek>
```

## Reading the key-encryption-key (KEK)

The AUSKEY is itself encrypted by another key that we'll call the KEK. To read the KEK, type the following commands into the bootloader. The first command reads the value from flash into RAM. The next one displays the contents.

```
FLR 80000000 401802 16
DW 80000000 4
```

Make a note of the single line of output. This is your KEK.

## Read the encrypted AUSKEY

Use the following commands

```
FLR 80000000 402002 32
DW 80000000 8
```

Make a note of the two lines of output. They are your encrypted AUSKEY.

## Decode the values

The script linked below can be used to decode the AUSKEY and root password.

[Python script](https://raw.githubusercontent.com/c4xp/Devops04/master/assets/lidl_auskey_decode.py)

Start the python script and, when prompted, paste the lines obtained above to reveal your auskey and root password.

Example decode run :

```
python lidl_auskey_decode.py
Enter KEK hex string line>80000000: 7E7E7E7E       7E7E7E7E 7E7E7E7E
     7E7E7E7E
Encoded aus-key as hex string line 1>80000000:  ********
******** ********
Encoded aus-key as hex string line 2>80000010:  ********
******** ********
Auskey: b'****************'
Root Password: b'********'
```

[Paul Banks: Project lidl zigbee](https://paulbanks.org/projects/lidl-zigbee/#overview)