module top(clk,ctrl,inp1,inp2,out);
	input clk,ctrl;
	input [7:0] inp1,inp2;
	output [7:0] out;
	reg r1;
	reg [7:0] r2;
	always@(posedge clk)begin
		r1 <= ctrl;
		r2 <= inp1;
	end
	assign out = r1 ? inp2 : r2;
endmodule
