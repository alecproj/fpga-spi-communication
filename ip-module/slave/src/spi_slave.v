`timescale  1ns / 1ps

module spi_slave (
 SCLK,
 MOSI,
 MISO,
 SS,

 leds
);

 input SCLK;
 input MOSI;
 input SS;
 output MISO;

 output [7:0] leds;

spi_control u_spi_control(
 .SCLK(SCLK),
 .MOSI(MOSI),
 .MISO(MISO),
 .SS(SS),
 
 .data_from_master(leds)
);     

endmodule
