/***********************************************************
************************************************************
*  **************  Writen by: Shilin Tian                  *
*  Title: synchronous interface for input/output           *
************************************************************
*  File name: ASYN_FIFO.v                                  *
*                                                          *
*  Description: Input frequency 250 MHz. read out in the   *
*                same width at 50 MHz. To avoid overflow,  *
*               one cycle before a new data should be      *
*	        signaled for avoiding loss of data.        *
************************************************************
*Revise history:   5/2/19      BY S.T.                     *
************************************************************
***********************************************************/
`timescale 1 ns / 1 ns
module  ASYN_FIFO(DATA_OUT, DATA_IN, WD, RD, WCLK, RCLK, WFULL, REMPTY, RST_N);
	parameter WIDTH = 16;     // DATA SIZE
	parameter FIFO_DEPTH = 8;  // equals to Busrt - Burst f2/f1 (50 MHz / 250 MHz) 
  
	input WCLK, RCLK, WD, RD, RST_N;  // wd -write fifo singal  rd- read fifo singal
	input [WIDTH - 1 : 0] DATA_IN;
	output [WIDTH - 1: 0] DATA_OUT;
	output WFULL, REMPTY;
	
	reg WFULL, REMPTY;
	reg [WIDTH-1:0] MEM [FIFO_DEPTH-1:0]; //FIFO MEMORY 
	wire [WIDTH-1 : 0] WADDR,RADDR;
	reg [WIDTH : 0] WB,RB;  // wriet/read pointer in binary and 
	wire [WIDTH : 0] WG_next,RG_next,WB_next,RB_next;
	reg [WIDTH : 0] WP,RP;
	reg [WIDTH : 0] wr1_rp,wr2_rp,rd1_wp,rd2_wp;
	wire REMPTY_SYN,WFULL_SYN;

	//READ DATA
	assign DATA_OUT = MEM[RADDR];

	//WRITE DATA
	always@(posedge WCLK) begin 
		if((WD) && !(WFULL))
			MEM[WADDR] <= DATA_IN;
	end

	//1.generating read adderss ADDR; 2. Gray converting and give it to pointer RP
	always@(posedge RCLK or negedge RST_N) begin 
		if(!RST_N)
			{RB,RP} <= 0;
		else
			{RB,RP} <= {RB_next,RG_next};
	end
	assign RADDR = RB[WIDTH-1 : 0];
	assign RB_next = RB + (RD & ~REMPTY);
	assign RG_next = RB_next ^ (RB_next >> 1);

	//1.generating write adderss WADDR; 2.Gray converting and give it to pointer WP
	always@(posedge WCLK or negedge RST_N) begin
		if(!RST_N)
			{WB,WP} <= 0;
		else
			{WB,WP} <= {WB_next,WG_next};
	end
	assign WADDR = WB[WIDTH-1 : 0];
	assign WB_next = WB + (WD & ~WFULL);
	assign WG_next = WB_next ^ (WB_next >> 1);

	//read pointer RP syn to WCLK
	always@(posedge WCLK or negedge RST_N) begin
			if(!RST_N)
			{wr2_rp,wr1_rp} <= 0;
			else
			{wr2_rp,wr1_rp} <= {wr1_rp,RP};
	end
	//write pointer WP syn to RCLK
	always@(posedge RCLK or negedge RST_N) begin 
		if(!RST_N) 
			{rd2_wp,rd1_wp} <= 0;
		else 
			{rd2_wp,rd1_wp} <= {rd1_wp,WP};
	end
	//generating REMPTY signal
	assign REMPTY_SYN = (rd2_wp == RG_next);
	always@(posedge RCLK or negedge RST_N) begin
		if(!RST_N)
			REMPTY <= 1'b1;
		else
			REMPTY <= REMPTY_SYN;
	end
	//generating WFULL signal
	assign WFULL_SYN = ({~wr2_rp[WIDTH : WIDTH-1], wr2_rp[WIDTH-2 : 0]} == WG_next);
	always@(posedge WCLK or negedge RST_N) begin
		if(!RST_N)
			WFULL <= 1'b0;
		else
			WFULL <= WFULL_SYN;
	end
endmodule
