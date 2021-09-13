//----------------------------------------------------------------------------
//Module:      async_fifo
//Author: 
//Description: 
//----------------------------------------------------------------------------
//Version      Modified              Data
//1.0          Draft                 2019.01.29

//----------------------------------------------------------------------------



module async_fifo
#(
parameter WIDTH = 16,
parameter DEPTH = 3
)
(
input	wire			rst,
input	wire			wr_clk,
input	wire			wr_en,
input	wire[WIDTH-1:0]	din,
input	wire			rd_clk,
input	wire			rd_en,
output	reg				valid,
output	reg	[WIDTH-1:0]	dout,
output	reg				empty,
output	reg				full
);


(* RAM_STYLE="BLOCK" *)
reg	[WIDTH-1:0]	mem[0:2**DEPTH-1];
reg	[DEPTH-1:0]	raddr;
reg	[DEPTH-1:0]	waddr;
wire[DEPTH-1:0]	raddr_next;
wire[DEPTH-1:0]	raddr_next_gray;
wire[DEPTH-1:0]	waddr_gray;
reg	[DEPTH-1:0]	waddr_gray_d1;
reg	[DEPTH-1:0]	waddr_gray_d2;
wire[DEPTH-1:0]	waddr_next;
wire[DEPTH-1:0]	waddr_next_gray;
wire[DEPTH-1:0]	raddr_gray;
reg	[DEPTH-1:0]	raddr_gray_d1;
reg	[DEPTH-1:0]	raddr_gray_d2;


//Dual-ports RAM write/read
always @ (posedge rd_clk or posedge rst)
begin
	if (rst)
		raddr <= 'd0;
	else if (rd_en && !empty)
		raddr <= raddr + 1'd1;
	else;
end

always @ (posedge rd_clk or posedge rst)
begin
	if (rst)
		valid <= 1'b0;
	else
		valid <= (rd_en && !empty);
end

always @ (posedge rd_clk or posedge rst)
begin
	if (rst)
		dout <= 'b0;
	else if (rd_en && !empty)
		dout <= mem[raddr];
	else;
end

always @ (posedge wr_clk or posedge rst)
begin
	if (rst)
		waddr <= 'd0;
	else if (wr_en && !full)
		waddr <= waddr + 1'd1;
	else;
end

always @ (posedge wr_clk)
begin
	if (wr_en && !full)
		mem[waddr] <= din;
	else;
end


//Empty falg: Next value of read address = write address
always @ (posedge rd_clk or posedge rst)
begin
	if (rst)
		empty <= 1'b1;
	else if (full)
		empty <= 1'b0;
	else
		empty <= (raddr_next_gray==waddr_gray_d2);
end

assign raddr_next = raddr + (rd_en && !empty);

assign raddr_next_gray = (raddr_next>>1)^raddr_next;

assign waddr_gray = (waddr>>1)^waddr;

always @ (posedge rd_clk or posedge rst)
begin
	if (rst)
		begin
			waddr_gray_d1 <= 'd0;
			waddr_gray_d2 <= 'd0;
		end
	else
		begin
			waddr_gray_d1 <= waddr_gray;
			waddr_gray_d2 <= waddr_gray_d1;
		end
end

//Full flag: Next value of write address = read address
always @ (posedge wr_clk or posedge rst)
begin
	if (rst)
		full <= 1'b0;
	else if (empty)
		full <= 1'b0;
	else	
		full <= (waddr_next_gray==raddr_gray_d2);
end

assign waddr_next = waddr + (wr_en && !full);

assign waddr_next_gray = (waddr_next>>1)^waddr_next;

assign raddr_gray = (raddr>>1)^raddr;

always @ (posedge wr_clk or posedge rst)
begin
	if (rst)
		begin
			raddr_gray_d1 <= 'd0;
			raddr_gray_d2 <= 'd0;
		end
	else
		begin
			raddr_gray_d1 <= raddr_gray;
			raddr_gray_d2 <= raddr_gray_d1;
		end
end


endmodule

