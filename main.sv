
module stat_prj
#
(
	parameter A_WIDTH = 10,
	parameter D_WIDTH = 32
)
(
	input logic  clk_i,
	input logic  rst_i,
	input logic [A_WIDTH-1:0] rx_flow_num_i,
	input logic [15:0] pkt_size_i,
	input logic pkt_size_en_i,
	
	input logic rd_stb_i,
	input logic [A_WIDTH-1:0] rd_flow_num_i,
	output logic [D_WIDTH-1:0] rd_data_o,/*rd_data_o_2,*/
	output logic rd_data_val_o
);

logic [D_WIDTH-1:0] tmp;
bit we;

	// Declare the RAM variable
	reg [D_WIDTH-1:0] ram[2**A_WIDTH-1:0];

	// Port A 
	always_ff @ (posedge clk_i)
	begin
		if (pkt_size_en_i) 
		begin
			ram[rx_flow_num_i] <= pkt_size_i;
			rd_data_o <= pkt_size_i;
		end
		else 
		begin
			rd_data_o <= ram[rx_flow_num_i];
		end 
	end 

	// Port B 
	always_ff @ (posedge clk_i)
	begin
		logic [D_WIDTH-1:0] rd_data_o_2;
		if (rd_stb_i) 
		begin
			ram[rd_flow_num_i] <= 0;
			rd_data_o_2 <= 0;
		end
		else 
		begin
			rd_data_o_2 <= ram[rd_flow_num_i];
		end 
	end
																	

endmodule

// Quartus II Verilog Template
// Simple Dual Port RAM with separate read/write addresses and
// single read/write clock

module simple_dual_port_ram_single_clock
#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=6)
(
	input [(DATA_WIDTH-1):0] data,
	input [(ADDR_WIDTH-1):0] read_addr, write_addr,
	input we, clk,
	output reg [(DATA_WIDTH-1):0] q
);

	// Declare the RAM variable
	

endmodule


//****************************************************************
//                  The testbench
//****************************************************************


module testbench
#
(
	parameter A_WIDTH = 4,
	parameter D_WIDTH = 32
);

	logic  clk_i, rst_i;
	logic [A_WIDTH-1:0] rx_flow_num_i = 10'b0000000100;
	logic [15:0] pkt_size_i = 0;
	logic pkt_size_en_i;
	
	logic rd_stb_i;
	logic [A_WIDTH-1:0] rd_flow_num_i;
	logic [D_WIDTH-1:0] rd_data_o, rd_data_o_2;
	logic rd_data_val_o;
	
  stat_prj #(.A_WIDTH(A_WIDTH), .D_WIDTH(D_WIDTH)) DUT(.* , .rst_i(1'b0));


bit [A_WIDTH-1:0] count, count2, count3;

initial begin clk_i = 1'b0;
forever #50 clk_i = !clk_i;
end

always_ff @(posedge clk_i) begin
  if (clk_i)
    begin
      
      if(count<=5)
       begin
        pkt_size_en_i <= 1;
        pkt_size_i    <= ++count;     
        rx_flow_num_i <= count;
       end
        else
          begin
            count <= 0;
            count2++;
            pkt_size_en_i <= 0;
          end
          
      if(count2 == 2)    
        if(count==3) begin
          rd_stb_i <= 1;
          rd_flow_num_i <= 3;
        end
        else if(count==5) begin
           rd_stb_i <= 1;
           rd_flow_num_i <= 5;
        end 
       else
        begin
         rd_stb_i <= 0;
         rd_flow_num_i <= 0;
        end 
       
      if(count2 == 4)    
        if(count==3) begin
          rd_stb_i <= 1;
          rd_flow_num_i <= 3;
        end
        else if(count==5) begin
           rd_stb_i <= 1;
           rd_flow_num_i <= 5;
        end 
       else
        begin
         rd_stb_i <= 0;
         rd_flow_num_i <= 0;
        end 

         
     end    
end

endmodule

