module s_btn_control
(
    clk,
    btn_reset,
    reset
);

    input clk;
    input btn_reset;
    output reset;

////////////////////////////////////////////////////////////////   
// Internal Wires/Registers
    
    reg  [7:0]                delay_btn_reset=0;
    reg  [14:0]               counter0=0;
    reg                       clk_en=0; 

//////////////////////////////////////////////////////////////////////////
// Button debounce processing

 assign reset=&{delay_btn_reset[5],!delay_btn_reset[4],!delay_btn_reset[3],!delay_btn_reset[2],!delay_btn_reset[1],!delay_btn_reset[0]};

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

endmodule