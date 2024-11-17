`timescale 1ns / 1ps

`define     DATA_LENGTH         8

module spi_control (
    SCLK,
    MOSI,
    MISO,
    SS,

    data_from_master,
    data_to_master,
    receiveing,
    transmitting
);

/********************************************************************
*port and variables
********************************************************************/
    input                       SCLK;
    input                       MOSI;
    input                       SS;
    output                      MISO;

    output reg [7:0] data_from_master;
    input [7:0] data_to_master;
    output receiveing;
    output transmitting;

    reg [5:0]                   rx_cnt                  =       0;
    reg [5:0]                   tx_cnt                  =       0;
    reg [`DATA_LENGTH-1:0]      mosi_shift_reg          =       0;
    reg [`DATA_LENGTH-1:0]      miso_shift_reg          =       0;

    reg transmitting_f=0;
    reg receiveing_f=0;

/*********************************************************************
*receive data 
*********************************************************************/

always@(posedge SCLK )
    if(SS)
        mosi_shift_reg <= 0;
    else if(!SS && (rx_cnt < `DATA_LENGTH))
    begin
        mosi_shift_reg <= {mosi_shift_reg[`DATA_LENGTH-2:0],MOSI}; //MSB -> LSB
    end
    else
        mosi_shift_reg <= 0;

always@(posedge SCLK )
    if(SS) begin
        rx_cnt <= 0;
    end
    else if(rx_cnt == `DATA_LENGTH - 1) begin
        receiveing_f <= 0;
        data_from_master <= mosi_shift_reg;
        rx_cnt <= 0;
    end
    else begin
        receiveing_f <= 1;
        rx_cnt <= rx_cnt + 1;
    end

assign receiveing = receiveing_f;

/*******************************************************************
*transmit data 
*******************************************************************/

always@(negedge SCLK )
    if(SS) 
    begin
        tx_cnt <= 0;
    end
    else if(tx_cnt >= `DATA_LENGTH - 1)
    begin
        //miso_shift_reg <= mosi_shift_reg;
        miso_shift_reg <= data_to_master;
        tx_cnt <= 0;
    end
    else begin
        if (tx_cnt == (`DATA_LENGTH - 2))
            transmitting_f <= 0;
        else
            transmitting_f <= 1;
        tx_cnt <= tx_cnt + 1;
    end

assign MISO = SS ? 1'bz : miso_shift_reg[`DATA_LENGTH-tx_cnt-1] ;    //MSB -> LSB
assign transmitting = transmitting_f;


endmodule

