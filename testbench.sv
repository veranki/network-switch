// Top Module

module testbench;
	reg clk;
	reg rst;
	wire [31:0] in_data_a;
	wire in_sop_a;
	wire in_eop_a;
	wire [31:0] in_data_b;
	wire in_sop_b;
	wire in_eop_b;
	wire [31:0] out_data_a;
	wire out_sop_a;
	wire out_eop_a;
	wire [31:0] out_data_b;
	wire out_sop_b;
	wire out_eop_b;
	wire a_stall;
	wire b_stall;

	// instantiate DUT
	eth_sw eth_sw_instance (
		.clk(clk),
		.rst(rst),
		.in_data_a(in_data_a),
		.in_sop_a(in_sop_a),
		.in_eop_a(in_eop_a),
		.in_data_b(in_data_b),
		.in_sop_b(in_sop_b),
		.in_eop_b(in_eop_b),
		.out_data_a(out_data_a),
		.out_sop_a(out_sop_a),
		.out_eop_a(out_eop_a),
		.out_data_b(out_data_b),
		.out_sop_b(out_sop_b),
		.out_eop_b(out_eop_b),
		.a_stall(a_stall),
		.b_stall(b_stall)
	);
endmodule