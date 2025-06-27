`timescale 1ns/1ps

`define DATA_WIDTH 32

module m_64spi
(
    clk,
    SCLK_MASTER,
    SS_N_MASTER,
    MOSI_MASTER,
    MISO_MASTER,
    reset,
    start,
    in,
    out,
    status
);

    input  clk;
    output SCLK_MASTER;
    output SS_N_MASTER;
    output MOSI_MASTER;
    input  MISO_MASTER;
    input  reset;
    input  start;

    output reg [63:0] in;
    input  [63:0] out;
    output reg status;

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
    
    reg                       send=0;
    wire                      is_sending;
    wire                      reset_on_0;
    

    // For data
    reg  [`DATA_WIDTH-1:0]    i_splited [1:0];
    reg  [`DATA_WIDTH-1:0]    o_splited [1:0];
    reg  [`DATA_WIDTH-1:0]    o_data=0;
    wire [`DATA_WIDTH-1:0]    i_data;
    reg                       index=0;

    reg  [1:0]                stage=0;
    reg  [1:0]                step=0;

////////////////////////////////////////////////////////////////

assign reset_on_0=~reset;

always @(posedge reset or posedge clk)
begin
	if(reset)
	begin
        o_data <= 0;
        index <= 0;
        stage <= 0;
        step <= 0;  
        status <= 0;
        in <= 0;
        send <= 0;
	end
	else
	begin
		if(stage==0)begin    // preparation
            if(start)
                begin
                    status <= 1;
                    o_splited[0] = out[31:0];
                    o_splited[1] = out[63:32];
                    index <= 0;
                    
                    stage <= 1;
                end
		    
		end //if(stage==0)

        else if(stage==1)begin   // sending
		     case(step)
                0:
                  begin 
                    o_data <= o_splited[index];
                    step <= 1;
                  end
                1:
                  begin
                    send <= 1;
                    step <= 2;
                  end
                2:
                  if(is_sending)
                  begin
                    send <= 0;
                    step <= 0;
                    stage <= 2;
                  end
            endcase
		end //if(stage==1)
		
        else if(stage==2)begin   // updating
		      if (!is_sending)
                begin
                    i_splited[index] <= i_data;
                    stage <= 3;
                end
		end //if(stage==2)

        else if(stage==3)begin   // distribution
		      if (index==1) // 64 bits received
                begin
                    in[31:0] <= i_splited[0]; 
                    in[63:32] <= i_splited[1];
                    stage <= 0;
                    status <= 0;
                end
              else // 32 bits received
                begin
                    index = index + 1;
                    o_data <= o_splited[index+1];
                    stage <= 1;
                end
		end //if(stage==3)
    end
end

///////////////////////////////////////////////////////////////////////////

 m_spi_control u_spi_control (
    .I_CLK              ( clk          ),
    .I_RESETN           ( reset_on_0   ),
    .start              ( send         ),
    .I_TX_EN            ( I_TX_EN      ),
    .I_WADDR            ( I_WADDR      ),
    .I_WDATA            ( I_WDATA      ),
    .I_RX_EN            ( I_RX_EN      ),
    .I_RADDR            ( I_RADDR      ),
    .O_RDATA            ( O_RDATA      ),
    .i_data             ( i_data       ),
    .o_data             ( o_data       ),
    .is_sending         ( is_sending   )
 );

 SPI_MASTER_Top u_spi_master (
    .I_CLK              ( clk          ),
    .I_RESETN           ( reset_on_0   ),
    .I_TX_EN            ( I_TX_EN      ),
    .I_WADDR            ( I_WADDR      ),
    .I_WDATA            ( I_WDATA      ),
    .I_RX_EN            ( I_RX_EN      ),
    .I_RADDR            ( I_RADDR      ),
    .O_RDATA            ( O_RDATA      ),
    .O_SPI_INT          (              ),
    .MISO_MASTER        ( MISO_MASTER  ),
    .MOSI_MASTER        ( MOSI_MASTER  ),
    .SS_N_MASTER        ( SS_N_MASTER  ),
    .SCLK_MASTER        ( SCLK_MASTER  ),
    .MISO_SLAVE         ( MISO_SLAVE   ),
    .MOSI_SLAVE         ( MOSI_SLAVE   ),
    .SS_N_SLAVE         ( SS_N_SLAVE   ),
    .SCLK_SLAVE         ( SCLK_SLAVE   )
 );

endmodule