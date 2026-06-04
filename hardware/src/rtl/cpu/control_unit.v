
`timescale 1ns / 1ps

module control_unit(
    input [5:0] opcode,
    input [5:0] funct,
    
    output reg          MemtoReg,
    output reg          MemWrite,
    output reg          Branch,
    output reg [2:0]    ALUControl,
    output reg          ALUSrc,
    output reg          RegDst,
    output reg          RegWrite
);

    reg [1:0] ALUOp;
    
    //main Decoder
    always @(*)
    begin
        case(opcode)
            6'b000000:  //R-type
             begin
              MemtoReg = 1'b0;
              MemWrite = 1'b0;
              Branch   = 1'b0;
              ALUOp    = 2'b01;
              ALUSrc   = 1'b0;
              RegDst   = 1'b1;
              RegWrite  = 1'b1;
             end
            
            6'b001000: //I-type, addi
             begin
              MemtoReg = 1'b0;
              MemWrite = 1'b0;
              Branch   = 1'b0;
              ALUOp    = 2'b00;
              ALUSrc   = 1'b1;
              RegDst   = 1'b0;
              RegWrite  = 1'b1;
             end
            
            6'b100011: //I-type, lw
             begin
              MemtoReg = 1'b1;
              MemWrite = 1'b0;
              Branch   = 1'b0;
              ALUOp    = 2'b00;
              ALUSrc   = 1'b1;
              RegDst   = 1'b0;
              RegWrite  = 1'b1;
             end
             
            6'b101011: //I-type, sw
             begin
              MemtoReg = 1'b0; // whatever
              MemWrite = 1'b1;
              Branch   = 1'b0;
              ALUOp    = 2'b00;
              ALUSrc   = 1'b1;
              RegDst   = 1'b0; // whatever
              RegWrite  = 1'b0;
             end
            
            6'b000100: //I-type, beg
             begin
              MemtoReg = 1'b0;
              MemWrite = 1'b0;
              Branch   = 1'b1;
              ALUOp    = 2'b10;
              ALUSrc   = 1'b0;
              RegDst   = 1'b0; // whatever
              RegWrite  = 1'b0;
             end
             
            default:
                begin
                    MemtoReg = 1'b0;
                    MemWrite = 1'b0;
                    Branch   = 1'b0;
                    ALUOp    = 2'b00;
                    ALUSrc   = 1'b0;
                    RegDst   = 1'b0;
                    RegWrite  = 1'b0;
                 end
        endcase
   end             
   
   //ALU Decoder => ALU Control
   always @(*)
   begin
    if (ALUOp == 2'b01)
        begin
            case(funct)
             6'b100000 : ALUControl = 3'b000;
             6'b100010 : ALUControl = 3'b001;
             6'b100100 : ALUControl = 3'b010;
             6'b100101 : ALUControl = 3'b011;
             6'b101010 : ALUControl = 3'b101;
             default:    ALUControl = 3'b000;
            endcase
        end
     else if (ALUOp == 2'b10)
        ALUControl = 3'b001;
     else
        ALUControl = 3'b000;
   end
  

endmodule