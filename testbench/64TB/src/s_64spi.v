`timescale 1ns/1ps

`define DATA_LENGTH 32

module s_64spi
(
    clk,
    SCLK,
    MOSI,
    SS,
    MISO,
    in,
    out,
    reset,
    status,

    i_data
);

    input clk;
    input SCLK;
    input MOSI;
    input SS;
    output MISO;
    output reg [63:0] in;
    input  [63:0] out;
    input  reset;
    output reg status;

    output [`DATA_LENGTH-1:0] i_data;

////////////////////////////////////////////////////////////////   
// Internal Wires/Registers
    
    wire                      reset;

    // For data
    reg   [`DATA_LENGTH-1:0]   i_splited [1:0];
    wire  [`DATA_LENGTH-1:0]   o_splited [1:0];
    reg   [`DATA_LENGTH-1:0]   o_data=0;
    //wire [`DATA_LENGTH-1:0]   i_data;
    reg                        index=0;

    wire                       is_transmitting;
    wire                       is_receiveing;

    reg   [1:0]                 stage=0;

//////////////////////////////////////////////////////////////////////////

assign o_splited[0] = out[31:0];
assign o_splited[1] = out[63:32];

always @(posedge reset or posedge clk)
begin
	if(reset)
	begin
        o_data <= 0;
        index <= 0;
        stage <= 0;
        status <= 0;
        in <= 0;
	end
	else
	begin
		if(stage==0)begin    // preparation
            if(!is_transmitting && !is_receiveing)
                o_data <= o_splited[index]; 
            else
            begin
                status <= 1;
                stage <= 1;
            end
                        
		end //if(stage==0)

        else if(stage==1)begin   // receiving
            if(!is_transmitting && !is_receiveing)
            begin
                i_splited[index] <= i_data;
                stage <= 2;
            end
                  
		end //if(stage==1)

        else if(stage==2)begin   // distribution
		      if (index==1) // 64 bits received
                begin
                    index <= 0;
                    in[31:0] <= i_splited[0]; 
                    in[63:32] <= i_splited[1];
                    stage <= 0;
                    status <= 0;
                end
              else // 32 bits received
                begin
                    index = index + 1;
                    stage <= 0;
                end
		end //if(stage==2)
    end
end

///////////////////////////////////////////////////////////////////////////

s_spi_control u_spi_control(
 .SCLK                  ( SCLK              ),
 .MOSI                  ( MOSI              ),
 .MISO                  ( MISO              ),
 .SS                    ( SS                ),
 .i_data                ( i_data            ),
 .o_data                ( o_data            ),
 .is_receiveing         ( is_receiveing     ),
 .is_transmitting       ( is_transmitting   )
); 

endmodule