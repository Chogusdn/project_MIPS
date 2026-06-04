`timescale 1ns/1ps

module seg7driver(
  input clk,
  input [7:0] dataseg3,
  input [7:0] dataseg2,
  input [7:0] dataseg1,
  input [7:0] dataseg0,
  output reg [3:0]AN,
  output [7:0]segment
);

reg state;
reg [1:0]count;
reg [31:0] data_to_display;

always @(posedge clk) begin
case (state)
    0: begin
        AN <= 4'h8;
        data_to_display <= {dataseg3,dataseg2,dataseg1,dataseg0};
        state <= 1;
        count <= 0;
    end
    1: begin
        count <= count + 1;
        data_to_display <= data_to_display >> 8;
        AN <= AN >> 1;
        if(count == 3)
            state <= 0;
    end

    default : state <= 0;
endcase
end

assign segment = data_to_display[7:0];

endmodule
