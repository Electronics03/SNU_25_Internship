set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { clk }];
# clk pin : E3
# 100 MHz

## Reset (임의 버튼/핀에 맞게 조정)
set_property -dict { PACKAGE_PIN C12 IOSTANDARD LVCMOS33 } [get_ports { rst }]

set_property -dict { PACKAGE_PIN C4 IOSTANDARD LVCMOS33 } [get_ports { rxd }];
set_property -dict { PACKAGE_PIN D4 IOSTANDARD LVCMOS33 } [get_ports { txd }];
# rx pin : C4
# tx pin : D4