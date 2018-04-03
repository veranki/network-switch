// interface

interface eth_sw_if();
	input clk;
	input rst;
	input [31:0] in_data_a;
	input in_sop_a;
	input in_eop_a;
	input [31:0] in_data_b;
	input in_sop_b;
	input in_eop_b;
	input [31:0] out_data_a;
	input out_sop_a;
	input out_eop_a;
	input [31:0] out_data_b;
	input out_sop_b;
	input out_eop_b;
	input a_stall;
	input b_stall;

// clocking block of interface for monitor
	default clocking eth_mon_cb@(posedge clk);
	default input #2ns output #2ns;
	input clk;
	input rst;
	input in_data_a;
	input in_sop_a;
	input in_eop_a;
	input in_data_b;
	input in_sop_b;
	input in_eop_b;
	input out_data_a;
	input out_sop_a;
	input out_eop_a;
	input out_data_b;
	input out_sop_b;
	input out_eop_b;
	input a_stall;
	input b_stall;
	endclocking: eth_mon_cb

// modport of clocking block of interface for monitor
	modport monitor_mp(
	clocking eht_mon_cb
	);

// clocking block of interface for driver
	clocking eth_drv_cb@(posedge clk);
	default input #2ns output #2ns;
	input clk;
	input rst;
	output in_data_a;
	output in_sop_a;
	output in_eop_a;
	output in_data_b;
	output in_sop_b;
	output in_eop_b;
	endclocking

// modport of clocking block of interface for driver
	modport driver_mp(
	clocking eth_drv_cb
	);
endinterface;
