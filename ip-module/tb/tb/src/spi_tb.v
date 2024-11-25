
`timescale 1ns/1ps

module tb;

reg clk;
reg rst;
reg key2;

wire SCLK_MASTER;
wire SS_N_MASTER;
wire MOSI_MASTER;
wire MISO_MASTER;
wire success;
wire [7:0] m_leds;
wire m_debug;
wire m_test;

wire [7:0] s_leds;
wire [3:0] cols;
wire [2:0] rows;
wire s_debug;
wire s_test;

GSR GSR(.GSRI(1'b1));

spi_master u_spi_master 
	(
      .clk(clk),
      .rst_n(rst),
      .key2(key2),
      .SCLK_MASTER(SCLK_MASTER),
      .SS_N_MASTER(SS_N_MASTER),
      .MOSI_MASTER(MOSI_MASTER),
      .MISO_MASTER(MISO_MASTER),  
      .success(success),

      .leds(m_leds),
      .debug(m_debug),
      .test(m_test)
    );

spi_slave u_spi_slave(
 .clk(clk),
 .SCLK(SCLK_MASTER),
 .MOSI(MOSI_MASTER),
 .MISO(MISO_MASTER),
 .SS(SS_N_MASTER),

 .leds(s_leds),
 .cols(cols),
 .rows(rows),

 .debug(s_debug),
 .test(s_test)
);

    initial begin
        clk=0;
        forever #10 clk=~clk;
    end

    initial begin
        rst=1;
        key2=1;		
        #2000000;
        rst=0;
        #6000000;
        rst=1;
        #2000000;
        key2=0;
        #6000000;
        key2=1;
        #2000000;
        key2=0;
        #6000000;
        key2=1;
        #2000000;
        key2=0;
        #6000000;
        key2=1;
        #2000000;
        key2=0;
        #6000000;
        key2=1;
        #2000000;
        key2=0;
        #6000000;
        key2=1;
        #2000000;
		key2=0;
        #6000000;
        key2=1;
        #2000000;

        $finish;		
    end

endmodule
