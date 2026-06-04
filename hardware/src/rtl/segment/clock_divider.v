`timescale 1ns/1ns

module clock_divider(
	input clk_100MHz,
	input rst_n,
	output reg clk_out   
);
     
  reg [15:0] count;   
            
  always@(posedge clk_100MHz, negedge rst_n)
  begin
    if(!rst_n) begin
      count   <= 16'h0;
      clk_out <= 0;
    end         
    else begin
      if(count == 25 -1) begin        //(SIM)
      //if(count == 50000 -1) begin   //(FPGA) 100MHz -> 1000Hz
        count   <= 16'h0;
        clk_out <= ~clk_out;
      end
      else  begin
        count   <= count + 1;
      end
    end
  end
             
endmodule
