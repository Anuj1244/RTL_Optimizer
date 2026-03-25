module clk_divider (
    input wire clk_in,
    input wire rst_n,
    output reg clk_out
);

    // ---------------------------------------------------------------------------
    // POWER OPTIMIZATION: AI-Injected Sequential Enable Logic
    // Target Register: count
    // ---------------------------------------------------------------------------
    wire seq_enable_1;
    wire wire_count_1_w5;
    wire wire_count_1_w1;
    reg reg_count_1_w2;
    assign wire_count_1_w1 = count == 24'b100110001001011010000000;
    assign wire_count_1_w5 = (!rst_n);
    always @(posedge clk_in or posedge wire_count_1_w5)
        begin
        if (wire_count_1_w5)
            reg_count_1_w2 <= 1'b0;
        else
            reg_count_1_w2 <= wire_count_1_w1;
    end
    assign seq_enable_1 = (!(wire_count_1_w1 & reg_count_1_w2));
    // ---------------------------------------------------------------------------
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
                if (seq_enable_1) count <= count + 1; 
            end
        end
    end
endmodule