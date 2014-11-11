`include "packages.sv"
`include "buses.sv"

module stat
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

//****************************************************************
//                Inclide external modules
//****************************************************************
`include "memory.sv"
`include "fifo.sv"

//****************************************************************
//                  Importing defenitions
//****************************************************************
import definitions_main::*;
import definitions_bus::*;

//****************************************************************
//                     Buses connection
//****************************************************************
main_bus  #(.A_WIDTH(A_WIDTH),.D_WIDTH(D_WIDTH)) bus(.clk_i, .rst_i, .rd_data_o);

//****************************************************************
//                     Some local defs
//****************************************************************
states_write next_state_wr_t, state_wr_t; 
states_read  next_state_r_t, state_r_t; 

StatesBusWrite NextStatesBusWrite, CurrentStatesBusWrite;
StatesBusRead NextStatesBusRead, CurrentStatesBusRead;


//****************************************************************
//                   Define memory block
//****************************************************************
mem  #(.A_WIDTH(A_WIDTH), .D_WIDTH(D_WIDTH), .FIFO_WIDTH(10)) mem_unit(.bus);



//****************************************************************
//
//
//            Finite State machine for writing
//
//
//****************************************************************

//****************************************************************
//     Finite State machine for writing: Next State assigning
//****************************************************************
always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        state_wr_t <= IDLE_WRITE;
        CurrentStatesBusWrite <= '{0,0,0,0};
    end
      else begin
        state_wr_t <= next_state_wr_t;
        CurrentStatesBusWrite<=NextStatesBusWrite;
    end
end


//****************************************************************
//   Finite State machine for writing: Next State Logic
//****************************************************************
always_comb begin : set_next_state_write 
next_state_wr_t = state_wr_t;
NextStatesBusWrite = CurrentStatesBusWrite;
     unique case(state_wr_t)
      IDLE_WRITE:
           begin
              //Wait for data come in
				      if(pkt_size_en_i) 
				        begin
				           next_state_wr_t = IDLE_WRITE;
				           //Envoke FIFO writer in the memory.sv :: FSM for writing mem 
				           NextStatesBusWrite = '{1'b1, 1'b0 ,rx_flow_num_i, pkt_size_i};
				        end
				        //Else, wait for valid data in 
				        else NextStatesBusWrite = '{0'b1,1'b0 ,rx_flow_num_i, pkt_size_i};
				        
				        //This data comes from the arbiter and states whether the current mem adress free or not
				        //If blocked then do nothing. Else retrive the existing data from specified 
				        //memory cell to add upcoming data with existing    
				        //if(bus.BusStateWrite.blocked == UNBLOCKED) next_state_wr_t = READ_WR_MEM;
                //else next_state_wr_t = IDLE_WR_MEM;  				          
           end
     // READ_WR_MEM:
     //       begin
     //         NextStatesBusWrite = '{0'b0, 1'b1 ,rx_flow_num_i, pkt_size_i};
		//		      next_state_wr_t = IDLE_WRITE; 
    //        end          
    endcase 
end:set_next_state_write 


//****************************************************************
//      Finite State machine for writing: Output logic
//****************************************************************
always_comb begin:set_outputs_write
bus.BusStateWrite = '{0,0,0,0};
     unique case(state_wr_t)
      IDLE_WRITE:
            begin
              bus.BusStateWrite = CurrentStatesBusWrite;
            end
      endcase 
end:set_outputs_write 


//****************************************************************
//
//
//            Finite State machine for reading
//
//
//****************************************************************


//****************************************************************
//    Finite State machine for reading: Next State assigning
//****************************************************************
always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        state_r_t <= IDLE_READ;
        CurrentStatesBusRead <= '{0,0};
    end
      else begin
        state_r_t <= next_state_r_t;
        CurrentStatesBusRead <=NextStatesBusRead;
    end
end


//****************************************************************
//         Finite State machine for reading: Next State Logic
//****************************************************************
always_comb begin:set_next_state_read  
 NextStatesBusRead = CurrentStatesBusRead;  
 next_state_r_t = state_r_t;
     unique case(state_r_t)
      IDLE_READ:
           begin
				      if(rd_stb_i) begin
				        next_state_r_t = READ_M;				        
				      end
				      else NextStatesBusRead = '{1'b0, rd_flow_num_i}; 
           end
      READ_M:
            begin
              NextStatesBusRead = '{1'b1, rd_flow_num_i};  
				      next_state_r_t = IDLE_READ; 
            end        
    endcase 
end:set_next_state_read 


//****************************************************************
//          Finite State machine for reading: Output logic
//****************************************************************
always_comb begin:set_outputs_read 
 bus.BusStateRead = '{0,0};

     unique case(state_r_t)
      READ_M:
        begin
            rd_data_val_o = 0; 
            bus.BusStateRead = CurrentStatesBusRead;     
        end      
    endcase 
end:set_outputs_read 



endmodule


//****************************************************************
//                  The testbench
//****************************************************************


module testbench
#
(
	parameter A_WIDTH = `A_W,
	parameter D_WIDTH = `D_W
);

	logic  clk_i, rst_i;
	logic [A_WIDTH-1:0] rx_flow_num_i = 10'b0000000100;
	logic [15:0] pkt_size_i = 0;
	logic pkt_size_en_i;
	
	logic rd_stb_i;
	logic [A_WIDTH-1:0] rd_flow_num_i;
	logic [D_WIDTH-1:0] rd_data_o;
	logic rd_data_val_o;	 

  stat #(.A_WIDTH(A_WIDTH), .D_WIDTH(D_WIDTH)) DUT  (.* , .rst_i(1'b0));


bit [A_WIDTH-1:0] count, count2;
initial begin
clk_i = 1'b0;
pkt_size_en_i = 1'b0; 
rd_stb_i = 1'b0;
forever  
  begin 
   #50
   count2 = 2'b10<<A_WIDTH-4; 
   clk_i = !clk_i;
   pkt_size_en_i = !pkt_size_en_i;
   rd_stb_i = !rd_stb_i;
   if (clk_i)
    if(count<=count2)
      begin 
       pkt_size_i = ++count;     
       rx_flow_num_i = count;
       rd_flow_num_i = count;
      end
     else count = 0;
  end
end

endmodule




