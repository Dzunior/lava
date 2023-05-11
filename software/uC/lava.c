/*-------------------------------------------------------------------------------
--
-- File         : lava.c
-- Author       : Dominik Domanski
-- Date         : 28/10/10
--
-- Last Check-in :
-- $Revision: 138 $
-- $Author: dzunior $
-- $Date: 2010-10-27 20:09:58 +0200 (mié, 27 oct 2010) $
--
-------------------------------------------------------------------------------
-- Description:
-- file for Lava uC interface operations
-------------------------------------------------------------------------------*/
#include "stm32f10x_gpio.h"
#include "lava.h"
#include "stdlib.h"

GPIO_InitTypeDef GPIO_InitStructure;

void config_gpio(void)
{
  RCC_APB2PeriphClockCmd(RCC_APB2Periph_AFIO, ENABLE);
  RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);
   // set STROBE_N, RNW_N as ouputs
  GPIO_InitStructure.GPIO_Pin = STROBE_N|RNW_N|DATA_BUS;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_10MHz;
  GPIO_Init(GPIOA, &GPIO_InitStructure);
  GPIO_WriteBit(GPIOA,RNW_N,Bit_RESET);
  GPIO_WriteBit(GPIOA,STROBE_N,Bit_RESET);
  // set DONE as an input
  GPIO_InitStructure.GPIO_Pin = DONE;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;
  GPIO_Init(GPIOA, &GPIO_InitStructure);
}

void write_data(unsigned char data)
{
  // write data to port A(0:7) and reset STROBE_N
  GPIO_Write(GPIOA,(0x00FF&data));
  // wait for DONE signal
  while(GPIO_ReadInputDataBit(GPIOA,DONE)==0);
  // finish operation
  GPIO_WriteBit(GPIOA,STROBE_N,Bit_SET);
}

unsigned char read_data(void)
{
  // set DATA_BUS as an input
  GPIO_InitStructure.GPIO_Pin = DATA_BUS;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_10MHz;
  GPIO_Init(GPIOA, &GPIO_InitStructure);
  // set read mode
  GPIO_WriteBit(GPIOA,RNW_N,Bit_SET);
  // start operation
  GPIO_WriteBit(GPIOA,STROBE_N,Bit_RESET);
  while(GPIO_ReadInputDataBit(GPIOA,DONE)==0);
  // read data from port A(0:7)
  uint16_t data=GPIO_ReadInputData(GPIOA);
  // finish operation
  GPIO_WriteBit(GPIOA,STROBE_N,Bit_SET);
  // set DATA_BUS as an output
  GPIO_InitStructure.GPIO_Pin = DATA_BUS;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_10MHz;
  GPIO_Init(GPIOA, &GPIO_InitStructure);
  GPIO_WriteBit(GPIOA,RNW_N,Bit_RESET);
  return((unsigned char)data);
}

void write_reg(unsigned char command,unsigned int address,unsigned short data)
{
  // 1st byte - command
  write_data(command);
  // 2nd byte - address(bits: 23:16)
  write_data((unsigned char)((address&0x00FF0000)>>16));
  // 3rd byte - address(bits: 15:8)
  write_data((unsigned char)((address&0x0000FF00)>>8));
  // 4th byte - address(bits: 7:0)
  write_data((unsigned char)(address&0x000000FF));
  // 5th byte - data(bits: 15:8)
  write_data((unsigned char)((data&0xFF00)>>8));
  // 6th byte - data(bits: 7:0)
  write_data((unsigned char)(data&0x00FF));
}

unsigned short read_reg(unsigned char command,unsigned int address)
{
  // 1st byte - command
  write_data(command);
  // 2nd byte - address(bits: 23:16)
  write_data((unsigned char)((address&0x00FF0000)>>16));
  // 3rd byte - address(bits: 15:8)
  write_data((unsigned char)((address&0x0000FF00)>>8));
  // 4th byte - address(bits: 7:0)
  write_data((unsigned char)(address&0x000000FF));
  // read data(bits: 15:8)
  unsigned short data=(unsigned short)read_data();
  // read data(bits: 7:0)
  data=(data<<8);
  return (data|(unsigned short)read_data());
}

