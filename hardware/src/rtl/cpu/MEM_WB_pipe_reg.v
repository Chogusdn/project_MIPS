module MEM_WB_pipe_reg( 
 input clk, 
 input rst_n, 
 
 //control signal 
 input  i_MemtoReg, 
 input  i_RegWrite, 
 
 output reg   o_MemtoReg, 
 output reg  o_RegWrite, 
 
 //datapath signal 
      input [31:0] i_inst, 
 input [31:0] i_ALUOut, 
 input [4:0] i_WriteReg, 
 input [31:0] i_ReadData, 
 
      output reg [31:0] o_inst, 
 output reg [31:0] o_ALUOut, 
 output reg [4:0] o_WriteReg, 
 output reg [31:0] o_ReadData 
); 
 
 always @(posedge clk, negedge rst_n) 
 begin 
  if(!rst_n) 
  begin 
   //control signal 
   o_MemtoReg <= 1'b0; 
   o_RegWrite  <= 1'b0; 
 
   //datapath signal 
                      o_inst                   <= 32'h0; 
   o_ALUOut  <= 32'h0; 
   o_WriteReg  <= 5'h0; 
   o_ReadData <= 32'h0; 
  end 
  else 
  begin 
   //control signal 
   o_MemtoReg <= i_MemtoReg; 
   o_RegWrite  <= i_RegWrite; 
 
   //datapath signal 
                      o_inst                  <= i_inst; 
   o_ALUOut  <= i_ALUOut; 
   o_WriteReg  <= i_WriteReg; 
   o_ReadData <= i_ReadData; 
end 
end 
endmodule
