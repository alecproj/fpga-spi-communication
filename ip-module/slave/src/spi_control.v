`timescale 1ns / 1ps

`define     SHIFT_DIRECTION     0   // 0: MSB->LSB , 1: LSB -> MSB
`define     CLOCK_PHASE         0   
`define     CLOCK_POLARITY      0
`define     DATA_LENGTH         8

module spi_control (
    SCLK,
    MOSI,
    MISO,
    SS,

    data_from_master,
    data_to_master
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

    reg [5:0]                   rx_cnt                  =       0;
    reg [5:0]                   tx_cnt                  =       0;
    reg [`DATA_LENGTH-1:0]      mosi_shift_reg          =       0;
    reg [`DATA_LENGTH-1:0]      miso_shift_reg          =       0;

/*********************************************************************
*receive data 
*********************************************************************/
if(!(`CLOCK_POLARITY ^ `CLOCK_PHASE))begin
    always@(posedge SCLK )
        if(SS)
            mosi_shift_reg <= 0;
        else if(!SS && (rx_cnt < `DATA_LENGTH))begin
            if(`SHIFT_DIRECTION)    //LSB -> MSB
                mosi_shift_reg <= {MOSI,mosi_shift_reg[`DATA_LENGTH-1:1]};
            else                    //MSB -> LSB
                mosi_shift_reg <= {mosi_shift_reg[`DATA_LENGTH-2:0],MOSI};
        end
        else
            mosi_shift_reg <= 0;

    always@(posedge SCLK )
        if(SS)
            rx_cnt <= 0;
        else if(rx_cnt == `DATA_LENGTH - 1) begin
            data_from_master <= mosi_shift_reg;
            rx_cnt <= 0;
        end
        else 
            rx_cnt <= rx_cnt + 1;
end
else begin
    always@(negedge SCLK /*or negedge SS*/)
        if(SS)
            mosi_shift_reg <= 0;
        else if(!SS && (rx_cnt < `DATA_LENGTH))begin
            if(`SHIFT_DIRECTION)        //LSB -> MSB
                mosi_shift_reg  <=  {MOSI,mosi_shift_reg[`DATA_LENGTH-1:1]};
            else                        //MSB -> LSB
                mosi_shift_reg  <=  {mosi_shift_reg[`DATA_LENGTH-2:0],MOSI};
        end
        else
            mosi_shift_reg <= 0;
     always@(negedge SCLK /*or negedge SS*/)
        if(SS)
            rx_cnt <= 0;
        else if(rx_cnt == `DATA_LENGTH - 1)
            rx_cnt <= 0;
        else if(!SS)
            rx_cnt <= rx_cnt + 1;
end

/*******************************************************************
*transmit data 
*******************************************************************/
if(`CLOCK_POLARITY ^ `CLOCK_PHASE)begin
    always@(posedge SCLK )
        if(SS)
            tx_cnt <= 0;
        else if(tx_cnt >= `DATA_LENGTH - 1)begin
            miso_shift_reg <= mosi_shift_reg;
            tx_cnt <= 0;
        end
        else
            tx_cnt <= tx_cnt + 1;

    assign MISO = SS      ? 1'bz :
                  `SHIFT_DIRECTION ? miso_shift_reg[tx_cnt] :                   //LSB ->MSB
                                     miso_shift_reg[`DATA_LENGTH-tx_cnt-1] ;    //MSB -> LSB
    
end
else begin
    always@(negedge SCLK )
        if(SS)
            tx_cnt <= 0;
        else if(tx_cnt >= `DATA_LENGTH - 1)begin
            //miso_shift_reg <= mosi_shift_reg;
            miso_shift_reg <= data_to_master;
            tx_cnt <= 0;
        end
        else 
            tx_cnt <= tx_cnt + 1;

    assign MISO = SS      ? 1'bz :
                  `SHIFT_DIRECTION ? miso_shift_reg[tx_cnt] :                   //LSB ->MSB
                                     miso_shift_reg[`DATA_LENGTH-tx_cnt-1] ;    //MSB -> LSB
 
end


endmodule

