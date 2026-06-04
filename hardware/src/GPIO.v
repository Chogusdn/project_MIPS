//`timescale 1ns/1ns

module GPIO(
  input clk,
  input rst_n,
  input CS_N,
  input WR_N,
  input       [11:0] 	Addr,
  input       [31:0]  DataIn,
  output      [7:0]	  HEX,
  output      [3:0]   HEX_DIGIT,
  output      [9:0]	  LED
);

  reg [31:0] LED_G;
  reg [31:0] HEX0_R;
  reg [31:0] HEX1_R;
  reg [31:0] HEX2_R;
  reg [31:0] HEX3_R;
  
   
  // Write Output Register
  always @(posedge clk or negedge rst_n)
  begin
    if(!rst_n)
    begin                                        
        LED_G[9:0]	<= 10'h3FF;
        HEX0_R 		  <= 8'b11111111;
        HEX1_R 		  <= 8'b11111111;
        HEX2_R 		  <= 8'b11111111;
        HEX3_R 		  <= 8'b11111111;
    end
  
    else  
    begin
      if(CS_N && WR_N) 
        begin
          //TO DO 1
          case (Addr)
            12'h8 : LED_G <= DataIn; 
            12'hC : HEX0_R <= DataIn;
            12'h10 : HEX1_R <= DataIn;
            12'h14 : HEX2_R <= DataIn;
            12'h18 : HEX3_R <= DataIn;
          endcase
        end
      else
        begin
          LED_G	      <= LED_G;
          HEX0_R 		  <= HEX0_R;
          HEX1_R 		  <= HEX1_R;
          HEX2_R 		  <= HEX2_R;
          HEX3_R 		  <= HEX3_R;
        end
    end
  end         
   
	//--------------------------------------
  //LED
	//--------------------------------------
  //TO DO 2
  assign LED = LED_G;
	//--------------------------------------
  //SEGMENT
	//--------------------------------------

	wire 	 [3:0] i_HEX0;
	wire 	 [3:0] i_HEX1;
	wire 	 [3:0] i_HEX2;
	wire 	 [3:0] i_HEX3;

	wire 	 [7:0] o_HEX0;
	wire 	 [7:0] o_HEX1;
	wire 	 [7:0] o_HEX2;
	wire 	 [7:0] o_HEX3;

	assign i_HEX0       = HEX0_R[3:0];
	assign i_HEX1       = HEX1_R[3:0];
	assign i_HEX2       = HEX2_R[3:0];
	assign i_HEX3       = HEX3_R[3:0];
 

  //------LUT ---------------------
  //TO DO 3
  SEG7_LUT u0_SEG7_LUT(
    .idata(i_HEX0),.oSEG(o_HEX0));
  SEG7_LUT u1_SEG7_LUT(
    .idata(i_HEX1),.oSEG(o_HEX1));
  SEG7_LUT u2_SEG7_LUT(
    .idata(i_HEX2),.oSEG(o_HEX2));
  SEG7_LUT u3_SEG7_LUT(
    .idata(i_HEX3),.oSEG(o_HEX3));  
 
  //------clock divider------------
  //TO DO 4
  wire clk_out;
  
  clock_divider u_clock_divider(
  .clk_100MHz(clk),.rst_n(rst_n),.clk_out(clk_out));
  //------driver ------------------
  //TO DO 5
  wire [3:0] digit;
  wire [7:0] segment;
	
  seg7driver driver(
		.clk		    (clk_out),  //1000Hz
		//.clk            (clk), //100MHz
		.dataseg3	    (o_HEX3),
		.dataseg2	    (o_HEX2),
		.dataseg1       (o_HEX1),
		.dataseg0       (o_HEX0),
		.AN			    (digit),
		.segment	    (segment)
	);

	assign HEX_DIGIT = digit;
	assign HEX = segment;
endmodule
