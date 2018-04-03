typedef eth_packet_c;
class eth_packet_drv_c;
	virtual interface eth_sw_if rtl_int;
	mailbox mbx_input;
	function new(mailbox mbx,virtual interface eth_sw_if intf);
		mbx_input=mbx;
		this.rtl_intf=intf;
	endfunction

	task run;
		eth_packet_c pkt;
		forever begin
			mbx_input.get(pkt);
			$display("packet_drv::Got packet=%s",pkt.to_string());
			if(pkt.src_addr == a_addr) begin
				drive_pkt_port_a(pkt);
			end else if(pkt.src_addr == b_addr) begin
				drive_pkt_port_b(pkt);
			end else begin
				$display("Packets SRC neither A nor B and hence dropping");
			end
		end
	endtask

	task drive_pkt_port_a(eth_packet_c pkt);
		int count;
		int numDwords;
		bit[31:0] cur_dword;
		count=0;
		numDwords=pkt.pkt_size_bytes/4;
		$display("packet_drive::drive_pkt_port_a:numDwords=%0d",numDwords);
		forever@(posedge rtl_intf.clk) begin
			if(!rtl_int.a_stall) begin
				rtl_intf.eth_drv_cb.in_sop_a <= 1'b0;
				rtl_intf.eth_drv_cb.in_eop_a <= 1'b0;
				cur_dword[7:0]=pkt.pkt_full[4*count];
				cur_dword[15:8]=pkt.pkt_full[4*count+1];
				cur_dword[23:16]=pkt.pkt_full[4*count+2];
				cur_dword[31:2]=pkt.pkt_full[4*count+3];
				$display("time=%t packet_drv::drive_pkt_port_a:count=%0d cur_dword=%h",$time,count,cur_dword);
				if(count==0) begin
					rtl_intf.eth_drv_cb.in_sop_a <= 1'b1;
					rtl_intf.eth_drv_cb.in_data <= cur_dword;
					count=count+1;
				end else if (count==numDwords-1) begin
					rtl_intf.eth_drv_cb.in_eop_a <= 1'b1;
					rtl_intf.eth_drv_cb.in_data_a <= cur_word;
					count=count+1;
				end else if (count==numDwords) begin
					count=0;
					break;
				end else begin
					rtlj.inf.eth_drv_cb.in_data_a <= cur_dword;
					count=count+1;
				end
			end
		end
	endtask

	task drive_pkt_port_b(eth_packet_c pkt);
		int count;
		int numDwords;
		bit[31:0] cur_dword;
		count=0;
		numDwords=pkt.pkt_size_bytes/4;
		$display("packet_drive::drive_pkt_port_b:numDwords=%0d",numDwords);
		forever@(posedge rtl_intf.clk) begin
			if(!rtl_int.a_stall) begin
				rtl_intf.eth_drv_cb.in_sop_b <= 1'b0;
				rtl_intf.eth_drv_cb.in_eop_b <= 1'b0;
				cur_dword[7:0]=pkt.pkt_full[4*count];
				cur_dword[15:8]=pkt.pkt_full[4*count+1];
				cur_dword[23:16]=pkt.pkt_full[4*count+2];
				cur_dword[31:2]=pkt.pkt_full[4*count+3];
				$display("time=%t packet_drv::drive_pkt_port_b:count=%0d cur_dword=%h",$time,count,cur_dword);
				if(count==0) begin
					rtl_intf.eth_drv_cb.in_sop_b <= 1'b1;
					rtl_intf.eth_drv_cb.in_data <= cur_dword;
					count=count+1;
				end else if (count==numDwords-1) begin
					rtl_intf.eth_drv_cb.in_eop_b <= 1'b1;
					rtl_intf.eth_drv_cb.in_data_b <= cur_word;
					count=count+1;
				end else if (count==numDwords) begin
					count=0;
					break;
				end else begin
					rtlj.inf.eth_drv_cb.in_data_b <= cur_dword;
					count=count+1;
				end
			end
		end
	endtask
endclass