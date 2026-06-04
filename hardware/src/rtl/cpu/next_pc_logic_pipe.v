`timescale 1ns / 1ps

module next_pc_logic_pipe( 
    input               clk, 
    input               rst_n, 
    input       [31:0]  signimm, 
    input               PCSrc,  
    input       [31:0]  PCPlus4D,
    input               EN, 
     
    output      [31:0]  PCPlus4F,
    output  reg [31:0]  pcF 
 ); 
  
 parameter  RESET_PC = 32'h0001_0000; 
  
 wire [31:0]    PCNext; 
  
 wire [31:0]    signimm_shift; 
 assign signimm_shift = signimm << 2; 
  
 
 ripple_carry_adder u_pc_plus_4( 
 .a(pcF),.b(32'h4),.cin(1'b0),.sum(PCPlus4F),.cout()); 

  wire [31:0] PCBranchD;
  
 ripple_carry_adder u_pc_target( 
 .a(PCPlus4D),.b(signimm_shift),.cin(1'b0),.sum(PCBranchD),.cout()); 
  
 //PCNext signal  
  
 assign PCNext = (PCSrc)?(PCBranchD):(PCPlus4F); 
  
 always @(posedge clk, negedge rst_n) 
 begin 
    if (!rst_n) 
        pcF <= RESET_PC; 
    else if (EN)
        pcF <= PCNext; 
 end 
  
endmodule

