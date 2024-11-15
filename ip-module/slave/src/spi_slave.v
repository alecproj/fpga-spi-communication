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
 
 reg [7:0] data = 8'b00110011;

spi_control u_spi_control(
 .SCLK(SCLK),
 .MOSI(MOSI),
 .MISO(MISO),
 .SS(SS),
 
 .data_from_master(leds),
 .data_to_master(data)
);     

endmodule
