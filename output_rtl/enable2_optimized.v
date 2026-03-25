module ocp_resp_sync_const (
    intf_clk,
    intf_rst_n,
    cfg_device_id,
    sresp_r,
    sdata_r,
    sresp_req_sync_s,
    sresp_req_sync_r,
    sresp_sync_r,
    sdata_sync_r,
    id_out
);

  // ---------------------------------------------------------------------------
  // POWER OPTIMIZATION: AI-Injected Sequential Enable Logic
  // Target Register: sresp_sync_r
  // ---------------------------------------------------------------------------
  wire seq_enable_1;
  wire wire_sresp_sync_r_1_w3;
  wire wire_sresp_sync_r_1_w1;
  wire wire_sresp_sync_r_1_w4;
  wire wire_sresp_sync_r_1_w6;
  wire wire_sresp_sync_r_1_w10;
  wire wire_sresp_sync_r_1_w8;
  reg reg_sresp_sync_r_1_w5;
  reg reg_sresp_sync_r_1_w2;
  assign wire_sresp_sync_r_1_w1 = sresp_sync_r != 3'b000;
  assign wire_sresp_sync_r_1_w3 = (sresp_req_sync_s & (!sresp_req_sync_r));
  assign wire_sresp_sync_r_1_w4 = ((!(wire_sresp_sync_r_1_w1 & reg_sresp_sync_r_1_w2)) & (wire_sresp_sync_r_1_w3 | wire_sresp_sync_r_1_w1));
  assign wire_sresp_sync_r_1_w6 = ((!reg_sresp_sync_r_1_w5) & (wire_sresp_sync_r_1_w3 | wire_sresp_sync_r_1_w1));
  assign wire_sresp_sync_r_1_w8 = (wire_sresp_sync_r_1_w3 | wire_sresp_sync_r_1_w1);
  assign wire_sresp_sync_r_1_w10 = (!intf_rst_n);
  always @(posedge intf_clk or posedge wire_sresp_sync_r_1_w10)
    begin
    if (wire_sresp_sync_r_1_w10)
      reg_sresp_sync_r_1_w5 <= 1'b0;
    else
      reg_sresp_sync_r_1_w5 <= wire_sresp_sync_r_1_w8;
  end
  always @(posedge intf_clk or posedge wire_sresp_sync_r_1_w10)
    begin
    if (wire_sresp_sync_r_1_w10)
      reg_sresp_sync_r_1_w2 <= 1'b0;
    else
      reg_sresp_sync_r_1_w2 <= wire_sresp_sync_r_1_w1;
  end
  assign seq_enable_1 = (wire_sresp_sync_r_1_w4 | wire_sresp_sync_r_1_w6);
  // ---------------------------------------------------------------------------

  // Parameter declarations inside the module (Classic Style)
  parameter OCP_DATA_WIDTH = 32;
  parameter OCP_SRESP_NULL = 3'b000;

  // Input/Output Port declarations
  input  wire                      intf_clk;
  input  wire                      intf_rst_n;
  input  wire [7:0]                cfg_device_id; // Constant Input
  input  wire [2:0]                sresp_r;
  input  wire [OCP_DATA_WIDTH-1:0] sdata_r;
  input  wire                      sresp_req_sync_s;
  input  wire                      sresp_req_sync_r;

  output reg  [2:0]                sresp_sync_r;
  output reg  [OCP_DATA_WIDTH-1:0] sdata_sync_r;
  output reg  [7:0]                id_out;

  // --- SRESP_SYNC_PROC ---
  always @(posedge intf_clk or negedge intf_rst_n)
  begin : SRESP_SYNC_PROC
    if (intf_rst_n == 1'b0)
    begin
      sresp_sync_r <= OCP_SRESP_NULL;
      sdata_sync_r <= {OCP_DATA_WIDTH{1'b0}};
      id_out       <= 8'h00;
    end
    else
    begin
      // Logic for Constant Input
      id_out <= cfg_device_id;

      if (sresp_sync_r != OCP_SRESP_NULL)
      begin
        sresp_sync_r <= OCP_SRESP_NULL;
      end
      else if (sresp_req_sync_s == 1'b1 && sresp_req_sync_r == 1'b0)
      begin
        if (seq_enable_1) sresp_sync_r <= sresp_r; 
        sdata_sync_r <= sdata_r;
      end
    end
  end

endmodule