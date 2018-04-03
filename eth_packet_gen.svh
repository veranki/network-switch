// packet generator class
typedef eth_packet_c;
class eth_packet_gen_c;
	int num_pkts;
	mailbox mbx_out;
	function new (mailbox mbx);
		mbx_out=mbx;
	endfunction
	task run;
		eth_pkt_c pkt;
		num_pkts=2;
		for(i=0;i<num_pkts;i++)
			begin
				pkt=new();
				`ifdef no_randomize
		pkt.build_custom_random();
		`else
				assert(pkt.randomize());
				`endif
				mbx_out.put(pkt);
			end
	endtask
endclass