
//  This code references EECS151 in UCB.

module MIPS_System(
  input         CLOCK_100,
  input         BUTTON,
  output  [7:0] HEX,
  output  [3:0] HEX_DIGIT,
  output  [9:0] LED
);

  parameter MIF_HEX       ="code.hex";
  parameter RESET_PC      = 32'h0001_0000;
  parameter DWIDTH        = 32;
  parameter AWIDTH        = 12;

  wire          clk;
  wire          reset;
  reg           reset_ff;
  wire [31:0]   fetch_addr;
  wire [31:0]   inst;
  wire [31:0]   imem_inst;
  wire [31:0]   data_addr;
  wire [31:0]   write_data;
  wire [31:0]   read_data;
  wire          data_we;

  assign  clk = CLOCK_100;
  assign  reset = BUTTON;

  always @(posedge clk)
    reset_ff <= reset;

  assign inst = (reset_ff)? imem_inst: 32'h0;

	MIPS_cpu #(
      .RESET_PC(RESET_PC)
  ) icpu (
		.clk			  (clk), 
		.rst_n		  (reset_ff),     //negedge reset
		.pc			    (fetch_addr),
		.inst		  	(inst),

		.MemWrite   (data_we),      // data_we: active high
		.MemAddr		(data_addr), 
		.MemWData	  (write_data),
		.MemRData	  (read_data)
  );


  ASYNC_RAM_DP #(
      .DWIDTH   (DWIDTH),
      .AWIDTH   (AWIDTH),
      .MIF_HEX  (MIF_HEX)
  ) imem (
    .clk      (clk),
    //IM  - Read Only
    .addr0    (fetch_addr [AWIDTH+1:2]),    //12-bit (match with mem width)
    .we0      (1'b0),                       //write enable
    .d0       (32'd0),                      //write data
    .q0       (imem_inst),                  //read inst

    //DM  - Read / Write
    .addr1    (data_addr  [AWIDTH+1:2]),
    .we1      (data_we),                    //wirte enable 
    .d1       (write_data),                 //write data
    .q1       (read_data)                   //read data
  );
 
 /******************************************************************************/
 
                         /***  Peripheral Device ***/

  reg cs_gpio;

  //addr_decoder
  always @(*) begin
    if  (data_addr[15:8] == 8'h20)  // LED, SEGMENT(GPIO)
      cs_gpio  = 1'b1;
    else 
      cs_gpio  = 1'b0;
  end


  GPIO u_GPIO (
    .clk        (clk),
    .rst_n      (reset_ff),
    .CS_N       (cs_gpio),
    .WR_N       (data_we),
    .Addr       (data_addr[11:0]),
    .DataIn     (write_data),
    .HEX        (HEX),
    .HEX_DIGIT  (HEX_DIGIT),
    .LED        (LED)
  );
 
endmodule
