module fifo(
	input logic clk,
	input logic rst,
	input logic read_en,
	input logic write_en,
	input logic [FIFO_WIDTH-1:0] data_in,
	output logic [FIFO_DEPTH-1:0] data_out,
	output logic empty,
	output logic full);

	parameter FIFO_WIDTH=8;
	parameter FIFO_DEPTH=16;
	logic [FIFO_WIDTH-1:0]ram[0:FIFO_DEPTH];
	logic tmp_empty;
	logic tmp_full;
	integer write_ptr;
	integer read_ptr;

	assign empty=tmp_empty;
	assign full=tmp_full;

	always @(posedge clk or negedge rst)
	begin
		if(!rst)
			begin
				data_out=0;
				tmp_empty=1'b1;
				tmp_full=1'b0;
				write_ptr=0;
				read_ptr=0;
			end
		else
			begin
				if((write_en==1'b1) && (tmp_full==1'b0))
					begin
						ram[write_ptr] <= data_in;
						tmp_empty <= 1'b0;
						write_ptr <= (write_ptr+1) % FIFO_DEPTH;
						if(read_ptr==write_ptr)
							begin
								tmp_full <= 1'b1;
							end
					end
				if((read_en==1'b1) && (tmp_empty==1'b0))
					begin
						data_out <= ram[read_ptr];
						tmp_full <= 1'b0;
						read_ptr <= (read_ptr+1) % FIFO_DEPTH;
						if(read_ptr==write_ptr)
							begin
								tmp_empty <= 1'b1;
							end
					end
			end
	end
endmodule
