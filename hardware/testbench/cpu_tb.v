//`timescale 1ns/1ps

`include "opcode.vh"
`include "mem_path.vh"


//  This code references EECS151 in UCB.


module cpu_tb();
  reg clk, rst;
  //parameter CPU_CLOCK_PERIOD = 20;

  initial clk = 0;
  //always #(CPU_CLOCK_PERIOD/2) clk = ~clk;
  always #(10) clk = ~clk;

  parameter RESET_PC = 32'h0001_0000;

 MIPS_System  #(
      .RESET_PC(RESET_PC)
  ) CPU (
        .CLOCK_100  (clk),
        .BUTTON     (~rst),
        .HEX        (),
        .HEX_DIGIT  (),
        .LED        ()
  );

  wire [31:0] timeout_cycle = 25; 

  //------------------------------------------------------
  // Reset IMem, DMem, and RegFile before running new test
  //------------------------------------------------------
  task reset;
    integer i;
    begin
      for (i = 0; i < `RF_PATH.DEPTH; i = i + 1) begin
        `RF_PATH.mem[i] = 0;
      end
      for (i = 0; i < `DMEM_PATH.DEPTH; i = i + 1) begin
        `DMEM_PATH.mem[i] = 0;
      end
      for (i = 0; i < `IMEM_PATH.DEPTH; i = i + 1) begin
        `IMEM_PATH.mem[i] = 0;
      end
    end
  endtask


  //------------------------------------------------------
  task reset_cpu; 
  begin
    @(negedge clk);
    rst = 1;
    @(negedge clk);
    rst = 0;
  end
  endtask


  //------------------------------------------------------
  task init_rf;
    integer i;
    begin
      for (i = 1; i < `RF_PATH.DEPTH; i = i + 1) begin
        `RF_PATH.mem[i] = 100 * i + 1;
      end
    end
  endtask


  reg [31:0] cycle;
  reg done;
  reg [31:0]  current_test_id = 0;
  reg [255:0] current_test_type;
  reg [31:0]  current_output;
  reg [31:0]  current_result;
  reg all_tests_passed = 0;


  // Check for timeout
  // If a test does not return correct value in a given timeout cycle,
  // we terminate the testbench
  initial begin
    while (all_tests_passed === 0) begin
      @(posedge clk);
      if (cycle === timeout_cycle) begin
        $display("[Failed] Timeout at [%d] test %s, expected_result = %h, got = %h",
                current_test_id, current_test_type, current_result, current_output);
        //$finish();
      end
    end
  end

  always @(posedge clk) begin
    if (done === 0)
      cycle <= cycle + 1;
    else
      cycle <= 0;
  end

  // Check result of RegFile
  // If the write_back (destination) register has correct value (matches "result"), test passed
  // This is used to test instructions that update RegFile
  task check_result_rf;
    input [31:0]  rf_wa;
    input [31:0]  result;
    input [255:0] test_type;
    begin
      done = 0;
      current_test_id   = current_test_id + 1;
      current_test_type = test_type;
      current_result    = result;
      while (`RF_PATH.mem[rf_wa] !== result) begin
        current_output = `RF_PATH.mem[rf_wa];
        @(posedge clk);
      end
      cycle = 0;
      done = 1;
      $display("[%d] Test %s passed!", current_test_id, test_type);
    end
  endtask

  // Check result of DMem
  // If the memory location of DMem has correct value (matches "result"), test passed
  // This is used to test store instructions
  task check_result_dmem;
    input [31:0]  addr;
    input [31:0]  result;
    input [255:0] test_type;
    begin
      done = 0;
      current_test_id   = current_test_id + 1;
      current_test_type = test_type;
      current_result    = result;
      while (`DMEM_PATH.mem[addr] !== result) begin
        current_output = `DMEM_PATH.mem[addr];
        @(posedge clk);
      end
      cycle = 0;
      done = 1;
      $display("[%d] Test %s passed!", current_test_id, test_type);
    end
  endtask

  //integer i;

  reg [31:0] num_cycles = 0;
  reg [31:0] num_insts  = 0;
  reg [4:0]  RS, RT;
  reg [4:0]  RS1, RT1;
  reg [4:0]  RS2, RT2;
  reg [4:0]  RS3, RT3;
  reg [31:0] RD, RD1, RD2, RD3;
  reg [4:0]  SHAMT;
  reg [31:0] IMM, IMM0, IMM1, IMM2, IMM3;
  reg [14:0] INST_ADDR;
  reg [14:0] DATA_ADDR;

  reg [14:0] DATA_ADDR0, DATA_ADDR1, DATA_ADDR2, DATA_ADDR3;

  reg [14:0] DATA_ADDR4, DATA_ADDR5, DATA_ADDR6, DATA_ADDR7;
  reg [14:0] DATA_ADDR8, DATA_ADDR9;

  reg [31:0] JUMP_ADDR;

  reg [31:0]  BR_TAKEN_OP1  [5:0];
  reg [31:0]  BR_TAKEN_OP2  [5:0];
  reg [31:0]  BR_NTAKEN_OP1 [5:0];
  reg [31:0]  BR_NTAKEN_OP2 [5:0];
  reg [2:0]   BR_TYPE       [5:0];
  reg [255:0] BR_NAME_TK1   [5:0];
  reg [255:0] BR_NAME_TK2   [5:0];
  reg [255:0] BR_NAME_NTK   [5:0];

  initial begin

    #0;
    rst = 0;

    // Reset the CPU
    rst = 1;
    // Hold reset for a while
    repeat (10) @(posedge clk);

    @(negedge clk);
    rst = 0;

if (1) begin
    // Test R-Type Insts --------------------------------------------------
    // - ADD, SUB, AND, OR, SLT
    reset();

    // We can also use $random to generate random values for testing
    RS = 1; RD1 = -100;
    RT = 2; RD2 =  200;
    RD  = 3;

    `RF_PATH.mem[RS] = RD1;
    `RF_PATH.mem[RT] = RD2;

    SHAMT           = 5'd20;
    INST_ADDR       = 14'h0000;

    `IMEM_PATH.mem[INST_ADDR + 0]  = {`OPC_ARI_RTYPE,  RS,  RT,  5'd3,  SHAMT,  `FNC_ADD};  //0x0022_1d20
    `IMEM_PATH.mem[INST_ADDR + 1]  = {`OPC_ARI_RTYPE,  RS,  RT,  5'd4,  SHAMT,  `FNC_SUB};
    `IMEM_PATH.mem[INST_ADDR + 2]  = {`OPC_ARI_RTYPE,  RS,  RT,  5'd5,  SHAMT,  `FNC_AND};
    `IMEM_PATH.mem[INST_ADDR + 3]  = {`OPC_ARI_RTYPE,  RS,  RT,  5'd6,  SHAMT,  `FNC_OR};
    `IMEM_PATH.mem[INST_ADDR + 4]  = {`OPC_ARI_RTYPE,  RS,  RT,  5'd7,  SHAMT,  `FNC_SLT};

    reset_cpu();

    check_result_rf(5'd3,  32'h00000064, "R-Type ADD");
    check_result_rf(5'd4,  32'hfffffed4, "R-Type SUB");
    check_result_rf(5'd5,  32'h00000088, "R-Type AND");
    check_result_rf(5'd6,  32'hffffffdc, "R-Type OR");
    check_result_rf(5'd7,  32'h1,        "R-Type SLT");
end

if (1) begin
    // Test I-Type Insts --------------------------------------------------
    // - ADDI, BEQ, LW, SW 

    // Test I-type arithmetic instructions
    reset();

    RS1  = 1; RD1 = -100;
    RT1  = 3; 

    RS2  = 4; RD2 = -100;
    RT2  = 6; 

    RS3  = 7; RD3 = 32'hC;
    RT3  = 8; 
 
    `RF_PATH.mem[RS1] = RD1;
    `RF_PATH.mem[RS2] = RD2;
    `RF_PATH.mem[RS3] = RD3;
    IMM1              = -200;
    IMM2              = -500;
    IMM3              = 20000;
    INST_ADDR         = 14'h0000;

    `IMEM_PATH.mem[INST_ADDR + 0]  = {`OPC_ADDI,  RS1,  RT1,  IMM1[15:0]};
    `IMEM_PATH.mem[INST_ADDR + 1]  = {`OPC_ADDI,  RS2,  RT2,  IMM2[15:0]};
    `IMEM_PATH.mem[INST_ADDR + 2]  = {`OPC_ADDI,  RS3,  RT3,  IMM3[15:0]};

    reset_cpu();

    check_result_rf(5'd3,  32'hfffffed4, "I-Type ADD 1");
    check_result_rf(5'd6,  32'hfffffda8, "I-Type ADD 2");
    check_result_rf(5'd8,  32'h00004E2C, "I-Type ADD 3");

end

if (1) begin
    // Test I-type load instructions
    // - LW
    reset();

    RS1 = 1; 
    `RF_PATH.mem[1] = 32'h3000_0100;
    `RF_PATH.mem[4] = 32'h3000_0110;

    IMM0            = 32'h0000_0000;
    IMM1            = 32'h0000_0000;

    INST_ADDR       = 14'h0000;

    DATA_ADDR1      = (`RF_PATH.mem[1]  + IMM0[11:0]) >> 2;
    DATA_ADDR2      = (`RF_PATH.mem[4]  + IMM1[11:0]) >> 2;

    `IMEM_PATH.mem[INST_ADDR + 0]  = {`OPC_LW,  5'd1,  5'd2,  IMM0[15:0]};
    `IMEM_PATH.mem[INST_ADDR + 1]  = {`OPC_LW,  5'd4,  5'd6,  IMM0[15:0]};

    `DMEM_PATH.mem[DATA_ADDR1] = 32'hdeadbeef;
    `DMEM_PATH.mem[DATA_ADDR2] = 32'hFFFFFFFF;

    reset_cpu();

    check_result_rf(5'd2,  32'hdeadbeef, "I-Type LW 1");
    check_result_rf(5'd6,  32'hFFFFFFFF, "I-Type LW 2");
end


if (1) begin
    // Test S-Type Insts --------------------------------------------------
    // - SW

    reset();

    `RF_PATH.mem[1]  = 32'h12345678;
    `RF_PATH.mem[5]  = 32'hbeefdead;

    `RF_PATH.mem[3]  = 32'h3000_0010;
    `RF_PATH.mem[7]  = 32'h4000_0010;

    IMM0 = 32'h0000_0100;

    INST_ADDR = 14'h0000;

    DATA_ADDR0 = (`RF_PATH.mem[3]  + IMM0[11:0]) >> 2;
    DATA_ADDR1 = (`RF_PATH.mem[7]  + IMM0[11:0]) >> 2;

    //rs = 2, rt = 1
    `IMEM_PATH.mem[INST_ADDR + 0]  = {`OPC_SW,  5'd3,  5'd1,  IMM0[15:0]};
    `IMEM_PATH.mem[INST_ADDR + 1]  = {`OPC_SW,  5'd7,  5'd5,  IMM0[15:0]};

    `DMEM_PATH.mem[DATA_ADDR0] = 0;
    `DMEM_PATH.mem[DATA_ADDR1] = 0;

    reset_cpu();

    check_result_dmem(DATA_ADDR0, 32'h12345678, "I-Type SW 1");
    check_result_dmem(DATA_ADDR1, 32'hbeefdead, "I-Type SW 2");

end

if (1) begin
      // Test B-Type Insts --------------------------------------------------
      // - BEQ

      IMM       = 32'h0000_0FF0;
      INST_ADDR = 14'h0000;
      //JUMP_ADDR = (32'h1000_0004 + (IMM << 2)) >> 2;
      JUMP_ADDR = (RESET_PC + 32'h0000_0004 + (IMM << 2)) >> 2;

      BR_TYPE[0]     = `OPC_BEQ;
      BR_NAME_TK1[0] = "B-Type BEQ Taken 1";
      BR_NAME_TK2[0] = "B-Type BEQ Taken 2";
      BR_NAME_NTK[0] = "B-Type BEQ Not Taken";
      BR_TAKEN_OP1[0]  = 100; BR_TAKEN_OP2[0]  = 100;
      BR_NTAKEN_OP1[0] = 100; BR_NTAKEN_OP2[0] = 200;
      SHAMT = 5'd20;

      reset();

      `RF_PATH.mem[1] = BR_TAKEN_OP1[0];
      `RF_PATH.mem[2] = BR_TAKEN_OP2[0];
      `RF_PATH.mem[3] = 300;
      `RF_PATH.mem[4] = 400;

      // Test branch taken
      `IMEM_PATH.mem[INST_ADDR + 0]  = {`OPC_BEQ,  5'd2,  5'd1,  IMM[15:0]};
      `IMEM_PATH.mem[INST_ADDR + 1]  = {`OPC_ARI_RTYPE,  5'd3,  5'd4,  5'd5,  SHAMT,  `FNC_ADD};
      `IMEM_PATH.mem[JUMP_ADDR[13:0]]= {`OPC_ARI_RTYPE,  5'd3,  5'd4,  5'd6,  SHAMT,  `FNC_ADD};

      reset_cpu();

      check_result_rf(5'd5, 0,   "I-type BEQ Taken 1");
      check_result_rf(5'd6, 700, "I-type BEQ Taken 2");
      reset();

      `RF_PATH.mem[1] = BR_NTAKEN_OP1[0];
      `RF_PATH.mem[2] = BR_NTAKEN_OP2[0];
      `RF_PATH.mem[3] = 300;
      `RF_PATH.mem[4] = 400;

      // Test branch not taken
      `IMEM_PATH.mem[INST_ADDR + 0]  = {`OPC_BEQ,  5'd2,  5'd1,  IMM[15:0]};
      `IMEM_PATH.mem[INST_ADDR + 1]  = {`OPC_ARI_RTYPE,  5'd3,  5'd4,  5'd5,  SHAMT,  `FNC_ADD};

      reset_cpu();
      check_result_rf(5'd5, 700, "I-type BEQ Not Taken");
end

if (1) begin
    // Test Hazards -------------------------------------------------------
    // ALU->ALU hazard (RS1)
    reset();
    init_rf();
    INST_ADDR = 14'h0000;
    `IMEM_PATH.mem[INST_ADDR + 0]  = {`OPC_ARI_RTYPE,  5'd1,  5'd2,  5'd3,  SHAMT,  `FNC_ADD};  //x3 <= x1 + x2
    `IMEM_PATH.mem[INST_ADDR + 1]  = {`OPC_ARI_RTYPE,  5'd3,  5'd4,  5'd5,  SHAMT,  `FNC_ADD};  //x5 <= x3 + x4
    reset_cpu();
    check_result_rf(5'd5, `RF_PATH.mem[1] + `RF_PATH.mem[2] + `RF_PATH.mem[4], "Hazard 1");

    // ALU->ALU hazard (RS2)
    reset();
    init_rf();
    INST_ADDR = 14'h0000;
    `IMEM_PATH.mem[INST_ADDR + 0]  = {`OPC_ARI_RTYPE,  5'd1,  5'd2,  5'd3,  SHAMT,  `FNC_ADD};  //x3 <= x1 + x2
    `IMEM_PATH.mem[INST_ADDR + 1]  = {`OPC_ARI_RTYPE,  5'd4,  5'd3,  5'd5,  SHAMT,  `FNC_ADD};  //x5 <= x4 + x3
    reset_cpu();
    check_result_rf(5'd5, `RF_PATH.mem[1] + `RF_PATH.mem[2] + `RF_PATH.mem[4], "Hazard 2");

    // Two-cycle ALU->ALU hazard (RS1)
    reset();
    init_rf();
    INST_ADDR = 14'h0000;
    `IMEM_PATH.mem[INST_ADDR + 0]  = {`OPC_ARI_RTYPE,  5'd1,  5'd2,  5'd3,  SHAMT,  `FNC_ADD};  //x3 <= x1 + x2
    `IMEM_PATH.mem[INST_ADDR + 1]  = {`OPC_ARI_RTYPE,  5'd4,  5'd5,  5'd6,  SHAMT,  `FNC_ADD};  //x6 <= x4 + x5
    `IMEM_PATH.mem[INST_ADDR + 2]  = {`OPC_ARI_RTYPE,  5'd3,  5'd7,  5'd8,  SHAMT,  `FNC_ADD};  //x8 <= x3 + x7
    reset_cpu();
    check_result_rf(5'd8, `RF_PATH.mem[1] + `RF_PATH.mem[2] + `RF_PATH.mem[7], "Hazard 3");

    // Two-cycle ALU->ALU hazard (RS2)
    reset();
    init_rf();
    INST_ADDR = 14'h0000;
    `IMEM_PATH.mem[INST_ADDR + 0]  = {`OPC_ARI_RTYPE,  5'd1,  5'd2,  5'd3,  SHAMT,  `FNC_ADD};  //x3 <= x1 + x2
    `IMEM_PATH.mem[INST_ADDR + 1]  = {`OPC_ARI_RTYPE,  5'd4,  5'd5,  5'd6,  SHAMT,  `FNC_ADD};  //x6 <= x4 + x5
    `IMEM_PATH.mem[INST_ADDR + 2]  = {`OPC_ARI_RTYPE,  5'd7,  5'd3,  5'd8,  SHAMT,  `FNC_ADD};  //x8 <= x7 + x3
    reset_cpu();
    check_result_rf(5'd8, `RF_PATH.mem[1] + `RF_PATH.mem[2] + `RF_PATH.mem[7], "Hazard 4");

    // Two ALU hazards
    reset();
    init_rf();
    INST_ADDR = 14'h0000;
    `IMEM_PATH.mem[INST_ADDR + 0]  = {`OPC_ARI_RTYPE,  5'd1,  5'd2,  5'd3,  SHAMT,  `FNC_ADD};  //x3 <= x1 + x2
    `IMEM_PATH.mem[INST_ADDR + 1]  = {`OPC_ARI_RTYPE,  5'd4,  5'd3,  5'd5,  SHAMT,  `FNC_ADD};  //x5 <= x4 + x3
    `IMEM_PATH.mem[INST_ADDR + 2]  = {`OPC_ARI_RTYPE,  5'd5,  5'd6,  5'd7,  SHAMT,  `FNC_ADD};  //x7 <= x5 + x6
    reset_cpu();
    check_result_rf(5'd7, `RF_PATH.mem[1] + `RF_PATH.mem[2] + `RF_PATH.mem[4] + `RF_PATH.mem[6], "Hazard 5");

    // ALU->MEM hazard
    reset();
    init_rf();
    `RF_PATH.mem[4] = 32'h3000_0100;
    //`RF_PATH.mem[4] = 32'h0000_0100;
    IMM             = 32'h0000_0000;
    INST_ADDR       = 14'h0000;
    DATA_ADDR       = (`RF_PATH.mem[4] + IMM[11:0]) >> 2;
    `IMEM_PATH.mem[INST_ADDR + 0]  = {`OPC_ARI_RTYPE,  5'd1,  5'd2,  5'd3,  SHAMT,  `FNC_ADD};  //add x3 <= x1 + x2
    `IMEM_PATH.mem[INST_ADDR + 1]  = {`OPC_SW,  5'd4,  5'd3,  IMM[15:0]};                       //sw r3 imm(r4)
    reset_cpu();
    check_result_dmem(DATA_ADDR, `RF_PATH.mem[1] + `RF_PATH.mem[2], "Hazard 6");

    // MEM->ALU hazard
    reset();
    init_rf();
    `RF_PATH.mem[1] = 32'h3000_0100;
    //`RF_PATH.mem[1] = 32'h0000_0100;
    IMM             = 32'h0000_0000;
    INST_ADDR       = 14'h0000;
    DATA_ADDR       = (`RF_PATH.mem[1] + IMM[11:0]) >> 2;
    `DMEM_PATH.mem[DATA_ADDR] = 32'h12345678;

    `IMEM_PATH.mem[INST_ADDR + 0]  = {`OPC_LW,  5'd1,  5'd2,  IMM[15:0]};                       //LW x2, r1(imm)
    `IMEM_PATH.mem[INST_ADDR + 1]  = {`OPC_ARI_RTYPE,  5'd2,  5'd3,  5'd4,  SHAMT,  `FNC_ADD};  //add x4 <= x2 + x3

    reset_cpu();
    check_result_rf(5'd4, `DMEM_PATH.mem[DATA_ADDR] + `RF_PATH.mem[3], "Hazard 7");

    // MEM->MEM hazard (store data)
    reset();
    init_rf();
    `RF_PATH.mem[1] = 32'h3000_0100;
    `RF_PATH.mem[4] = 32'h3000_0200;
    //`RF_PATH.mem[1] = 32'h0000_0100;
    //`RF_PATH.mem[4] = 32'h0000_0200;
    IMM             = 32'h0000_0000;
    INST_ADDR       = 14'h0000;

    DATA_ADDR0      = (`RF_PATH.mem[1] + IMM[11:0]) >> 2;
    DATA_ADDR1      = (`RF_PATH.mem[4] + IMM[11:0]) >> 2;
    `DMEM_PATH.mem[DATA_ADDR0] = 32'h12345678;

    `IMEM_PATH.mem[INST_ADDR + 0]  = {`OPC_LW,  5'd1,  5'd2,  IMM[15:0]};                       //LW x2, r1(imm)
    `IMEM_PATH.mem[INST_ADDR + 1]  = {`OPC_SW,  5'd4,  5'd2,  IMM[15:0]};                       //sw r2 imm(r4)

    reset_cpu();
    check_result_dmem(DATA_ADDR1, `DMEM_PATH.mem[DATA_ADDR0], "Hazard 8");


    // MEM->MEM hazard (store address)
    reset();
    init_rf();
    `RF_PATH.mem[1] = 32'h3000_0100;
    //`RF_PATH.mem[1] = 32'h0000_0100;
    IMM             = 32'h0000_0000;
    INST_ADDR       = 14'h0000;
    DATA_ADDR0      = (`RF_PATH.mem[1] + IMM[11:0]) >> 2;
    `DMEM_PATH.mem[DATA_ADDR0] = 32'h3000_0200;
    DATA_ADDR1      = (`DMEM_PATH.mem[DATA_ADDR0] + IMM[11:0]) >> 2;

    `IMEM_PATH.mem[INST_ADDR + 0]  = {`OPC_LW,  5'd1,  5'd2,  IMM[15:0]};                       //LW x2, r1(imm)
    `IMEM_PATH.mem[INST_ADDR + 1]  = {`OPC_SW,  5'd2,  5'd4,  IMM[15:0]};                       //sw r4 imm(r2)

    reset_cpu();
    check_result_dmem(DATA_ADDR1, `RF_PATH.mem[4], "Hazard 9"); //실제로 sw 끝나고 r2+imm 위치에 저장된 data와 r4 레지스터 값 비교하는거네


    // Hazard to Branch operands
    reset();
    //  init_rf();
    INST_ADDR = 14'h0000;
    IMM       = 32'h0000_0FF0;
    JUMP_ADDR = (32'h0001_000C + (IMM << 2)) >> 2; // note the PC address here

    `RF_PATH.mem[1]   = 100;
    `RF_PATH.mem[2]   = 200;
    `RF_PATH.mem[3]   = 300;
    `RF_PATH.mem[4]   = 400;
    `RF_PATH.mem[8]   = 800;
    `RF_PATH.mem[9]   = 900;
    `RF_PATH.mem[10]  = 1000;

    `IMEM_PATH.mem[INST_ADDR + 0]  = {`OPC_ARI_RTYPE,  5'd1,  5'd4,  5'd6,  SHAMT,  `FNC_ADD};  //add x6 <= x1 + x4
    `IMEM_PATH.mem[INST_ADDR + 1]  = {`OPC_ARI_RTYPE,  5'd3,  5'd2,  5'd7,  SHAMT,  `FNC_ADD};  //add x7 <= x3 + x2
    `IMEM_PATH.mem[INST_ADDR + 2]  = {`OPC_BEQ,  5'd6,  5'd7,  IMM[15:0]};                      //beq x6, x7, imm
    `IMEM_PATH.mem[INST_ADDR + 3]  = {`OPC_ARI_RTYPE,  5'd9,  5'd8,  5'd10, SHAMT,  `FNC_ADD};  //add x10 <= x9 + x8
    `IMEM_PATH.mem[JUMP_ADDR[13:0]]= {`OPC_ARI_RTYPE,  5'd9,  5'd8,  5'd11, SHAMT,  `FNC_SUB};  //sub r11 <= r9 - r8

    reset_cpu();
    check_result_rf(5'd10, `RF_PATH.mem[10], "Hazard 10 1"); // x10 should not be updated
    check_result_rf(5'd11, `RF_PATH.mem[9] - `RF_PATH.mem[8], "Hazard 10 2"); // x11 should be updated

 end

    // ... what else?
    all_tests_passed = 1'b1;

    repeat (100) @(posedge clk);
    $display("All tests passed!");
    $finish();
  end

endmodule
