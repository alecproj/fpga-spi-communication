`timescale 1ns/1ps

module m_top
(
    clk,
    SCLK_MASTER,
    SS_N_MASTER,
    MOSI_MASTER,
    MISO_MASTER,
    btn_reset,
    btn_send
);

    input  clk;
    output SCLK_MASTER;
    output SS_N_MASTER;
    output MOSI_MASTER;
    input  MISO_MASTER;
    input  btn_reset;
    input  btn_send;

////////////////////////////////////////////////////////////////   
// Internal Wires/Registers

    wire start;
    wire reset;
    wire status;
    
    wire [63:0] i_float;
    reg  [63:0] o_float=64'h5555555577777777;

///////////////////////////////////////////////////////////////////////////

 m_64spi u_64spi (
    .clk                ( clk          ),
    .SCLK_MASTER        ( SCLK_MASTER  ),
    .SS_N_MASTER        ( SS_N_MASTER  ),
    .MOSI_MASTER        ( MOSI_MASTER  ),
    .MISO_MASTER        ( MISO_MASTER  ),
    .reset              ( reset        ),
    .start              ( start        ),
    .in                 ( i_float      ),
    .out                ( o_float      ),
    .status             ( status       )
);

 m_btn_control u_btn_control (
    .clk                 ( clk          ),
    .btn_send            ( btn_send     ),
    .btn_reset           ( btn_reset    ),
    .start               ( start        ),
    .reset               ( reset        )
);

endmodule