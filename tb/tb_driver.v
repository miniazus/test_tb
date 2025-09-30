// tb_driver.sv
`timescale 1ps/1ps

module tb_driver #(
  parameter int DATA_WIDTH   = 512
)(
  input  logic                    clk,
  input  logic                    rst_n,
  output logic [DATA_WIDTH-1:0]   data_in,
  output logic [7:0]              sid_in,
  output logic                    data_valid,
  input  logic [DATA_WIDTH-1:0]   data_out
);

  // File handling
  int fd_in;    // file descriptor for input
  int fd_out;   // file descriptor for output
  string line;
  real sim_time_ps;
  int sid;
  bit [DATA_WIDTH-1:0] data_vec;

  // Open input file and read/apply vectors at exact time
  initial begin
    fd_in = $fopen("input_vectors.txt", "r");
    if (fd_in == 0) begin
      $error("Failed to open input_vectors.txt");
      $finish;
    end

    fd_out = $fopen("output_vectors.txt", "w");
    if (fd_out == 0) begin
      $error("Failed to open output_vectors.txt");
      $finish;
    end

    data_in    = '0;
    data_valid = 0;

    @(posedge rst_n); // wait for reset deasserted

    while (!$feof(fd_in)) begin           //$feof() is a file status function used when reading files.
      void'($fgets(line, fd_in));         //$fgets is a system task used to read a line of text from a file.
      if (line.len() > 0) begin
        // parse: time_in_ps;sid;512-bit-data
        void'($sscanf(line, "%f;%d;%b", sim_time_ps, sid, data_vec));  //$sscanf: parse a string and extract values into variables

        // wait until simulation reaches this time
        #(sim_time_ps - $realtime);

        // apply data for 1 clock cycle
        data_in     <= data_vec;
        data_valid  <= 1;
        sid_in      <= sid;

        @(posedge clk);
        data_valid <= 0;

        // optional: clear input after pulse
        data_in <= '0;
      end
    end


    $fclose(fd_in);
    $fclose(fd_out);

    $display("Driver: Finished applying all vectors.");
  end

  // Capture DUT outputs
  always @(posedge clk) begin
    if (data_valid) begin
      $fwrite(fd_out, "%h\n", data_out);
    end
  end

endmodule
