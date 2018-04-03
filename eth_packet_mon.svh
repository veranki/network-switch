class eth_packet_mon_c;
	virtual interface eth_sw_if rtl_intf;
	mailbox mbx_out[4];
	function new(mailbox mbx[4],virtual interface eth_sw_if rtl_intf);
		this.mbx_out=mbx;
		this.rtl_intf=rtl_intf;
	endfunction
	task run;
		fork
			sample_port_a_input_pkt();
			sample_port_a_output_pkt();
			sample_port_b_input_pkt();
			sample_port_b_output_pkt();
		join
	endtask
	task sample_port_a_input_pkt();
		eth_packet_c pkt;
		int count;
		count=0;
		forever@(posedge rtl_intf.clk) begin
			if(rtl_intf.eth_mon_cb.in_sop_a) begin
				$display("time=%t packet_mon::seeing SOP on PortA",$time);
				pkt=new();
				count=1;
				pkt.dst_addr=rtl_intf.eth_mon_cb.in_data_a;
			end else if (count==1) begin
				pkt.src_addr=rtl_intf.eth_mon_cb.in_data_a;
				count++;
			end else if (rtl.intf.eth_mon_cb.in_eop_a) begin
				pkt.pkt_crc=rtl.intf.eth_mon_cb_in_data_a;
				$display("time=%0t packet_mon: Saw packet on PortA input: pkt=%s", $time,pkt.to_string());
				mbx_out[0].put(pkt);
				count=0;
			end else if(count>0) begin
				pkt.pkt_data.push_back(rtl_intf.eth_mon_cb.in_data_a);
				count++;
			end
		end
	endtask
	task sample_port_a_output_pkt();
		eth_pkt_c pkt;
		int count;
		count=0;
		forever@(posedge rtl_intf.clk) begin
			if(rtl_intf.eth_mon_cb.in_sop_b) begin
				$display("time=%t packet_mon::seeing Sop on Port A output",$time);
				pkt=new();
				count=1;
				pkt.dst_addr=rtl.intf.eth_packet_mon_cb.out_data_a;
			end else if (count==1) begin
				pkt.src_addr=rtl.intf.eth_packet_mon_cb.out_data_a;
				count++;
			end else if(rtl.intf.eth_mon_cb.out_data_a) begin
				pkt.pkt_crc=rtl_intf.eth_mon_cb.out_data_a;
				$display("time=0%t packet_mon: Saw packet on Port A output: pkt=%s",$time,pkt.to_string());
				mbx_out[2].put(pkt);
				count=0;
			end else if (count>0) begin
				pkt.pkt_data.push_back(rtl.intf.eth_mon_cb.out_data_a);
				count++;
			end
		end
	endtask

	task sample_port_b_input_pkt();
		eth_packet_c pkt;
		int count;
		count=0;
		forever@(posedge rtl_intf.clk) begin
			if(rtl_intf.eth_mon_cb.in_sop_b) begin
				$display("time=%t packet_mon::seeing SOP on PortA",$time);
				pkt=new();
				count=1;
				pkt.dst_bddr=rtl_intf.eth_mon_cb.in_data_b;
			end else if (count==1) begin
				pkt.src_bddr=rtl_intf.eth_mon_cb.in_data_b;
				count++;
			end else if (rtl.intf.eth_mon_cb.in_eop_b) begin
				pkt.pkt_crc=rtl.intf.eth_mon_cb_in_data_b;
				$display("time=%0t packet_mon: Saw packet on PortA input: pkt=%s", $time,pkt.to_string());
				mbx_out[0].put(pkt);
				count=0;
			end else if(count>0) begin
				pkt.pkt_data.push_back(rtl_intf.eth_mon_cb.in_data_b);
				count++;
			end
		end
	endtask
	task sample_port_b_output_pkt();
		eth_pkt_c pkt;
		int count;
		count=0;
		forever@(posedge rtl_intf.clk) begin
			if(rtl_intf.eth_mon_cb.in_sop_b) begin
				$display("time=%t packet_mon::seeing Sop on Port A output",$time);
				pkt=new();
				count=1;
				pkt.dst_bddr=rtl.intf.eth_packet_mon_cb.out_data_b;
			end else if (count==1) begin
				pkt.src_bddr=rtl.intf.eth_packet_mon_cb.out_data_b;
				count++;
			end else if(rtl.intf.eth_mon_cb.out_data_b) begin
				pkt.pkt_crc=rtl_intf.eth_mon_cb.out_data_b;
				$display("time=0%t packet_mon: Saw packet on Port A output: pkt=%s",$time,pkt.to_string());
				mbx_out[2].put(pkt);
				count=0;
			end else if (count>0) begin
				pkt.pkt_data.push_back(rtl.intf.eth_mon_cb.out_data_b);
				count++;
			end
		end
	endtask
endclass
