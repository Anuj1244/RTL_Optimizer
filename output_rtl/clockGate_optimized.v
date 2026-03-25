module top(clk,ctrl,inp1,inp2,out);

	// ---------------------------------------------------------------------------
	// POWER OPTIMIZATION: AI-Injected Sequential Enable Logic
	// Target Register: r2
	// ---------------------------------------------------------------------------
	wire seq_enable_1;
	assign seq_enable_1 = (!ctrl);
	// ---------------------------------------------------------------------------
	input clk,ctrl;
	input [7:0] inp1,inp2;
	output [7:0] out;
	reg r1;
	reg [7:0] r2;
	always@(posedge clk)begin
		r1 <= ctrl;
		if (seq_enable_1) r2 <= inp1; 
	end
	assign out = r1 ? inp2 : r2;
endmodule