unsigned short read_flash(unsigned char command,unsigned int address)
{
  // 1st cycle - Address - don't care (Table 4 - Command Interface - Flash memory)
  write_reg(WRITE_MEM|FLASH_MEM,0x00000000,command);
  // 2nd cycle - read data from the register/memory array
  return read_reg(READ_MEM|FLASH_MEM,address);
}

unsigned short write_flash(unsigned char command,unsigned int address,unsigned short data)
{
  // 1st cycle - Address - don't care (Table 4 - Command Interface - Flash memory)
  write_reg(WRITE_MEM|FLASH_MEM,0x00000000,command);
  // 2nd cycle - read data from the register/memory array
  write_reg(WRITE_MEM|FLASH_MEM,address,data);
}

void mem_copy(unsigned char memory,unsigned int src_address,unsigned int dst_address,unsigned short data_size)
{
  // 1st byte - command
  write_data(MEM_COPY|memory);
  // 2nd byte - src_address(bits: 23:16)
  write_data((unsigned char)((src_address&0x00FF0000)>>16));
  // 3rd byte - src_address(bits: 15:8)
  write_data((unsigned char)((src_address&0x0000FF00)>>8));
  // 4th byte - src_address(bits: 7:0)
  write_data((unsigned char)(src_address&0x000000FF));
  // 5th byte - data_size(bits: 15:8)
  write_data((unsigned char)((data_size&0x0000FF00)>>8));
  // 6th byte - data_size(bits: 7:0)
  write_data((unsigned char)(data_size&0x000000FF));
  // 7th byte - in this case zero data just to align to 16-bit register size
  write_data(0x00);
  // 8th byte - dst_address(bits: 23:16)
  write_data((unsigned char)((dst_address&0x00FF0000)>>16));
  // 9th byte - dst_address(bits: 15:8)
  write_data((unsigned char)((dst_address&0x0000FF00)>>8));
  // 10th byte - dst_address(bits: 7:0)
  write_data((unsigned char)(dst_address&0x000000FF));
}

void write_char(unsigned char ascii_char,unsigned short position_x,unsigned short position_y)
{
    // write postion X to CSR_FONT_X register
    write_reg(WRITE_MEM|WRITE_CSR,CSR_FONT_X,position_x);
    // write postion Y to CSR_FONT_Y register
    write_reg(WRITE_MEM|WRITE_CSR,CSR_FONT_Y,position_y);
    // 1st byte - write command
    write_data(DRAW_TEXT);
    // 2nd byte - write string length max. 8
    write_data(0x01);
    // 3rd byte byte - write ascii code of the char
    write_data(ascii_char);
    // 4th byte byte - in this case zero data just to align to 16-bit register size (in case of strings longer than 1, next chars  here)
    write_data(0x00);
}
/**************************************************************************
 *  Graphic functions based on code written by David Brackeen             *
 * http://www.brackeen.com/home/vga/                                      *
 **************************************************************************/

/**************************************************************************
 *  draw_line                                                             *
 *    draws a line using Bresenham's line-drawing algorithm, which uses   *
 *    no multiplication or division.                                      *
 **************************************************************************/
void draw_line(unsigned int x1,unsigned int y1,unsigned int x2,unsigned int y2, unsigned short color)
{
  int i,dx,dy,sdx,sdy,dxabs,dyabs,x,y,px,py;

  dx=x2-x1;      /* the horizontal distance of the line */
  dy=y2-y1;      /* the vertical distance of the line */
  dxabs=abs(dx);
  dyabs=abs(dy);
  sdx=sgn(dx);
  sdy=sgn(dy);
  x=dyabs>>1;
  y=dxabs>>1;
  px=x1;
  py=y1;

  write_reg(WRITE_MEM|SDRAM_MEM,(py<<10)+px,color);

  if (dxabs>=dyabs) /* the line is more horizontal than vertical */
  {
    for(i=0;i<dxabs;i++)
    {
      y+=dyabs;
      if (y>=dxabs)
      {
        y-=dxabs;
        py+=sdy;
      }
      px+=sdx;
      write_reg(WRITE_MEM|SDRAM_MEM,(py<<10)+px,color);
    }
  }
  else /* the line is more vertical than horizontal */
  {
    for(i=0;i<dyabs;i++)
    {
      x+=dxabs;
      if (x>=dyabs)
      {
        x-=dyabs;
        px+=sdx;
      }
      py+=sdy;
      write_reg(WRITE_MEM|SDRAM_MEM,(py<<10)+px,color);
    }
  }
}

