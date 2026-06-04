`timescale 1ns / 1ps


module sign_extension(
    input [15:0]    imm,
    output [31:0]   signimm
);

  assign signimm = {{16{imm[15]}},imm};

endmodule
