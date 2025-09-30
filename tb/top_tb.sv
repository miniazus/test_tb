// top_tb.sv
`timescale 1ps/1ps

module top_tb;

  // Parameters
  localparam int DATA_WIDTH   = 512;
  localparam int N_CYCLES     = 4;
  localparam int CLK_FREQ_HZ  = 357_000_000;
  localparam real CLK_PERIOD_NS = 1e9 / CLK_FREQ_HZ;

  // Clock and reset
  logic clk;
  logic rst_n;

  // DUT signals (DUT: Design Under Test)
  logic [DATA_WIDTH-1:0] data_in;
  logic                  data_valid;
  logic [DATA_WIDTH-1:0] data_out;

  // DUT instance (replace with your real top module)
  top dut (
    .clk       (clk),
    .rst_n     (rst_n),
    .data_in   (data_in),
    .sid_in    (sid_in),
    .data_valid(data_valid),
    .data_out  (data_out)
  );

  // Driver instance
  tb_driver #(
    .DATA_WIDTH (DATA_WIDTH),
    .N_CYCLES   (N_CYCLES),
    .CLK_FREQ_HZ(CLK_FREQ_HZ)
  ) driver (
    .clk       (clk),
    .rst_n     (rst_n),
    .data_in   (data_in),
    .sid_in    (sid_in),
    .data_valid(data_valid),
    .data_out  (data_out)
  );

  // Clock generation
  initial begin       //Runs once at the start of simulation.
    clk = 0;
    forever #(CLK_PERIOD_NS/2) clk = ~clk;
  end

  // Reset sequence
  initial begin
    rst_n = 0;
    #(10*CLK_PERIOD_NS);  //Waits for 10 clock periods worth of simulation time.
    rst_n = 1;
  end

  // End simulation after all vectors are applied
  initial begin
    #(1_000_000*CLK_PERIOD_NS); // adjust time or add condition
    $display("Simulation finished.");
    $finish;
  end

endmodule
