`timescale 1ns/1ps

module s_top
(
    clk,
    SCLK,
    MOSI,
    SS,
    MISO,
    btn_reset,

    i_data,
    i_float
);

    input clk;
    input SCLK;
    input MOSI;
    input SS;
    output MISO;
    input  btn_reset;

    output [31:0] i_data;
    output [63:0] i_float;

////////////////////////////////////////////////////////////////   
// Internal Wires/Registers
    
    wire reset;
    wire status;

    //wire [63:0] i_float;
    reg  [63:0] o_float=64'h3333333366666666;

///////////////////////////////////////////////////////////////////////////

s_btn_control u_btn_control (
    .clk                   ( clk            ),
    .btn_reset             ( btn_reset      ),
    .reset                 ( reset          )
);

s_64spi u_64_spi (
    .clk                   ( clk            ),
    .SCLK                  ( SCLK           ),
    .MOSI                  ( MOSI           ),
    .MISO                  ( MISO           ),
    .SS                    ( SS             ),
    .in                    ( i_float        ),
    .out                   ( o_float        ),
    .reset                 ( reset          ),
    .status                ( status         ),

    .i_data                ( i_data         )
);

endmodule