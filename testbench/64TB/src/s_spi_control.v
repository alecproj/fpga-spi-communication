`timescale 1ns / 1ps

`define     DATA_LENGTH         32

module s_spi_control (
    SCLK,
    MOSI,
    MISO,
    SS,

    i_data,
    o_data,
    is_receiveing,
    is_transmitting
);

    input                       SCLK;
    input                       MOSI;
    input                       SS;
    output                      MISO;

    output reg [`DATA_LENGTH-1:0]            i_data;
    input [`DATA_LENGTH-1:0]                 o_data;
    output reg                  is_receiveing;
    output reg                  is_transmitting;

///////////////////////////////////////////////////////////////////////////
// Internal Wires/Registers

    reg [5:0]                   rx_cnt                  =       0;
    reg [5:0]                   tx_cnt                  =       0;
    reg [`DATA_LENGTH-1:0]      mosi_shift_reg          =       0;
    reg [`DATA_LENGTH-1:0]      miso_shift_reg          =       0;

///////////////////////////////////////////////////////////////////////////
// Receive data 

always@(posedge SCLK)
    if(SS)
        mosi_shift_reg <= 0;
    else if(!SS && (rx_cnt < `DATA_LENGTH))
    begin
        mosi_shift_reg <= {mosi_shift_reg[`DATA_LENGTH-2:0],MOSI}; //MSB -> LSB
    end
    else
        mosi_shift_reg <= 0;

always@(posedge SCLK or posedge SS)
    if(SS) begin
        rx_cnt <= 0;
        is_receiveing <= 0;
    end
    else if(rx_cnt == `DATA_LENGTH - 1) begin
        rx_cnt <= 0;
    end
    else begin
        is_receiveing <= 1;
        rx_cnt <= rx_cnt + 1;
    end

always @(posedge SS)
    i_data <= mosi_shift_reg;

///////////////////////////////////////////////////////////////////////////
// Transmit data 

always@(negedge SCLK or posedge SS)
    if(SS) 
    begin
        is_transmitting <= 0;
        tx_cnt <= 0;
    end
    else if(tx_cnt >= `DATA_LENGTH - 1)
    begin
        is_transmitting <= 0;
        tx_cnt <= 0;
    end
    else begin
        is_transmitting <= 1;
        tx_cnt <= tx_cnt + 1;
    end

assign MISO = SS ? 1'bz : o_data[`DATA_LENGTH-tx_cnt-1] ;    //MSB -> LSB


endmodule

