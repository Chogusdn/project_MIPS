module ID_EXE_pipe_reg(
	input clk,
	input rst_n,
	input clr,

	//control signal
	input 	i_MemtoReg,
	input 	i_MemWrite,
	input [2:0]  i_ALUControl,
	input		i_ALUSrc,
	input 	i_RegDst,
	input		i_RegWrite,

	output reg 		o_MemtoReg,
	output reg 		o_MemWrite,
	output reg [2:0]  	o_ALUControl,
	output reg		o_ALUSrc,
	output reg		o_RegDst,
	output reg		o_RegWrite,

	//datapath signal
	input [31:0] i_inst,
	input [31:0] i_RD1,
	input [31:0] i_RD2,
	input [31:0] i_signimm,
	input [4:0]  i_Rs,
	input [4:0]  i_Rt,
	input [4:0]  i_Rd,

	output reg [31:0] o_inst,
	output reg [31:0] o_RD1,
	output reg [31:0] o_RD2,
	output reg [31:0] o_signimm,
	output reg [4:0] o_Rs,
	output reg [4:0] o_Rt,
	output reg [4:0] o_Rd
);

	always @(posedge clk, negedge rst_n)
	begin
		if(!rst_n || clr)
		begin
			//control signal
			o_MemtoReg	<= 1'b0;
			o_MemWrite	<= 1'b0;
			o_ALUControl	<= 3'b0;
			o_ALUSrc		<= 1'b0;
			o_RegDst		<= 1'b0;
			o_RegWrite		<= 1'b0;

			//datapath signal
			o_inst		<= 32'h0;
			o_RD1		<= 32'h0;
			o_RD2		<= 32'h0;
			o_signimm		<= 32'h0;
			o_Rs         <= 5'h0;
			o_Rt         <= 5'h0;
			o_Rd         <= 5'h0;
		end
		else 
		begin
			//control signal
			o_MemtoReg	<= i_MemtoReg;
			o_MemWrite	<= i_MemWrite;
			o_ALUControl	<= i_ALUControl;
			o_ALUSrc		<= i_ALUSrc;
			o_RegDst		<= i_RegDst;
			o_RegWrite		<= i_RegWrite;
			
			//datapath signal
			o_inst		<= i_inst;
			o_RD1		<= i_RD1;
			o_RD2		<= i_RD2;
			o_signimm		<= i_signimm;
			o_Rs         <= i_Rs;
			o_Rt         <= i_Rt;
			o_Rd         <= i_Rd;
		end
	end

endmodule
			
		