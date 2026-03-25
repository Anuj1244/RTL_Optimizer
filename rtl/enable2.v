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
        sresp_sync_r <= sresp_r;
        sdata_sync_r <= sdata_r;
      end
    end
  end

endmodule