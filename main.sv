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
	output logic [D_WIDTH-1:0] rd_data_o,
	output logic rd_data_val_o	
);


//Define memory storage
bit [D_WIDTH-1:0] mem [int'(2'b10<<(A_WIDTH-1))-1:0];



//****************************************************************
//     Finite State machine for writing: Next State assigning
//****************************************************************

bit tmp;

always_ff @(posedge clk_i or negedge rst_i) begin
    if (!rst_i) 
      begin
        if(pkt_size_en_i)
          begin
           //mem_read = mem[int'(rx_flow_num_i)];
           mem[int'(rx_flow_num_i)] = mem[int'(rx_flow_num_i)] + pkt_size_i;
          end
        //else mem[int'(rx_flow_num_i)] <= mem[int'(rx_flow_num_i)];
          
        if(rd_stb_i) 
          begin
            rd_data_val_o <= 1;
            rd_data_o = mem[rd_flow_num_i];
            mem[rd_flow_num_i] = 0;
          end
        else 
          begin 
            rd_data_val_o <= 0;
            rd_data_o <= 0;
          end
          
      end    
    else 
      begin
            rd_data_val_o <= 0;
            rd_data_o <= 0;
            mem[int'(rx_flow_num_i)] = mem[int'(rx_flow_num_i)];
      end   
end

/*always_ff @(negedge clk_i) begin
			if(!clk_i)if(rd_data_val_o)
			  begin
			     mem[rd_flow_num_i] <= 0;
			     tmp = !tmp;
		 end
end*/
endmodule


//****************************************************************
//                  The testbench
//****************************************************************


module testbench
#
(
	parameter A_WIDTH = 10,
	parameter D_WIDTH = 32
);

	logic  clk_i, rst_i;
	logic [A_WIDTH-1:0] rx_flow_num_i = 10'b0000000100;
	logic [15:0] pkt_size_i = 0;
	logic pkt_size_en_i;
	
	logic rd_stb_i;
	logic [A_WIDTH-1:0] rd_flow_num_i;
	logic [D_WIDTH-1:0] rd_data_o;
	logic rd_data_val_o;	 

  stat_prj #(.A_WIDTH(A_WIDTH), .D_WIDTH(D_WIDTH), .FIFO_WIDTH(20)) DUT(.* , .rst_i(1'b0));


bit [A_WIDTH-1:0] count, count2, count3;

initial begin clk_i = 1'b0;
forever #50 clk_i = !clk_i;
end

always_ff @(posedge clk_i) begin
  if (clk_i)
    begin
      
      if(count<=2'b10<<A_WIDTH-4)
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





