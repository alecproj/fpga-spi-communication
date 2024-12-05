`timescale 1ns/1ps

`define STARTUP_WAIT 32'd10000000

module m_top
(
    clk,
    ioSclk,
    ioSdin,
    ioCs,
    ioDc,
    ioReset,
    SCLK_MASTER,
    SS_N_MASTER,
    MOSI_MASTER,
    MISO_MASTER,
    btn_reset,
	btn_send,

    i_data
);

    input clk;
    output ioSclk;
    output ioSdin;
    output ioCs;
    output ioDc;
    output ioReset;
	output SCLK_MASTER;
	output SS_N_MASTER;
	output MOSI_MASTER;
	input  MISO_MASTER;
    input  btn_reset;
	input  btn_send;

    output [7:0] i_data;

////////////////////////////////////////////////////////////////   
// Internal Wires/Registers
 
    // For SPI
    wire                      I_RESETN;
    wire                      I_TX_EN;
    wire [2:0]                I_WADDR;
    wire [`DATA_WIDTH-1:0]    I_WDATA;
    wire                      I_RX_EN;
    wire [2:0]                I_RADDR;
    wire [`DATA_WIDTH-1:0]    O_RDATA;
    
    wire                      MOSI_SLAVE;
    wire                      MISO_SLAVE;
    wire                      SS_N_SLAVE;
    wire                      SCLK_SLAVE;

    wire                      start;
    wire                      is_sending;
    
    // For buttons
    wire                      reset_on_1;
    wire                      reset_on_0;
    reg  [7:0]                delay_btn_reset=0;
    reg  [7:0]                delay_btn_send=0; 
    reg  [14:0]               counter0=0;
    reg                       clk_en=0; 

    // For data
    reg  [7:0]                i_message [63:0];
    reg  [7:0]                o_message [63:0];
    reg  [7:0]                o_data=0;
    //wire [7:0]                i_data;
    reg  [5:0]                i_index=0;
    reg  [5:0]                o_index=0;
    reg                       i_change_rd=1;
    reg                       o_change_rd=1;
    
    // For display
    reg [7:0]                 fontBuffer [1519:0];

    wire [9:0]                pixelAddress;
    wire [7:0]                pixelData;
    
    wire [5:0]                charAddress;
    wire [2:0]                columnAddress;
    wire                      topRow;
    
    reg  [7:0]                outputBuffer;
    wire [7:0]                charOutput;
    wire [7:0]                chosenChar;
 
////////////////////////////////////////////////////////////////   
// Initial
 
    integer i;
    initial begin
        $readmemh("font.hex", fontBuffer);

        for (i=0; i<64; i=i+1) begin
            i_message[i] = 0;
        end

        o_message[0] = "M";
        o_message[1] = "A";
        o_message[2] = "S";
        o_message[3] = "T";
        o_message[4] = "E";
        o_message[5] = "R";
        for (i=6; i<64; i=i+1) begin
            o_message[i] = 0;
        end
    end

//////////////////////////////////////////////////////////////////////////
// Button debounce processing

 assign reset_on_1=&{delay_btn_reset[5],!delay_btn_reset[4],!delay_btn_reset[3],!delay_btn_reset[2],!delay_btn_reset[1],!delay_btn_reset[0]};
 
 assign reset_on_0=~reset_on_1;
 
 assign start=&{delay_btn_send[5],!delay_btn_send[4],!delay_btn_send[3],!delay_btn_send[2],!delay_btn_send[1],!delay_btn_send[0]}; 

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
       delay_btn_reset[7:1] <= delay_btn_reset[6:0];
       delay_btn_reset[0] <= btn_reset;
    end
	
 always @(posedge clk)
    if(clk_en==1'b1) 
	begin
       delay_btn_send[7:1] <= delay_btn_send[6:0];
       delay_btn_send[0] <= btn_send;
    end

//////////////////////////////////////////////////////////////////////////
// Output data preparation

always @(posedge clk)
    if(reset_on_1) 
    begin
        o_data <= o_message[0];
        o_index <= 0;

        o_change_rd <= 1;
    end
    // Data transmited and needs to be updated
    else if (is_sending && o_change_rd)
    begin
        o_data <= o_message[o_index];
        o_index <= o_index + 1;

        o_change_rd <= 0;
    end
    else if (!is_sending)
        o_change_rd <= 1;

////////////////////////////////////////////////////////////////  
// Input data management

always @(posedge clk)
    if(reset_on_1) 
    begin
        for (i=0; i<64; i=i+1) 
          begin
            i_message[i] <= 0;
          end
        i_index <=0; 

        i_change_rd <= 0;
    end
    // Data received and ready for display
    else if (!is_sending && i_change_rd)
    begin
        i_message[i_index] <= i_data;
        i_index <= i_index + 1;
        
        if (!i_index)
        begin
        for (i=1; i<64; i=i+1) 
          begin
            i_message[i] <= 0;
          end
        end

        i_change_rd <= 0;
    end
    else if (is_sending)
        i_change_rd <= 1;

////////////////////////////////////////////////////////////////   
// Preparation for display
 
    always @(posedge clk) begin
        outputBuffer <= fontBuffer[((chosenChar-8'd32) << 4) + (columnAddress << 1) + (topRow ? 0 : 1)];
    end

    assign charAddress = {pixelAddress[9:8],pixelAddress[6:3]};
    assign columnAddress = pixelAddress[2:0];
    assign topRow = !pixelAddress[7];

    assign charOutput = i_message[charAddress];    
    assign chosenChar = (charOutput >= 32 && charOutput <= 126) ? charOutput : 32;

    assign pixelData = outputBuffer;

///////////////////////////////////////////////////////////////////////////

m_screen u_m_screen (
    .clk                ( clk          ), 
    .ioSclk             ( ioSclk       ), 
    .ioSdin             ( ioSdin       ), 
    .ioCs               ( ioCs         ), 
    .ioDc               ( ioDc         ), 
    .ioReset            ( ioReset      ), 
    .pixelAddress       ( pixelAddress ),
    .pixelData          ( pixelData    ),
    .rst_btn            ( btn_reset    )
);

 m_spi_control u_spi_control (
    .I_CLK              ( clk         ),
    .I_RESETN           ( reset_on_0  ),
    .start              ( start       ),
    .I_TX_EN            ( I_TX_EN     ),
    .I_WADDR            ( I_WADDR     ),
    .I_WDATA            ( I_WDATA     ),
    .I_RX_EN            ( I_RX_EN     ),
    .I_RADDR            ( I_RADDR     ),
    .O_RDATA            ( O_RDATA     ),
	.wr_index           ( wr_index    ),

    .i_data             ( i_data      ),
    .o_data             ( o_data      ),
    .is_sending         ( is_sending  )
 );

 SPI_MASTER_Top u_spi_master (
    .I_CLK              ( clk         ),
    .I_RESETN           ( reset_on_0  ),
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