/*-------------------------------------------------------------------------------
--
-- File         : Accelerator.vhd
-- Author       : Dominik Domanski
-- Date         : 27/03/10
--
-- Last Check-in :
-- $Revision: 138 $
-- $Author: dzunior $
-- $Date: 2010-10-27 20:09:58 +0200 (mié, 27 oct 2010) $
--
-------------------------------------------------------------------------------
-- Description:
-- Top module
-------------------------------------------------------------------------------*/
#include "stm32f10x.h"
#include "system_stm32f10x.h"
#include "lava.h"
#include "stdlib.h"

int main(void);
unsigned short a=0;
unsigned short data=0xFFFF;
unsigned short temp_data=0;
uint16_t  status=0;
int vertices[6]={500,0,    /* (x1,y1) */
                 700,500,    /* (x2,y2) */
                 1,400};   /* (x3,y3) */

/*----------------------------------------------------------------------------
  MAIN function
 *----------------------------------------------------------------------------*/
int main (void)
{
  SystemInit();
  config_gpio();
  write_reg(WRITE_MEM|WRITE_CSR,CSR_COLOR,0xFFFF);
//  for(int b=0;b<800;b++)
//     write_reg(WRITE_MEM|SDRAM_MEM,0x100000+b,0x0000);
  while(1)
  {

//lines
//    for(char z=0;z<10;z++)
//      {
//        for (int a=0;a<50;a++)
//                {
//                data=data+0x2104;
//                draw_line(400,300,a*16,0,data);
//                };
//        for (int a=0;a<40;a++)
//                {
//                data=data+0x2104;
//                draw_line(400,300,800,a*15,data);
//                };
//        for (int a=50;a>0;a--)
//                {
//                data=data+0x2104;
//                draw_line(400,300,a*16,600,data);
//                };
//        for (int a=40;a>0;a--)
//                {
//                data=data+0x2104;
//                draw_line(400,300,0,a*15,data);
//                };
//        };
    //write_reg(WRITE_MEM|WRITE_CSR,BUFFER_REG,0x0100);
//  draw_rect(0,0,0,0,data);
//  for(int z=0;z<600;z++)
//      mem_copy(SDRAM_MEM,0x100000,0x000000+z*1024,800);
//  for (int a=50;a>0;a--)
//  {
//      int x1=rand()%799;
//      int y1=rand()%599;
//      int x2=rand()%799;
//      int y2=rand()%599;
//      data=rand();
//      draw_rect(x1,y1,x2,y2,data);
//   };
//
//  for(int z=0;z<600;z++)
//      mem_copy(SDRAM_MEM,0x100000,0x000000+z*1024,800);
//  for (int a=50;a>0;a--)
//  {
//      int x1=rand()%799;
//      int y1=rand()%599;
//      int x2=rand()%799;
//      int y2=rand()%599;
//      data=rand();
//      draw_rect_fill(x1,y1,x2,y2,data);
//   };
  //unsigned short read_flash(MEM_ARRAY,0x008000+a);
//  for(int a=0;a<1000;a++)
//    data=read_flash(MEM_ARRAY,0x008000+a);
//   for (int icon=0;icon<50;icon++)
//        {
//          //write_char((unsigned char)icon+33,icon*9,0);
//          for (int z=0;z<64;z++)
//          mem_copy(FLASH_MEM,0x008000+icon*0x1000+z*64,0x0100F0+z*1024,64);
//          for(int c=0;c<100;c++);
//        };
write_flash(BLOCK,0x020000,UNLOCK);
write_flash(BLOCK,0x028000,UNLOCK);
write_flash(BLOCK,0x030000,UNLOCK);
write_flash(BLOCK,0x038000,UNLOCK);

for(int a=0;a<23870;a++)
{
        //write_reg(WRITE_MEM|SDRAM_MEM,0x200000+a,file_data[a]);
        write_flash(PROGRAM,0x027000+a,file_data[a]);
        for(int a=0;a<40000;a++);
};

write_reg(WRITE_MEM|WRITE_CSR,CONFIG_REG,0x0001);
for(int a=0;a<50000;a++);
draw_bmp(FLASH_MEM,0x021000,0,0,154,155,PRIMARY_BUFFER);
draw_bmp(FLASH_MEM,0x027000,0,0,154,155,PRIMARY_BUFFER);
draw_bmp(FLASH_MEM,0x02D000,0,0,154,155,PRIMARY_BUFFER);
draw_bmp(FLASH_MEM,0x033000,0,0,154,155,PRIMARY_BUFFER);
draw_bmp(FLASH_MEM,0x039000,0,0,154,155,PRIMARY_BUFFER);

for(int a=0;a<100000;a++);
  for(int a=0;a<25;a++)
    {
    draw_bmp(FLASH_MEM,0x008000+a*0x1000,0,0,63,63,PRIMARY_BUFFER);
    //for(int c=0;c<100000;c++);
    for(int a=0;a<520;a++)
    //{
      copy_bmp2buffer(PRIMARY_BUFFER,0,0,63,63,PRIMARY_BUFFER,0,a+64);
      //for(int c=0;c<1000;c++);
    };
  };
}
//    data=data+0x2104;
////    draw_polygon(3,vertices,0xF800);
////    draw_rect(100,100,600,400,0x001F);
////    draw_rect_fill(10,10,60,40,0x001F);
//  }
//}
// flashing text
//  {
//    a++;
//    //data=read_reg(READ_MEM|READ_CSR,BUILD_VERSION);
//    for(int y=0;y<50;y++)
//      {
//      for(int x=0;x<800;x++)
//        {
//        write_reg(WRITE_MEM|WRITE_CSR,CSR_COLOR,data);
//        //write_reg(WRITE_MEM|SDRAM_MEM,(unsigned int)((y<<10)|x),data);
//        for (int icon=0;icon<50;icon++)
//        {
//          write_char((unsigned char)icon+33,icon*9,0);
////          for (int z=0;z<64;z++)
////          mem_copy(FLASH_MEM,0x008000+icon*0x1000+z*64,0x0100F0+z*1024,64);
//          for(int c=0;c<100;c++);
//        };
//        data=data+0x2104;
//        //for(int c=0;c<100;c++);
//        };
//      };
//
//      //temp_data=read_reg(READ_MEM|READ_CSR,(unsigned int)a);
//    //data=read_reg(READ_MEM|READ_CSR,BUILD_VERSION);
//  } // end
//} // end main
