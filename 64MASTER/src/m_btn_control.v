module m_btn_control
(
    clk,
    btn_send,
    btn_reset,
    start,
    reset
);

    input clk;
    input btn_send;
    input btn_reset;
    output reg start;
    output reset;

////////////////////////////////////////////////////////////////   
// Internal Wires/Registers

    reg  [7:0]                delay_btn_reset=0;
    reg  [7:0]                delay_btn_send=0; 
    reg  [14:0]               counter0=0;
    reg                       clk_en=0;
    
    wire                      pre_start;
    reg                       started;

//////////////////////////////////////////////////////////////////////////
// Button debounce processing

 assign reset=&{delay_btn_reset[5],!delay_btn_reset[4],!delay_btn_reset[3],!delay_btn_reset[2],!delay_btn_reset[1],!delay_btn_reset[0]};
 
 assign pre_start=&{delay_btn_send[5],!delay_btn_send[4],!delay_btn_send[3],!delay_btn_send[2],!delay_btn_send[1],!delay_btn_send[0]}; 

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
// Launching

always @(posedge clk)
    if(reset) 
    begin
        start <= 0;
        started <= 0;
    end
    // Single start tact after pressing the start button
    else if (pre_start && !started)
    begin
        start <= 1;
        started <= 1;
    end
    else if (!pre_start)
    begin
        started <= 0;
    end
    else if (started)
        start <= 0;

endmodule
