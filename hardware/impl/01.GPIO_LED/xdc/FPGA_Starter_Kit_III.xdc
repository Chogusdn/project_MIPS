#Clock Signal
set_property -dict { PACKAGE_PIN R4  IOSTANDARD LVCMOS33} [get_ports { CLOCK_100 }]; 
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { CLOCK_100 }];

#RESET SW
set_property -dict { PACKAGE_PIN U7   IOSTANDARD LVCMOS33 } [get_ports { BUTTON }];

#LEDs
set_property -dict { PACKAGE_PIN Y18   IOSTANDARD LVCMOS33 } [get_ports { LED[0] }];
set_property -dict { PACKAGE_PIN AA18  IOSTANDARD LVCMOS33 } [get_ports { LED[1] }];
set_property -dict { PACKAGE_PIN AB18  IOSTANDARD LVCMOS33 } [get_ports { LED[2] }];
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports { LED[3] }];
set_property -dict { PACKAGE_PIN Y19   IOSTANDARD LVCMOS33 } [get_ports { LED[4] }];
set_property -dict { PACKAGE_PIN AA19  IOSTANDARD LVCMOS33 } [get_ports { LED[5] }];
set_property -dict { PACKAGE_PIN W20   IOSTANDARD LVCMOS33 } [get_ports { LED[6] }];
set_property -dict { PACKAGE_PIN AA20  IOSTANDARD LVCMOS33 } [get_ports { LED[7] }];
set_property -dict { PACKAGE_PIN AB20  IOSTANDARD LVCMOS33 } [get_ports { LED[8] }];
set_property -dict { PACKAGE_PIN W21   IOSTANDARD LVCMOS33 } [get_ports { LED[9] }];

#7-Segment
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { HEX[0] }];
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports { HEX[1] }];
set_property -dict { PACKAGE_PIN W17   IOSTANDARD LVCMOS33 } [get_ports { HEX[2] }];
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { HEX[3] }];
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports { HEX[4] }];
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { HEX[5] }];
set_property -dict { PACKAGE_PIN V18   IOSTANDARD LVCMOS33 } [get_ports { HEX[6] }];
set_property -dict { PACKAGE_PIN P19   IOSTANDARD LVCMOS33 } [get_ports { HEX[7] }];

set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { HEX_DIGIT[0] }];
set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports { HEX_DIGIT[1] }];
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { HEX_DIGIT[2] }];
set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { HEX_DIGIT[3] }];

