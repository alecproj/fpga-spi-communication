
`timescale 1ns/1ps

module tb;

reg clk;
reg m_btn_reset;
reg s_btn_reset;
reg btn_send;

wire SCLK_MASTER;
wire SS_N_MASTER;
wire MOSI_MASTER;
wire MISO_MASTER;

wire [31:0] s_i_data;
wire [31:0] m_i_data;

wire [63:0] s_i_float;
wire [63:0] m_i_float;

wire status;

GSR GSR(.GSRI(1'b1));

//////////////////////////////////////////////////////////////// 

m_top u_m_top (
    .clk            (clk),
    .SCLK_MASTER    (SCLK_MASTER),
    .SS_N_MASTER    (SS_N_MASTER),
    .MOSI_MASTER    (MOSI_MASTER),
    .MISO_MASTER    (MISO_MASTER),
    .btn_reset      (m_btn_reset),
    .btn_send       (btn_send),

    .status(status),
    .i_data         (m_i_data),
    .i_float(m_i_float)
);

s_top u_s_top (
    .clk            (clk),
    .SCLK           (SCLK_MASTER),
    .MOSI           (MOSI_MASTER),
    .SS             (SS_N_MASTER),
    .MISO           (MISO_MASTER),
    .btn_reset      (s_btn_reset),

    .i_data         (s_i_data),
    .i_float(s_i_float)
);

//////////////////////////////////////////////////////////////// 

    initial begin
        clk=0;
        forever #10 clk=~clk;
    end

    initial begin
        m_btn_reset=1;
        s_btn_reset=1;
        btn_send=1;		
        #2000000;
        m_btn_reset=0;
        s_btn_reset=0;
        #6000000;
        m_btn_reset=1;
        s_btn_reset=1;
        #2000000;
        btn_send=0;
        #6000000;
        btn_send=1;
        #1000000;

        btn_send=0;
        #6000000;
        btn_send=1;
        #1000000;
        btn_send=0;
        #6000000;
        btn_send=1;
        #1000000;
       
        m_btn_reset=0;
        s_btn_reset=0;
        #6000000;
        m_btn_reset=1;
        s_btn_reset=1;
        #2000000;
        btn_send=0;
        #6000000;
        btn_send=1;
        #2000000;

        $finish;		
    end

endmodule
