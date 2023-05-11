/*-------------------------------------------------------------------------------
--
-- File         : lava.h
-- Author       : Dominik Domanski
-- Date         : 28/10/10
--
-- Last Check-in :
-- $Revision: 1 $
-- $Author: dzunior $
-- $Date: 2010-10-27 20:09:58 +0200 (mié, 27 oct 2010) $
--
-------------------------------------------------------------------------------
-- Description:
-- header file for Lava uC interface operations
-------------------------------------------------------------------------------*/
#define SDRAM_MEM 0x00
#define FLASH_MEM 0x01
#define READ_CSR  0x06
#define WRITE_CSR 0x02

#define PRIMARY_BUFFER 0x00000000
#define SECONDARY_BUFFER 0x00100000
// CSR regs
#define CSR_COLOR     0x00000000
#define CSR_FONT_X    0x00000001
#define CSR_FONT_Y    0x00000002
#define TRANSPARENCY  0x00000003
#define BUFFER_REG    0x00000004
#define BUILD_VERSION 0x00000005
#define CONFIG_REG    0x00000006

// Commands
#define MEM_COPY      0x10
#define WRITE_MEM     0x20
#define READ_MEM      0x30
#define DRAW_TEXT     0x40

// FLASH Commands
#define MEM_ARRAY     0x00FF
#define STATUS_REG    0x0070
#define EL_SIGNATURE  0x0090
#define ERASE         0x0020
#define PROGRAM       0x0010
#define BLOCK         0x0060
#define LOCK          0x0001
#define UNLOCK        0x00D0
#define CFI_QUERY     0x0098
// ports
#define STROBE_N  GPIO_Pin_8
#define RNW_N     GPIO_Pin_9
#define DONE      GPIO_Pin_10
#define DATA_BUS  (GPIO_Pin_7|GPIO_Pin_6|GPIO_Pin_5|GPIO_Pin_4|GPIO_Pin_3|GPIO_Pin_2|GPIO_Pin_1|GPIO_Pin_0)

//other constants
#define SCREEN_WIDTH    800
#define SCREEN_HEIGHT   600
#define sgn(x) ((x<0)?-1:((x>0)?1:0)) /* macro to return the sign of a number */

// Function prototypes
void config_gpio(void);
void write_data(unsigned char);
unsigned char read_data(void);
void write_reg(unsigned char,unsigned int,unsigned short);
unsigned short read_reg(unsigned char,unsigned int);
unsigned short read_flash(unsigned char,unsigned int);
unsigned short write_flash(unsigned char,unsigned int,unsigned short);
void mem_copy(unsigned char,unsigned int,unsigned int,unsigned short);
void write_char(unsigned char,unsigned short,unsigned short);
void draw_line(unsigned int,unsigned int,unsigned int,unsigned int,unsigned short);
void draw_polygon(int,unsigned int*,unsigned short);
void draw_rect(int,int,int,int,unsigned short);
void draw_rect_fill(int,int,int,int,unsigned short);
void draw_bmp(unsigned char memory,unsigned int src_address,int x1,int y1,int x2,int y2,unsigned char buffer_id);
void copy_bmp2mem(unsigned char buffer_id,int x1,int y1,int x2,int y2,unsigned int dst_address,unsigned char memory);
void copy_bmp2buffer(unsigned char src_buffer,int src_x1,int src_y1,int src_x2,int src_y2,unsigned char dst_buffer,int dst_x1,int dst_y1);