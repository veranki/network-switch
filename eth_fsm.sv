module eth_fsm(
	input rst,
	input clk,
	input [31:0] in_data,
	input in_sop,
	input in_eop,
	output reg out_wr_en, // assert when writing in output buffer
	output reg [33:0] out_data // 34 bits because start of packet and end of packet bits are appended
);

	parameter a_addr='habcd;
	parameter b_addr='hcdef;

	// declaring states for fsm
	typedef enum logic [2:0] {idle,addr_rcv,data_rcv,done}state;
	state pstate,nstate;

	// declaring auxillary registers for fsm
	reg [31:0] dst_addr;
	reg [31:0] src_addr;
	reg [33:0] data_word;
	reg in_sop_n;
	reg in_eop_n;
	reg [31:0] in_data_n;

	// sequential part of fsm, assign next state to present state and store values in auxillary register
	always @(posedge clk) begin
		pstate <= nstate;
		in_sop_n <= in_sop;
		in_eop_n <= in_eop;
		in_data_n <= in_data;
	end

	// combinational part of fsm
	always_comb begin
		case (pstate)
			idle :
			begin
				if(in_sop)
					begin
						dst_addr <= in_data;
						nstate <= addr_rcv;
					end
				else
					nstate <= idle;
			end
			addr_rcv :
			begin
				src_addr <= in_data;
				nstate <= data_rcv;
			end
			data_rcv :
			begin
				if(in_eop)
					nstate <= done;
				else
					nstate <= data_rcv;
			end
			done :
			nstate <= idle;
			default :
			nstate <= idle;
		endcase
	end

	// set other registers apart from fsm
	always @(posedge clk) begin
		if(!rst)
			begin
				out_wr_en <= 1'b0;
			end
		else
			begin
				if(pstate!=idle)
					begin
						out_wr_en <= 1'b1;
						out_data <= {in_eop_n,in_sop_n,in_data_n};
					end
				else
					begin
						out_wr_en <= 1'b0;
					end
			end
	end
endmodule
