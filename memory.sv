`ifndef DEFS_MEM // if the already-compiled flag is not set...
  `define DEFS_MEM // set the flag

`include "packages.sv"
`include "buses.sv"


module mem
#
(
	parameter A_WIDTH = 10,
	parameter D_WIDTH = 32,
	parameter FIFO_WIDTH = 10
)
(main_bus bus);

//****************************************************************
//                 Importing defenitions
//****************************************************************
import definitions_mem::*;
import definitions_bus::*;

//****************************************************************
//                    Some local defs
//****************************************************************
states_mem_write next_state_wr_mem_t, state_wr_mem_t;
states_mem_read  next_state_r_mem_t,  state_r_mem_t; 
//states_r next_state_r_t, state_r_t; 

//defenitions for fifo
logic                         wr_en_data, rd_en_data, wr_en_ptr, rd_en_ptr ;   
// reset, system clock, write enable and read enable.
logic [D_WIDTH-1:0]           buf_in_data,buf_in_ptr;                   
// data input to be pushed to buffer
logic [D_WIDTH-1:0]           buf_out_data,buf_out_ptr;                  
// port to output the data using pop.
bit                        buf_empty_data, buf_full_data,buf_empty_ptr, buf_full_ptr;      
// buffer empty and full indication 
logic [FIFO_WIDTH-1:0]        fifo_counter_data,fifo_counter_ptr;             
// number of data pushed in to buffer  


//Define memory storage
logic [D_WIDTH-1:0] mem [int'(2'b10<<(A_WIDTH-1))-1:0];


//****************************************************************
//                    FIFO bufers
//****************************************************************
//Define memory storage
fifo #(.FIFO_WIDTH(10), .D_WIDTH(15)) fifo_buf_data(.wr_en(wr_en_data),
                                                          .rd_en(rd_en_data),
                                                          .buf_in(bus.BusStateWrite.pkt_size_i),
                                                          .buf_out(buf_out_data) ,
                                                          .buf_empty(buf_empty_data),
                                                          .buf_full(buf_full_data),
                                                          .fifo_counter(fifo_counter_data),
                                                          .rst_i(1'b0),
                                                          .clk_i(bus.clk_i)
                                                          );
fifo #(.FIFO_WIDTH(10), .D_WIDTH(A_WIDTH)) fifo_buf_ptr(.wr_en(wr_en_ptr),
                                                          .rd_en(rd_en_ptr),
                                                          .buf_in(bus.BusStateWrite.rx_flow_num_i),
                                                          .buf_out(buf_out_ptr) ,
                                                          .buf_empty(buf_empty_ptr),
                                                          .buf_full(buf_full_ptr),
                                                          .fifo_counter(fifo_counter_ptr),
                                                          .rst_i(1'b0),
                                                          .clk_i(bus.clk_i)
                                                          );

//****************************************************************
//
//
//            Finite State machine for writing
//
//
//****************************************************************

//****************************************************************
//              Memory Writing: Next State assigning
//****************************************************************
always_ff @(posedge bus.clk_i or posedge bus.rst_i) begin
    if (bus.rst_i) begin
        state_wr_mem_t <= IDLE_WR_MEM;
        //state_r_t <= IDLE;
    end
      else begin
        //state_r_t <= next_state_r_t;
        state_wr_mem_t <= next_state_wr_mem_t;
      end
end

//****************************************************************
//              Memory Writing: Next State Logic
//****************************************************************
always_comb begin : set_next_state_write 
next_state_wr_mem_t = state_wr_mem_t;
//{wr_en_data,rd_en_data} = 2'b00;
wr_en_data = 1'b0;
     unique case(state_wr_mem_t)
      IDLE_WR_MEM:
           begin
             if(bus.BusStateWrite.write_flag_into_mem && !buf_full_data) begin
               //{wr_en_data,rd_en_data} = 2'b10;
               wr_en_data = 1'b1;
               //mem[int'(bus.BusStateWrite.rx_flow_num_i)] = bus.BusStateWrite.pkt_size_i;
             end                    
           end
      WR_MEM:
           begin             
             // if(bus.BusStateWrite.write_flag_into_mem)
             //   begin

             //   end    
           end          
    endcase 
end:set_next_state_write

//****************************************************************
//              Memory Writing: Output logic
//****************************************************************
always_comb begin:set_outputs_write
     unique case(state_wr_mem_t)
      IDLE_WR_MEM:
           begin
				    
           end
      WR_MEM:
           begin
             //if(bus.read_flag_from_write_mem) next_state_wr_mem_t = GET_WR_MEM;
             //mem[]
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
//            Memory Reading: Next State assigning
//****************************************************************
always_ff @(posedge bus.clk_i or posedge bus.rst_i) begin
    if (bus.rst_i) begin
        state_r_mem_t <= IDLE_R_MEM;
       end
      else begin
        state_r_mem_t <= next_state_r_mem_t;
      end
end

//****************************************************************
//              Memory Reading: Next State Logic
//****************************************************************
always_comb begin : set_next_state_read 
next_state_r_mem_t = state_r_mem_t;
rd_en_data = 1'b0;
     unique case(state_r_mem_t)
      IDLE_R_MEM:
           begin
             next_state_r_mem_t = R_MEM;
           end
      R_MEM:
           begin
             if(bus.BusStateRead.read_flag_from_mem && !buf_empty_data)
              begin
                rd_en_data = 1'b1;
                //bus.rd_data_o = mem[int'(bus.BusStateRead.rd_flow_num_i)];
                //next_state_r_mem_t = R_MEM;
              end  
           end          
    endcase 
end:set_next_state_read 

//****************************************************************
//              Memory Reading: Output logic
//****************************************************************
always_comb begin:set_outputs_read 
     unique case(state_r_mem_t)
      IDLE_R_MEM:
           begin
				    
           end
      R_MEM:
           begin
             //if(bus.read_flag_from_write_mem) next_state_wr_mem_t = GET_WR_MEM;
             //mem[]
           end
    endcase 
end:set_outputs_read 

endmodule
`endif