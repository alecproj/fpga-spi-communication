`timescale  1ns / 1ps

module spi_slave (
 clk,
 SCLK,
 MOSI,
 MISO,
 SS,

 leds,
 cols,
 rows,

 debug,
 test
);

 input clk;
 input SCLK;
 input MOSI;
 input SS;
 output MISO;
 
 output reg [7:0] leds;
 output reg [3:0] cols;
 output reg [2:0] rows;

 output reg debug;
 output test;
 
 reg [7:0] o_data;
 
 reg [17:0] cooldown=0;
 reg [3:0] history [0:2];
 reg [1:0] cur_index = 0;

 wire [7:0] i_data;

 wire receiveing;
 wire transmitting;
 reg flag=1;

initial begin
    history[0] = 4'b0;
    history[1] = 4'b0;
    history[2] = 4'b0;
    cols = 0;
    rows = 3'b111;
    o_data = 8'b11111111;
end

always @(negedge receiveing) begin
          history[0] <= history[1];
          history[1] <= history[2];
          history[2] <= ~i_data;
          leds <= i_data;
end



always @(posedge clk)
    if (cooldown == 0) begin
        cooldown <= 150000;
        rows <= ~(3'b001 << cur_index);
        cols <= history[cur_index];
        if (cur_index == 2)
            cur_index <= 0;
        else cur_index <= cur_index + 1;
    end
    else cooldown <= cooldown - 1;
   
    
   
always @(negedge transmitting) begin
    o_data <= o_data - 1'b1;
    debug <= ~debug;
end

s_spi_control u_spi_control(
 .SCLK(SCLK),
 .MOSI(MOSI),
 .MISO(MISO),
 .SS(SS),
 
 .data_from_master(i_data),
 .data_to_master(o_data),
 .receiveing(receiveing),
 .transmitting(transmitting),
 .dbg(test)
);     

endmodule
