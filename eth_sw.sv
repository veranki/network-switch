module eth_sw(
	input clk,
	input rst,
	input [31:0] in_data_a,
	input in_sop_a,
	input in_eop_a,
	input [31:0] in_data_b,
	input in_sop_b,
	input in_eop_b,
	output reg [31:0] out_data_a,
	output reg out_sop_a,
	output reg out_eop_a,
	output reg [31:0] out_data_b,
	output reg out_sop_b,
	output reg out_eop_b,
	output reg a_stall,
	output reg b_stall
	);

	parameter a_addr='habcd;
	parameter b_addr='hcdef;

	// generate signals for fifo
	wire [33:0] fifo_wr_data[2];
	wire [33:0] fifo_rd_data[2];
	wire fifo_empty[2];
	wire fifo_full[2];
	wire fifo_wr_en[2];
	reg fifo_rd_en[2];

	// instantiate fifos as buffers for each port
	fifo #(.FIFO_WIDTH(34),.FIFO_DEPTH(32)) in_a_queue (
		.clk(clk),
		.rst(rst),
		.read_en(fifo_rd_en[0]),
		.write_en(fifo_wr_en[0]),
		.data_in(fifo_wr_data[0]),
		.data_out(fifo_rd_data[0]),
		.empty(fifo_empty[0]),
		.full(fifo_full[0])
	);

	fifo #(.FIFO_WIDTH(34),	.FIFO_DEPTH(32)	) in_b_queue (
		.clk(clk),
		.rst(rst),
		.read_en(fifo_rd_en[1]),
		.write_en(fifo_wr_en[1]),
		.data_in(fifo_wr_data[1]),
		.data_out(fifo_rd_data[1]),
		.empty(fifo_empty[1]),
		.full(fifo_full[1])
	);

	// fsm for decoding packets and saving in output buffers(fifos)
	eth_fsm port_a_fsm (
		.rst(rst),
		.clk(clk),
		.in_data(in_data_a),
		.in_sop(in_sop_a),
		.in_eop(in_eop_a),
		.out_wr_en(fifo_wr_en[0]),
		.out_data(fifo_wr_data[0])
	);

	eth_fsm port_b_fsm (
		.rst(rst),
		.clk(clk),
		.in_data(in_data_b),
		.in_sop(in_sop_b),
		.in_eop(in_eop_b),
		.out_wr_en(fifo_wr_en[1]),
		.out_data(fifo_wr_data[1])
	);

	// other temporary signals
	reg read_fifo_head[2];
	reg read_fifo_data[2];
	reg port_busy[2];
	reg [1:0] dest_port[2];

	//
	always @(posedge clk) begin
		if(!rst)
			begin
				for(int i=0;i<2;i++)
					begin
						read_fifo_head[i] <= 1'b1;
						read_fifo_data[i] <= 1'b0;
						dest_port[i] <= 'b11; // invalid
						port_busy[i]='b0;
					end
				out_data_a <= 'x;
				out_data_b <= 'x;
				out_sop_a <= 'b0;
				out_sop_b <= 'b0;
				out_eop_a <= 'b0;
				out_eop_b <= 'b0;
			end
		else
			begin
				out_sop_a <= 'b0;
				out_sop_b <= 'b0;
				out_eop_a <= 'b0;
				out_eop_b <= 'b0;
				for(int i=0;i<2;i++)
					begin
						if(read_fifo_head[i] && !fifo_empty[i])
							begin
								fifo_rd_en[i] <= 1'b1;
								read_fifo_head[i] <= 1'b0;
								read_fifo_data[i] <= 1'b1;
							end
						else if(read_fifo_head[i] && !fifo_full[i])
							begin
								if(fifo_rd_data[i][32])
									begin
										dest_port[i] <= (fifo_rd_data[i][31:0]==b_addr) ? 'b01:'b00;
										if(port_busy[dest_port[i]])
											fifo_rd_en[i] <= 'b1;
										else
											begin
												fifo_rd_en[i] <= 'b0;
												port_busy[dest_port[i]] <= 1'b1;
											end
									end
								else if(fifo_rd_data[i][33])
									begin
										fifo_rd_en[i]<= 1'b0;
										read_fifo_data[i] <= 1'b0;
										read_fifo_head[i] <= 1'b1;
										port_busy[dest_port[i]] <= 1'b0;
									end
								else
									fifo_rd_en[i] <= 'b1;
								if(dest_port[i]==0)
									begin
										out_data_a <= fifo_rd_data[i][31:0];
										out_sop_a <= fifo_rd_data[i][32];
										out_sop_a <= fifo_rd_data[i][33];
									end
								if(dest_port[i]==1)
									begin
										out_data_b <= fifo_rd_data[i][31:0];
										out_sop_b <= fifo_rd_data[i][32];
										out_sop_b <= fifo_rd_data[i][33];
									end
							end
					end
			end
	end

	always @(posedge clk) begin
		if(!rst)
			begin
				a_stall <= 0;
				b_stall <= 0;
			end
		else
			begin
				a_stall <= fifo_full[0];
				b_stall <= fifo_full[1];
			end
	end
endmodule
