`timescale 1ns / 1ps


module write_back_data(
    input               MemtoReg,
    input [31:0]        ALUResult,
    input [31:0]        ReadData,
    output reg [31:0]   Result
    );
    
 always @(*)
  begin
    if (MemtoReg == 1'b0)
        Result = ALUResult;
    else
        Result = ReadData;
  end
        
 
endmodule
