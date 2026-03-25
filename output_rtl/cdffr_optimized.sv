

module cdffr ( q, clk, rst_n, c, e, d ) ; 
  parameter type T = logic;
  parameter T INIT  = T'('0);

  // ---------------------------------------------------------------------------
  // POWER OPTIMIZATION: AI-Injected Sequential Enable Logic
  // Target Register: q
  // ---------------------------------------------------------------------------
  wire seq_enable_1;
  wire wire_q_1_w10;
  wire wire_q_1_w8;
  wire wire_q_1_w6;
  wire wire_q_1_w4;
  reg reg_q_1_w5;
  reg reg_q_1_w2;
  assign wire_q_1_w4 = ((!(c & reg_q_1_w2)) & (e | c));
  assign wire_q_1_w6 = ((!reg_q_1_w5) & (e | c));
  assign wire_q_1_w8 = (e | c);
  assign wire_q_1_w10 = (!rst_n);
  always @(posedge clk or posedge wire_q_1_w10)
    begin
    if (wire_q_1_w10)
      reg_q_1_w5 <= 1'b0;
    else
      reg_q_1_w5 <= wire_q_1_w8;
  end
  always @(posedge clk or posedge wire_q_1_w10)
    begin
    if (wire_q_1_w10)
      reg_q_1_w2 <= 1'b0;
    else
      reg_q_1_w2 <= c;
  end
  assign seq_enable_1 = (wire_q_1_w4 | wire_q_1_w6);
  // ---------------------------------------------------------------------------
  input         clk;
  input         rst_n;
  input         e, c;
  input  T      d;
  output T      q;
  always @(posedge clk or negedge rst_n) 
    if (!rst_n)     q <= INIT ;
    // Updated code to better version for coverage. 
    else if (c) q <= INIT; //solidify {'X(fail d == 0)};
    else if (e) if (seq_enable_1) q <= d; 
endmodule

