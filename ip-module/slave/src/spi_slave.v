`timescale  1ns / 1ps

module spi_slave (
 SCLK,
 MOSI,
 MISO,
 SS,

 leds,
 debug,
 test
);

 input SCLK;
 input MOSI;
 input SS;
 output MISO;

 output [7:0] leds;
 output reg debug;
 output test;
 
 reg [7:0] data = 8'b11111111;

 wire receiveing;
 wire transmitting;
 reg flag=0;
   
always @(posedge transmitting) begin
    data <= data - 1'b1;
    debug <= ~debug;
end

spi_control u_spi_control(
 .SCLK(SCLK),
 .MOSI(MOSI),
 .MISO(MISO),
 .SS(SS),
 
 .data_from_master(leds),
 .data_to_master(data),
 .receiveing(receiveing),
 .transmitting(transmitting),
 .dbg(test)
);     

endmodule
