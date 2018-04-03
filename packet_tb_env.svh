// package for top level env class
package packet_tb_env_pkg;
	`define numports 2
	`define a_addr 'habcd
	`define b_addr 'hcdef
	
	// include env components
	`include "eth_packet.svh"
	`include "eth_packet_gen.svh"
	`include "eth_packet_drv.svh"
	`include "eth_packet_mon.svh"
	`include "eth_packet_chk.svh"

	// top level env class
	class packet_tb_env_c;
		string env_name;
		eth_packet_gen_c packet_gen;
		eth_packet_drv_c packet_driver;
		eth_packet_mon_c packet_mon;
		eth_packet_chk_c packet_checker;

		// mailboxes for  connectivity
		mailbox mbx_gen_drv; // gen to driver connectivity
		mailbox mbx_mon_chk[4]; // monitor to checker connectivity
		
		virtual interface eth_sw_if rtl_intf; // virtual interface
		
		// constructor
		function new(string name, virtual interface eth_sw_if intf);
			this.env_name=name;
			this.rtl_intf=intf;
			// create mailbox instances
			mbx_gen_drv=new();
			packet_gen=new(mbx_gen_drv);
			packet_driver=new(mbx_gen_drv,intf);
			for(int i=0;i<4;i++) begin
				mbx_mon_chk[i]=new();
				$display("create mailbox=%d for mon-check",i);
			end
			packet_mon=new(mbx_mon_chk,intf);
			// create checker instance and pass monitor mailboxes
			packet_checker=new(mbx_mon_chk);
		endfunction

		// main evaluation method
		task run();
			$display("packet_tb_env::run() called");
			// fork all component run
			fork
				packet_gen.run();
				packet_driver.run();
				packet_mon.run();
				packet_checker.run();
			join
		endtask
	endclass
endpackage
