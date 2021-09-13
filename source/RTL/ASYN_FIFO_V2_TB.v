//----------------------------------------------------------------------------
//Module:      async_fifo
//Author: 
//Description: 
//----------------------------------------------------------------------------
//Version      Modified              Data
//2.0         Draft                 2019.01.29

//----------------------------------------------------------------------------
`timescale 1ns / 1ps
`define WR_CLK 16
`define RD_CLK 7



module async_fifo_tb;

reg			rst;
reg			wr_clk;
reg			wr_en;
reg	[15:0]	din;
reg			rd_clk;
reg			rd_en;
wire		valid;
wire[15:0]	dout;
wire		empty;
wire		full;

reg	[15:0]	test_cnt;
reg			err;





async_fifo
#(
.WIDTH	(16),
.DEPTH	(5)
)
async_fifo_u
(
.rst	(rst),
.wr_clk	(wr_clk),
.wr_en	(wr_en),
.din	(din),
.rd_clk	(rd_clk),
.rd_en	(rd_en),
.valid	(valid),
.dout	(dout),
.empty	(empty),
.full	(full)
);


//clk and rst
initial
begin
	wr_clk = 1'b0;
	forever
	begin
		wr_clk = 1'b0;
		#(`WR_CLK/2);
		wr_clk = 1'b1;
		#(`WR_CLK/2);
	end
end

initial
begin
	rd_clk = 1'b0;
	forever
	begin
		rd_clk = 1'b0;
		#(`RD_CLK/2);
		rd_clk = 1'b1;
		#(`RD_CLK/2);
	end
end

initial
begin
	rst = 1'b1;
	#500;
	rst = 1'b0;
end


//write
initial
begin
	wr_en = 1'b0;
	
	while (rst!==1'b0) #0.01;
	#100;
	
	repeat(32) @ (posedge wr_clk) wr_en <= 1'b1;
	@ (posedge wr_clk) wr_en <= 1'b0;
	
	#1000
	forever @ (posedge wr_clk) wr_en <= ~full;
	
end

always @ (posedge wr_clk or posedge rst)
begin
	if (rst)
		din <= 'd0;
	else if (wr_en && !full)
		din <= din + 1'd1;
	else;
end




//read and check
initial
begin
	rd_en = 1'b0;
	
	while (rst!==1'b0) #0.01;
	#100;
	
	#500
	repeat(32) @ (posedge rd_clk) rd_en <= 1'b1;
	@ (posedge rd_clk) rd_en <= 1'b0;
	
	#500
	forever @ (posedge rd_clk) rd_en <= ~empty;
end

always @ (posedge rd_clk or posedge rst)
begin
	if (rst)
		err <= 1'b0;
	else if (valid)
		if (test_cnt!=dout)
			err <= 1'b1;
		else;
	else;
end

always @ (posedge rd_clk or posedge rst)
begin
	if (rst)
		test_cnt <= 16'd0;
	else if (valid)
		test_cnt <= test_cnt + 1'd1;
	else;
end


initial
begin
	#20000
	$stop;
end

endmodule
