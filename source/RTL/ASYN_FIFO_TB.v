/***********************************************************
************************************************************
*  Title: synchronous interface for input/output           *
************************************************************
*  File name: ASYN_FIFO_TB.v                               *
*                                                          *
*  Description: testbench file for ASYN_FIFO               *
*               WCLK - 250 MHz RCLK - 50 MHz               *
************************************************************
*Revise history:   5/2/19      BY S.T.                     *
************************************************************
***********************************************************/
`timescale 1 ns / 1 ns
module  ASYN_FIFO_TB();
	parameter WIDTH = 16;     // DATA SIZE
	parameter FIFO_DEPTH = 8;  // equals to Busrt - Burst f2/f1 (50 MHz / 250 MHz)
  
	reg WCLK, RCLK, WD, RD, RST_N;  // wd -write fifo singal  rd- read fifo singal
	reg [WIDTH - 1 : 0] DATA_IN;
	wire [WIDTH - 1: 0] DATA_OUT;
	wire WFULL, REMPTY;
	
	ASYN_FIFO DUT(DATA_OUT, DATA_IN, WD, RD, WCLK, RCLK, WFULL, REMPTY, RST_N);
	localparam CYCLE = 4;
	localparam CYCLE1 = 20;
	
	initial 
	$monitorb ("%d DATA_OUT = %b DATA_IN = %b WD = %b RD = %b RCLK = %b WCLK = %b WFULL = %b REMPTY = %b RST_N = %b",$time, DATA_OUT, DATA_IN, WD, RD, RCLK, WCLK, WFULL, REMPTY, RST_N);
	// clock signal
	initial begin                                                  
		WCLK = 0;
		forever #(CYCLE/2) WCLK = ~WCLK;
	end

	initial begin
		RCLK = 0;
		forever #(CYCLE1/2) RCLK = ~RCLK;
	end
	//generating reset
	initial begin
		RST_N = 1;
		#2 RST_N = 0;
		#(CYCLE*3) RST_N = 1;
	end

	initial begin
		RST_N = 1;
		#2 RST_N = 0;
		#(CYCLE1*2) RST_N = 1;
	end
	//
	initial begin
	$vcdpluson;
	#1000 $finish;
	end
														
	always@(posedge WCLK or negedge RST_N) begin                                                  
		if(!RST_N)begin
			WD <= 0;
			RD <= 0;
		end
		else begin
			WD <= $random;
			RD <= $random;
		end                                           
	end

	always@(posedge RCLK or negedge RST_N)begin
		if(!RST_N)begin
			RD <= 0;
		end
		else begin
			RD <= $random;
		end
	end                                                    
	// input data
	always@(*)begin
		if(WD) DATA_IN <= $random;
		else DATA_IN <= 0;
	end
endmodule
