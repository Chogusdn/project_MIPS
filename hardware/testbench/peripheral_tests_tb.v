///`timescale 1ns/1ns
`include "mem_path.vh"


//  This code references EECS151 in UCB.

module peripheral_tests_tb();
  reg clk, rst;
  localparam TIMEOUT_CYCLE = 1000_000;
  parameter MIF_HEX = "code.hex";

  initial clk = 0;
  always #(10) clk = ~clk;

	wire [7:0] hex;
	wire [3:0] hex_digit;
	wire [9:0] led;


	MIPS_System # (
   .RESET_PC	(32'h0001_0000),
   .MIF_HEX(MIF_HEX)
    ) CPU (
      .CLOCK_100(clk),
      .BUTTON   (~rst),
      .HEX			(hex),
      .HEX_DIGIT(hex_digit),
      .LED			(led)
	);



  reg [31:0] cycle;
  always @(posedge clk) begin
    if (rst === 1)
      cycle <= 0;
    else
      cycle <= cycle + 1;
  end


  reg [14:0] INST_ADDR;

  initial begin
    rst = 1;

    // Hold reset for a while
    repeat (10) @(posedge clk);

    @(negedge clk);
    rst = 0;

    // Delay for some time
    repeat (10) @(posedge clk);

    repeat (1000) @(posedge clk);
    $finish();
  end

  initial begin
    repeat (TIMEOUT_CYCLE) @(posedge clk);
    $display("Timeout!");
    $finish();
  end

endmodule
