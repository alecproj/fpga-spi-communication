`timescale  1ns / 1ps

module spi_slave (
 SCLK,
 MOSI,
 MISO,
 SS
);

 input SCLK;
 input MOSI;
 input SS;
 output MISO;

spi_control u_spi_control(
 .SCLK(SCLK),
 .MOSI(MOSI),
 .MISO(MISO),
 .SS(SS)
);     

endmodule
