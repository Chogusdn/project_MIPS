`timescale 1ns/1ps

module SEG7_LUT	(
    idata, 
    oSEG
);

input	      [3:0]	idata;
output	reg [7:0]	oSEG;

always @(*)
begin
		case(idata)
		4'h0: oSEG = 8'b00111111;  	
		4'h1: oSEG = 8'b00000110;	
		4'h2: oSEG = 8'b01011011; 
		4'h3: oSEG = 8'b01001111; 	
		4'h4: oSEG = 8'b01100110; 	
		4'h5: oSEG = 8'b01101101; 
		4'h6: oSEG = 8'b01111101; 	
		4'h7: oSEG = 8'b00100111; 	
		4'h8: oSEG = 8'b01111111; 	
		4'h9: oSEG = 8'b01101111; 	

		4'ha: oSEG = 8'b00000000;  //A
		4'hb: oSEG = 8'b00000000;  //b
		4'hc: oSEG = 8'b00000000;  //C
		4'hd: oSEG = 8'b00000000;  //d
		4'he: oSEG = 8'b00000000;  //E
		4'hf: oSEG = 8'b00000000;  //F

		endcase
end

endmodule