/**************************************************************************
 *  draw_polygon                                                                                                                       *
 **************************************************************************/
void draw_polygon(int num_vertices,
             unsigned int *vertices,
             unsigned short color)
{
  int i;

  for(i=0;i<num_vertices-1;i++)
  {
    draw_line(  vertices[(i<<1)+0],
                vertices[(i<<1)+1],
                vertices[(i<<1)+2],
                vertices[(i<<1)+3],
                color);
  }
  draw_line(vertices[0],
            vertices[1],
            vertices[(num_vertices<<1)-2],
            vertices[(num_vertices<<1)-1],
            color);
}

/**************************************************************************
 *  draw_rect                                                                                                                             *
 **************************************************************************/
void draw_rect(int x1,int y1, int x2, int y2, unsigned short color)
{
  unsigned int top_offset,bottom_offset,i,temp;

  if (y1>y2)
  {
    temp=y1;
    y1=y2;
    y2=temp;
  }
  if (x1>x2)
  {
    temp=x1;
    x1=x2;
    x2=temp;
  }

  top_offset=(y1<<10);
  bottom_offset=(y2<<10);
 // horizontal lines
  for(i=x1;i<=x2;i++)
  {
    write_reg(WRITE_MEM|SDRAM_MEM,top_offset+i,color);
    //write_reg(WRITE_MEM|SDRAM_MEM,bottom_offset+i,color);
  }
  // bottom line is a copy of top line
  mem_copy(SDRAM_MEM,top_offset+x1,bottom_offset+x1,x2-x1+1);
  //vertical lines
  for(i=top_offset;i<=bottom_offset;i+=0x400)
  {
    write_reg(WRITE_MEM|SDRAM_MEM,x1+i,color);
    write_reg(WRITE_MEM|SDRAM_MEM,x2+i,color);
  }
}

/**************************************************************************
 *  draw_rect _fill                                                                                                                      *
 **************************************************************************/
void draw_rect_fill(int x1,int y1, int x2, int y2, unsigned short color)
{
  unsigned int top_offset,bottom_offset,i,temp,width;

    if (y1>y2)
    {
        temp=y1;
        y1=y2;
        y2=temp;
    }
    if (x1>x2)
    {
        temp=x1;
        x1=x2;
        x2=temp;
    }

  top_offset=(y1<<10);
  bottom_offset=(y2<<10);
  width=x2-x1+1;
  // one horizontal line
  for(i=x1;i<=x2;i++)
  {
    write_reg(WRITE_MEM|SDRAM_MEM,top_offset+i,color);
    //write_reg(WRITE_MEM|SDRAM_MEM,bottom_offset+i,color);
  }
  // copies of the horizontal line
  for(i=top_offset;i<=bottom_offset;i+=0x400)
  {
    mem_copy(SDRAM_MEM,top_offset+x1,i+x1,width);
  }
}

void draw_bmp(unsigned char memory,unsigned int src_address,int x1,int y1,int x2,int y2,unsigned char buffer_id)
{
        int bmp_width=x2-x1+1;
        int bmp_height=y2-y1+1;
        for(int a=0;a<bmp_height;a++)
                mem_copy(memory,src_address+a*bmp_width,(buffer_id<<20)+((y1+a)<<10)+x1,bmp_width);
}

void copy_bmp2mem(unsigned char buffer_id,int x1,int y1,int x2,int y2,unsigned int dst_address,unsigned char memory)
{
        int bmp_width=x2-x1+1;
        int bmp_height=y2-y1+1;
        for(int a=0;a<bmp_height;a++)
                mem_copy(SDRAM_MEM,(buffer_id<<20)+((y1+a)<<10)+x1,dst_address+a*bmp_width,bmp_width);
}

void copy_bmp2buffer(unsigned char src_buffer,int src_x1,int src_y1,int src_x2,int src_y2,unsigned char dst_buffer,int dst_x1,int dst_y1)
{
        int bmp_width=src_x2-src_x1+1;
        int bmp_height=src_y2-src_y1+1;
        for(int a=0;a<bmp_height;a++)
                mem_copy(SDRAM_MEM,(src_buffer<<20)+((src_y1+a)<<10)+src_x1,(dst_buffer<<20)+((dst_y1+a)<<10)+src_x1,bmp_width);
}