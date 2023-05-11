# LAVA 10

**Introduction**



**LAVA 10** is an SVGA Graphics Controller based on an FPGA module (XC3S200 Xilinx SPARTAN 3), designed for use in embedded systems. The main task of this device is to take over most of the complex operations related to displaying graphics from the main processor.


Features:

• 3-in-1 Integrated SVGA Display Controller, SDRAM Controller, and Flash Memory Controller

• Displays 65536 colors (RGB565) in SVGA (800x600) resolution (60Hz) – perfect for use with LCD Monitors

• Xilinx Spartan 3 (XC3S200)

• 32 MB SDRAM memory for storing frames (2 buffers) and for general purposes (not necessarily related to graphics)

• 8 MB Flash memory for storing non-volatile data (fonts, icons, pictures, etc.)

• Ready to use with the Evaluation Board

• Embedded character generator (Code page 4371 based characters)

• Outputs for Video DAC

• Fast 8-bit interface for bidirectional communication (can be connected to any host controller)

• Reprogrammable via JTAG interface (adding new hardware functions, using module for other FPGA-based projects, etc.)

• Single low-power design: 3.0-3.6V supply @100mA

• Prepared for use directly in the application or with the evaluation board

• Simple instruction set (library written in C is available)
