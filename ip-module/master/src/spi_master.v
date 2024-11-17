  
`timescale 1ns/1ps

`define IF_DATA_WIDTH 8
   
module spi_master  
	(
      clk,
      rst_n,
	  key2,
      SCLK_MASTER,
      SS_N_MASTER,
      MOSI_MASTER,
      MISO_MASTER,  
      success,

      leds
    );
        
    input  clk;
    input  rst_n;
	input  key2;
	output SCLK_MASTER;
	output SS_N_MASTER;
	output MOSI_MASTER;
	input  MISO_MASTER;
    output success;

    output [7:0] leds;
            
////////////////////////////////////////////////////////////////   

 wire                      I_RESETN;
 wire                      I_TX_EN;
 wire [2:0]                I_WADDR;
 wire [`IF_DATA_WIDTH-1:0] I_WDATA;
 wire                      I_RX_EN;
 wire [2:0]                I_RADDR;
 wire [`IF_DATA_WIDTH-1:0] O_RDATA;
 
 wire                      MOSI_SLAVE;
 wire                      MISO_SLAVE;
 wire                      SS_N_SLAVE;
 wire                      SCLK_SLAVE;
 
 wire                      rstn1;
 wire                      rstn2;
 reg  [7:0]                delay_rst=0;
 reg  [7:0]                delay_key2=0; 
 reg  [14:0]               counter0=0;
 reg                       clk_en=0; 
 wire                      clk;

 wire                      start; 

reg [7:0] data=8'b11100011;

//////////////////////////////////////////////////////////////////////////

 assign rstn1=&{delay_rst[5],!delay_rst[4],!delay_rst[3],!delay_rst[2],!delay_rst[1],!delay_rst[0]};
 
 assign rstn2=~rstn1;
 
 assign start=&{delay_key2[5],!delay_key2[4],!delay_key2[3],!delay_key2[2],!delay_key2[1],!delay_key2[0]}; 
 

 always @(posedge clk) 
    if(counter0==15'd26999) 
	begin
	   counter0 <= 15'd0;
	   clk_en <= 1'b1;
	end
	else begin
	   counter0 <= counter0 + 15'd1;
	   clk_en <= 1'b0;	 
	end
    
 always @(posedge clk)
    if(clk_en==1'b1) 
	begin
       delay_rst[7:1] <= delay_rst[6:0];
       delay_rst[0] <= rst_n;
    end
	
 always @(posedge clk)
    if(clk_en==1'b1) 
	begin
       delay_key2[7:1] <= delay_key2[6:0];
       delay_key2[0] <= key2;
    end

 spi_control u_spi_control (
    .I_CLK              ( clk  ),
    .I_RESETN           ( rstn2       ),
    .start              ( start       ),
    .I_TX_EN            ( I_TX_EN     ),
    .I_WADDR            ( I_WADDR     ),
    .I_WDATA            ( I_WDATA     ),
    .I_RX_EN            ( I_RX_EN     ),
    .I_RADDR            ( I_RADDR     ),
    .O_RDATA            ( O_RDATA     ),
    .successfully       ( success     ),
	.wr_index           ( wr_index    ),

    .data_from_slave ( leds ),
    .data_to_slave( data )
 );

 SPI_MASTER_Top u_spi_master (
    .I_CLK              ( clk  ),
    .I_RESETN           ( rstn2       ),
    .I_TX_EN            ( I_TX_EN     ),
    .I_WADDR            ( I_WADDR     ),
    .I_WDATA            ( I_WDATA     ),
    .I_RX_EN            ( I_RX_EN     ),
    .I_RADDR            ( I_RADDR     ),
    .O_RDATA            ( O_RDATA     ),
    .O_SPI_INT          (             ),
    .MISO_MASTER        ( MISO_MASTER ),
    .MOSI_MASTER        ( MOSI_MASTER ),
    .SS_N_MASTER        ( SS_N_MASTER ),
    .SCLK_MASTER        ( SCLK_MASTER ),
    .MISO_SLAVE         ( MISO_SLAVE  ),
    .MOSI_SLAVE         ( MOSI_SLAVE  ),
    .SS_N_SLAVE         ( SS_N_SLAVE  ),
    .SCLK_SLAVE         ( SCLK_SLAVE  )
 );
          
endmodule
