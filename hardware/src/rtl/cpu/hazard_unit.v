module hazard_unit (
    input BranchD,       // control signal
    input MemtoRegE,
    input RegWriteE,
    input MemtoRegM,
    input RegWriteM,
    input RegWriteW,

    input [4:0] RsD,     // data signal
    input [4:0] RtD,
    input [4:0] RsE,
    input [4:0] RtE,
    input [4:0] WriteRegE,
    input [4:0] WriteRegM,
    input [4:0] WriteRegW,

    output reg StallF,
    output reg StallD,
    output reg ForwardAD,
    output reg ForwardBD,
    output reg FlushE,
    output reg [1:0] ForwardAE,
    output reg [1:0] ForwardBE
);

reg lwstall;
reg branchstall;

always @(*) begin
    // Default values
    StallF = 1'b0;
    StallD = 1'b0;
    ForwardAD = 1'b0;
    ForwardBD = 1'b0;
    FlushE = 1'b0;
    ForwardAE = 2'b00;
    ForwardBE = 2'b00;

    // Forwarding for RsE
    if ((RsE != 5'b0) && (RsE == WriteRegM) && RegWriteM)
        ForwardAE = 2'b10;
    else if ((RsE != 5'b0) && (RsE == WriteRegW) && RegWriteW)
        ForwardAE = 2'b01;//
    else
        ForwardAE = 2'b00;

    // Forwarding for RtE
    if ((RtE != 5'b0) && (RtE == WriteRegM) && RegWriteM)
        ForwardBE = 2'b10;
    else if ((RtE != 5'b0) && (RtE == WriteRegW) && RegWriteW)
        ForwardBE = 2'b01;
    else
        ForwardBE = 2'b00;//

    // Load-use stall detection
    lwstall = ((RsD == RtE) || (RtD == RtE)) && MemtoRegE;

    // Branch stall detection
    branchstall = (BranchD && RegWriteE && ((WriteRegE == RsD) || (WriteRegE == RtD))) || 
                  (BranchD && MemtoRegM && ((WriteRegM == RsD) || (WriteRegM == RtD))); 
      

    // Stall and Flush signals
 /*     if (branchstall) begin
        FlushE = 1'b1;
    end 
    else begin
        FlushE = 1'b0;
    end
    
    if (lwstall) begin
        StallF = 1'b1;
        StallD = 1'b1;
    end 
    else begin
        StallF = 1'b0;
        StallD = 1'b0;
    end */
    
    if (branchstall || lwstall) begin
        FlushE = 1'b1;
        StallF = 1'b1;
        StallD = 1'b1;
    end 
    else begin
        FlushE = 1'b0;
         StallF = 1'b0;
        StallD = 1'b0;
    end
    

    
    
    // Forwarding for RsD and RtD -> is that right? confuse... 
    if ((RsD != 5'b0) && (RsD == WriteRegM) && RegWriteM)
        ForwardAD = 1'b1;
    else
        ForwardAD = 1'b0;

    if ((RtD != 5'b0) && (RtD == WriteRegM) && RegWriteM)
        ForwardBD = 1'b1;
    else
        ForwardBD = 1'b0;
         
end

endmodule

   /* if ((RsD != 5'b0) && (RsD == WriteRegM) && RegWriteM)
        ForwardAD = 1'b1;
    else
        ForwardAD = 1'b0;

    if ((RtD != 5'b0) && (RtD == WriteRegE) && RegWriteE)
        ForwardBD = 1'b1;
    else
        ForwardBD = 1'b0; */








