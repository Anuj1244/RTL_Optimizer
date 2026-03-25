module clk_divider (
    input wire clk_in,
    input wire rst_n,
    output reg clk_out
);
    reg [23:0] count;
    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            count <= 24'd0;
            clk_out <= 1'b0;
        end else begin
            // TODO: Insert 'run' enable here
            if (count == 24'd10_000_000) begin
                count <= 24'd0;
                clk_out <= ~clk_out;
            end else begin
                count <= count + 1;
            end
        end
    end
endmodule