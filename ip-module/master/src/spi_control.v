  
`timescale 1ns/1ps

`define IF_DATA_WIDTH 8
   
module spi_control
(
	 I_CLK,
     I_RESETN,
	 start,
     I_TX_EN,
     I_WADDR,
     I_WDATA,
     I_RX_EN,
     I_RADDR,
     O_RDATA,
	 err_flag,
	 r_flag,
	 wr_index
);

  input                       I_CLK;
  input                       I_RESETN;
  input                       start;  
  output                      I_TX_EN;
  output [2:0]                I_WADDR;
  output [`IF_DATA_WIDTH-1:0] I_WDATA;   
  output                      I_RX_EN;  
  output [2:0]                I_RADDR;
  input  [`IF_DATA_WIDTH-1:0] O_RDATA;
  output                      err_flag;
  output                      r_flag; 
  output reg [3:0]            wr_index;  

//////////////////////////////////////////////////////////////////////////
//	Internal Wires/Registers
 reg                      r_flag_reg = 0;
 reg                      err_flag_reg = 0;  
 reg                      I_TX_EN;
 reg [2:0]                I_WADDR;
 reg [`IF_DATA_WIDTH-1:0] I_WDATA;
 reg                      I_RX_EN; 
 reg [2:0]                I_RADDR;

 wire [2:0]               REG_RXDATA  = 3'd0;
 wire [2:0]               REG_TXDATA  = 3'd1;
 wire [2:0]               REG_STATUS  = 3'd2;
 wire [2:0]               REG_CONTROL = 3'd3;
 wire [2:0]               REG_SSMASK  = 3'd4;

 reg [0:0]				  wr_cntl;
 reg [0:0]				  wr_reg;
// reg [3:0]				  wr_index;
 reg [1:0]				  rd_reg;
 reg [`IF_DATA_WIDTH-1:0] rd_status;
 reg [`IF_DATA_WIDTH-1:0] rd_data;
 
 reg                      start_dl;
 
 reg                      receive_flag;
///////////////////////////////////////////////////////////////////////////

always @(negedge I_RESETN or posedge I_CLK)
    if(~I_RESETN)
       start_dl <= 1'b0;	 
    else
       start_dl <= start; 

always @(negedge I_RESETN or posedge I_CLK)
begin
	if(~I_RESETN)
	begin
	    I_TX_EN <= 1'b0;
		I_WADDR <= 2'b00;
		I_WDATA <= {`IF_DATA_WIDTH{1'b0}};
	    I_RX_EN <= 1'b0;		
		I_RADDR <= 2'b00;
		
		wr_index <= 0;
		wr_cntl <= 0;
		wr_reg <=0;
		rd_reg <=0;
		rd_status <=0;
        err_flag_reg <= 0;
        r_flag_reg <= 0;
		receive_flag <= 1'b0;
	end
	else
	begin
		if(wr_index==0)begin    //write ssmask
		    case(wr_cntl)
		                0:
						   if((start_dl == 1'b0) && (start == 1'b1)) 
						    begin
		                        I_TX_EN <= 1'b1;
		                        I_WADDR <= REG_SSMASK; //0x04
		                        I_WDATA <= 8'h01;	 //Slave Select
		
		                        wr_cntl <=1;
		                    end
						   else
						    begin
		                        I_TX_EN <= 1'b0;
			                    wr_index <= 0;	
                                wr_cntl <= 0;
                            end								
		                1:
		                    begin 
		                        I_TX_EN <= 1'b0;
			                    wr_index <= 1;	
                                wr_cntl <= 0;								
		                    end
						default:
						    begin
		                        I_TX_EN <= 1'b0;
			                    wr_index <= 0;	
                                wr_cntl <= 0;
                            end						
		    endcase 
		end //if(wr_index==0)
		
        else if(wr_index==1)begin   //write control reg
		        case(wr_reg)
		                0:
		                    begin
		                        I_TX_EN <= 1'b1;
		                        I_WADDR <= REG_CONTROL; //0x03
		                        //I_WDATA <= {24'h0000_00,8'h92};	
		                        I_WDATA <= 8'h8B; //10001011
		
		                        wr_reg <=1;
		                    end
		                1:
		                    begin 
		                        I_TX_EN <= 1'b0;
								
			                    wr_index <= 2;
			                    wr_reg <= 0;
		                    end
						default:
						    begin
		                        I_TX_EN <= 1'b0;
								I_WADDR <= 0;
								I_WDATA <= 0;
			                    wr_index <= 0;	
                                wr_reg <= 0;
                            end								
		        endcase 
		end//if(wr_index==1)
		
        else if(wr_index==2)begin       //read status reg
			    case(rd_reg)
			            0:
			                begin
		                        I_RX_EN <= 1'b1;
				                I_RADDR <= REG_STATUS; //0x02
				
				                rd_reg <= 1;
			                end
			            1:
			                begin
		                        I_RX_EN <= 1'b0;
								
					            rd_reg <= 2;
			                end
			            2:
			                begin
				                rd_status <= O_RDATA;
					
					            rd_reg <= 3;					
			                end	
			            3:
			                begin
					            if(rd_status[5]&&rd_status[4])begin //if tx ready
						            wr_index <= 3;
						            rd_reg <= 0;
					            end
					            else
						            rd_reg <= 0;
				            end
						default:
						    begin
		                        I_RX_EN <= 1'b0;
								I_RADDR <= 0;
								rd_status <= 0;
			                    wr_index <= 0;	
                                rd_reg <= 0;
                            end								
			        endcase
			end	//if(wr_index==2)
			
		else if(wr_index==3)begin   //write data
		        case(wr_reg)
		                0:
		                    begin
		                        I_TX_EN <= 1'b1;
		                        I_WADDR <= REG_TXDATA; //0x01
		                        //I_WDATA <= {24'h0000_00,8'h92};
		                        I_WDATA <= 8'h55; //wr data
		
		                        wr_reg <=1;
		                    end
		                1:
		                    begin 
		                        I_TX_EN <= 1'b0;
								
			                    wr_index <= 4;
			                    wr_reg <= 0;								
		                    end
						default:
						    begin
		                        I_TX_EN <= 1'b0;
								I_WADDR <= 0;
								I_WDATA <= 0;
			                    wr_index <= 0;	
                                wr_reg <= 0;
                            end							
		        endcase 
		end//if(wr_index==3)

		else if(wr_index==4)begin       //read status reg
			    case(rd_reg)
			            0:
			                begin
		                        I_RX_EN <= 1'b1;
				                I_RADDR <= REG_STATUS; //0x02
				
				                rd_reg <= 1;
			                end
			            1:
			                begin
		                        I_RX_EN <= 1'b0;
								
					            rd_reg <= 2;
			                end
			            2:
			                begin
				                rd_status <= O_RDATA;
					
					            rd_reg <= 3;					
			                end	
						3:
                            begin						
							   if(rd_status[6] == 1'b1) begin
					              rd_reg <= 0;
                                  wr_index <= 5; 
                               end
                               else begin
					              rd_reg <= 0;
                                  wr_index <= 4;
							   end
			                end
						default:
						    begin
		                        I_RX_EN <= 1'b0;
								I_RADDR <= 0;
								rd_status <= 0;
			                    wr_index <= 0;	
                                rd_reg <= 0;
                            end							
			    endcase
		end	//if(wr_index==4)
		
		else if(wr_index==5)begin       //read data
			    case(rd_reg)
			            0:
			                begin
		                        I_RX_EN <= 1'b1;
				                I_RADDR <= REG_RXDATA; //0x00
				
				                rd_reg <= 1;
			                end
			            1:
			                begin
		                        I_RX_EN <= 1'b0;
								
					            rd_reg <= 2;
			                end
			            2:
			                begin
				                rd_data <= O_RDATA;
								
					            rd_reg <= 3;
			                end
			            3:
			                begin
                                r_flag_reg <= 1;
								
							   if(receive_flag == 1'b1)	begin //ignore the first time receiving data
								if(rd_data != 8'h55) begin
                                   err_flag_reg <= 1'b1;
								   receive_flag <= 1'b1;								   
					               rd_reg <= 0;
                                   wr_index <= 6;                                		   
								end
								else begin
                                   err_flag_reg <= 1'b0;
								   receive_flag <= 1'b1;								   
					               rd_reg <= 0;   
                                   wr_index <= 6;
                                end								   
							   end
                               else begin
                                    err_flag_reg <= 1'b0;	
									receive_flag <= 1'b1;
					                rd_reg <= 0;
                                    wr_index <= 6;									
							   end                 
			                end	
						default:
						    begin
		                        I_RX_EN <= 1'b0;
								I_RADDR <= 0;
								rd_data <= 0;
			                    wr_index <= 0;	
                                rd_reg <= 0;
                                err_flag_reg <= 1'b0;	
								receive_flag <= 1'b0;								
                            end							
			    endcase
		end	//if(wr_index==5)
			
        else if(wr_index==6)begin   //write control reg
		        case(wr_reg)
		                0:
		                    begin
		                        I_TX_EN <= 1'b1;
		                        I_WADDR <= REG_CONTROL;
		                        //I_WDATA <= {24'h0000_00,8'h92};
		                        I_WDATA <= 8'h00;
		
		                        wr_reg <=1;
		                    end
		                1:
		                    begin						
		                        I_TX_EN <= 1'b0;	
			                    wr_index <= 0;
			                    wr_reg <= 0;
		                    end
						default:
						    begin
		                        I_TX_EN <= 1'b0;
			                    wr_index <= 0;	
                                wr_reg <= 0;
                            end							
		        endcase 
		end//if(wr_index==6)
    	
	end 
end 
	
 assign err_flag = err_flag_reg;
 assign r_flag  = r_flag_reg;

endmodule
