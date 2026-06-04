module MIPS_cpu( 
  input           clk, 
  input           rst_n, 
  output  [31:0]  pc,           //program counter for instruction fetch 
  input   [31:0]  inst,         //incoming instruction 
 
  output          MemWrite,     //control signal, 'memory write' 
  output  [31:0]  MemAddr,      //memory access address 
  output  [31:0]  MemWData,     //memory wirte data 
  input   [31:0]  MemRData      //memory read data 
); 
 
  parameter RESET_PC = 32'h0001_0000;
  
    // hazard unit
  wire StallF, StallD, FlushE, ForwardAD, ForwardBD;
  wire [1:0] ForwardAE, ForwardBE;
  
  hazard_unit u_hazard_unit(
  .BranchD(BranchD),.MemtoRegE(MemtoRegE),.RegWriteE(RegWriteE),.MemtoRegM(MemtoRegM),.RegWriteM(RegWriteM),.RegWriteW(RegWriteW)
  ,.RsD(RsD),.RtD(RtD),.RsE(RsE),.RtE(RtE),.WriteRegE(WriteRegE),.WriteRegM(WriteRegM),.WriteRegW(WriteRegW)
  ,.StallF(StallF),.StallD(StallD),.ForwardAD(ForwardAD),.ForwardBD(ForwardBD),.FlushE(FlushE),.ForwardAE(ForwardAE),.ForwardBE(ForwardBE));
 
  // Fetch 
    wire [31:0] PCPlus4F; 
     
 next_pc_logic_pipe #( 
    .RESET_PC    (RESET_PC) 
  ) u_next_pc_logic_pipe(
    .clk(clk),
    .rst_n(rst_n),
    .signimm(signimmD),
    .PCSrc(PCSrcD),
    .PCPlus4D(PCPlus4D),
    .EN(~StallF),
    .PCPlus4F(PCPlus4F),
    .pcF(pc)
  ); 
  wire [31:0] instrF; 
  assign instrF = inst; 
  // IF_ID pipeline register 
  wire [31:0] instrD; 
  wire [31:0] PCPlus4D; 
   
 IF_ID_pipe_reg u_IF_ID_pipe_reg( 
 .clk(clk),.rst_n(rst_n),.EN(~StallD),.clr(PCSrcD)
 ,.i_inst(instrF),.i_PCPlus4(PCPlus4F) 
 ,.o_inst(instrD),.o_PCPlus4(PCPlus4D)); 
  
  // Decode 
  wire [31:0] RD1D; 
  wire [31:0] RD2D; 
   
  reg_file_async rf( 
  .clk        (clk), 
    .rst_n      (rst_n), 
    .we         (RegWriteW), 
    .ra1        (instrD[25:21]),  
    .ra2        (instrD[20:16]), 
    .wa         (WriteRegW), 
    .wd         (ResultW), 
    .rd1        (RD1D),  
    .rd2        (RD2D) 
 ); 
   
   wire RegWriteD; 
   wire MemtoRegD; 
   wire MemWriteD; 
   wire BranchD; 
   wire [2:0] ALUControlD; 
   wire ALUSrcD; 
   wire RegDstD; 
    
  control_unit u_control_unit( 
    .opcode     (instrD[31:26]), 
    .funct      (instrD[5:0]), 
 
    .MemtoReg   (MemtoRegD), 
    .MemWrite   (MemWriteD), 
    .Branch     (BranchD), 
    .ALUControl (ALUControlD), 
    .ALUSrc     (ALUSrcD), 
    .RegDst     (RegDstD), 
    .RegWrite   (RegWriteD) 
  ); 
 
   wire [31:0] signimmD; 
    
  sign_extension u_extension( 
   .imm        (instrD[15:0]), 
   .signimm    (signimmD) 
  ); 
  
  wire [31:0] EqualDA1;
  wire [31:0] EqualDA2;
  wire EqualD;
  
  assign EqualDA1 = (ForwardAD)?(ALUOutM):(RD1D);
  assign EqualDA2 = (ForwardBD)?(ALUOutM):(RD2D);
  assign EqualD = (EqualDA1==EqualDA2);

  
  assign PCSrcD = BranchD & EqualD;
  
  wire [4:0] RsD;
  wire [4:0] RtD;
  wire [4:0] RdD;
  
  assign RsD = instrD[25:21];
  assign RtD = instrD[20:16];
  assign RdD = instrD[15:11];
  
   
  //ID_EXE pipeline register 
   wire RegWriteE; 
   wire MemtoRegE; 
   wire MemWriteE; 
   wire [2:0] ALUControlE; 
   wire ALUSrcE; 
   wire RegDstE; 
    
   wire [31:0] instrE; 
   wire [31:0] RD1E; 
   wire [31:0] RD2E; 
   wire [31:0] signimmE; 
   wire [4:0] RsE;
   wire [4:0] RtE;
   wire [4:0] RdE;
    
  ID_EXE_pipe_reg u_ID_EXE_pipe_reg( 
  .clk(clk),.rst_n(rst_n),.clr(FlushE)
  ,.i_MemtoReg(MemtoRegD),.i_MemWrite(MemWriteD),.i_ALUControl(ALUControlD) 
  ,.i_ALUSrc(ALUSrcD),.i_RegDst(RegDstD),.i_RegWrite(RegWriteD) 
  ,.o_MemtoReg(MemtoRegE),.o_MemWrite(MemWriteE),.o_ALUControl(ALUControlE) 
  ,.o_ALUSrc(ALUSrcE),.o_RegDst(RegDstE),.o_RegWrite(RegWriteE) 
  ,.i_inst(instrD),.i_RD1(RD1D),.i_RD2(RD2D),.i_signimm(signimmD),.i_Rs(RsD),.i_Rt(RtD),.i_Rd(RdD) 
  ,.o_inst(instrE),.o_RD1(RD1E),.o_RD2(RD2E),.o_signimm(signimmE),.o_Rs(RsE),.o_Rt(RtE),.o_Rd(RdE)); 
   
  //Execute 
  wire [31:0] SrcAE;
  wire [31:0] SrcBE;
  
  assign SrcAE = (ForwardAE == 2'b00) ? RD1E :
                  (ForwardAE == 2'b01) ? ResultW :
                  (ForwardAE == 2'b10) ? ALUOutM : 32'h0;
  
  assign SrcBE = (ForwardBE == 2'b00) ? RD2E :
                  (ForwardBE == 2'b01) ? ResultW :
                  (ForwardBE == 2'b10) ? ALUOutM : 32'h0;

  wire [31:0] ALUOutE; 
   
  alu_32bit u_alu( 
    .ALUSrc     (ALUSrcE), 
    .ALUControl (ALUControlE), 
    .signimm    (signimmE), 
    .RD1        (SrcAE), 
    .RD2        (SrcBE), 
    .result     (ALUOutE), 
    .Z          () 
  ); 
   
  wire [31:0] WriteDataE; 
  assign WriteDataE = SrcBE; 
   
  wire [4:0] WriteRegE; 
   
  write_back_address u_write_back_address( 
 .RegDst     (RegDstE),   
    .instr      (instrE), 
    .WriteReg   (WriteRegE) 
  );  
   
  // instance EXE_MEM pipeling register 
  wire MemtoRegM; 
  wire MemWriteM; 
  wire RegWriteM; 
   
   
  wire [31:0] instrM; 
  wire [31:0] WriteDataM; 
  wire [31:0] ALUOutM; 
  wire [4:0] WriteRegM;  
   
  EXE_MEM_pipe_reg u_EXE_MEM_pipe_reg( 
  .clk(clk),.rst_n(rst_n) 
  ,.i_MemtoReg(MemtoRegE),.i_MemWrite(MemWriteE),.i_RegWrite(RegWriteE) 
  ,.o_MemtoReg(MemtoRegM),.o_MemWrite(MemWriteM),.o_RegWrite(RegWriteM) 
,.i_WriteData(WriteDataE),.i_ALUOut(ALUOutE),.i_WriteReg(WriteRegE),.i_inst(instrE) 
,.o_WriteData(WriteDataM),.o_ALUOut(ALUOutM),.o_WriteReg(WriteRegM),.o_inst(instrM));
 
// MEM  
assign MemWrite = MemWriteM; 
assign MemAddr  = ALUOutM; 
assign MemWData = WriteDataM; 

wire [31:0] ReadDataM; 
assign ReadDataM = MemRData; 

//MEM_WB pipeline register 
wire MemtoRegW; 
wire RegWriteW; 

wire [31:0] instrW; 
wire [31:0] ALUOutW; 
wire [4:0] WriteRegW; 
wire [31:0] ReadDataW; 

MEM_WB_pipe_reg u_MEM_WB_pipe_reg( 
.clk(clk),.rst_n(rst_n) 
,.i_MemtoReg(MemtoRegM),.i_RegWrite(RegWriteM) 
  ,.o_MemtoReg(MemtoRegW),.o_RegWrite(RegWriteW) 
  ,.i_ALUOut(ALUOutM),.i_WriteReg(WriteRegM),.i_ReadData(ReadDataM),.i_inst(instrM) 
  ,.o_ALUOut(ALUOutW),.o_WriteReg(WriteRegW),.o_ReadData(ReadDataW),.o_inst(instrW)); 
   
  // WB 
   wire [31:0] ResultW; 
   
 write_back_data u_write_back_data( 
  .MemtoReg   (MemtoRegW),   
  .ALUResult  (ALUOutW), 
  .ReadData   (ReadDataW), 
  .Result     (ResultW) 
 ); 
   

 
 
endmodule 
