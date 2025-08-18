set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk}];

set_property -dict { PACKAGE_PIN <PIN_UART_RX> IOSTANDARD LVCMOS33 } [get_ports uart_rx_i];
set_property PULLUP true [get_ports uart_rx_i];

set_property -dict { PACKAGE_PIN <PIN_UART_TX> IOSTANDARD LVCMOS33 } [get_ports uart_tx_o];
set_property DRIVE 8 [get_ports uart_tx_o];
set_property SLEW FAST [get_ports uart_tx_o];

set_property -dict { PACKAGE_PIN <PIN_LED0> IOSTANDARD LVCMOS33 } [get_ports busy_o];