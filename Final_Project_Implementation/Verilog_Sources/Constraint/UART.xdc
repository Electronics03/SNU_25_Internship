set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports { clk }]
create_clock -add -name sys_clk_pin -period 10.000 [get_ports { clk }]

set_property -dict { PACKAGE_PIN C12 IOSTANDARD LVCMOS33 } [get_ports { rst }]

set_property -dict { PACKAGE_PIN C4 IOSTANDARD LVCMOS33 } [get_ports { rxd }]
set_property -dict { PACKAGE_PIN D4 IOSTANDARD LVCMOS33 } [get_ports { txd }]