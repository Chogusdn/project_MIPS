`timescale 1ns / 1ps


module write_back_address(
    input               RegDst,
    input [31:0]        instr,
    output reg [4:0]    WriteReg
 );
 
 always @(*)
 begin
    if (RegDst)
        WriteReg = instr[15:11];
    else
        WriteReg = instr[20:16];
  end
 
endmodule
