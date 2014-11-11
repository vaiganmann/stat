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

//****************************************************************
//                Inclide external modules
//****************************************************************
`include "fifo.sv"

//****************************************************************
//                     Some local defs
//****************************************************************
typedef enum {WRITE_NEXT, WRITE_READ_MEM} states_write;
typedef enum {IDLE_READ, READ_M} states_read;

parameter FIFO_WIDTH = 20;

states_write next_state_wr_t, state_wr_t; 
states_read  next_state_r_t, state_r_t; 

bit WRITE_BLOCKED; 

//Define memory storage
bit [D_WIDTH-1:0] mem [int'(2'b10<<(A_WIDTH-1))-1:0];

//Defenitions for FIFO
logic                         wr_en_data, rd_en_data, wr_en_ptr, rd_en_ptr ;   
// reset, system clock, write enable and read enable.
bit [D_WIDTH-1:0]           buf_in_data,buf_in_ptr;                   
// data input to be pushed to buffer
bit [D_WIDTH-1:0]           buf_out_data,buf_out_ptr;                  
// port to output the data using pop.
bit                           buf_empty_data, buf_full_data,buf_empty_ptr, buf_full_ptr;      
// buffer empty and full indication 
bit [FIFO_WIDTH-1:0]        fifo_counter_data,fifo_counter_ptr;             
// number of data pushed in to buffer  

//Values for temp storage of imput values
logic [A_WIDTH-1:0] rx_flow_num_i_tmp;
logic [15:0] pkt_size_i_tmp;

//****************************************************************
//                    FIFO bufers
//****************************************************************
//Define FIFO storage

//FIFO for prt sizes
fifo #(.FIFO_WIDTH(FIFO_WIDTH), .D_WIDTH(15)) fifo_buf_data(.wr_en(wr_en_data),
                                                          .rd_en(rd_en_data),
                                                          .buf_in(pkt_size_i_tmp),
                                                          .buf_out(buf_out_data) ,
                                                          .buf_empty(buf_empty_data),
                                                          .buf_full(buf_full_data),
                                                          .fifo_counter(fifo_counter_data),
                                                          .rst_i(1'b0),
                                                          .clk_i(clk_i)
                                                          );
//FIFO for pckt adresses
fifo #(.FIFO_WIDTH(FIFO_WIDTH), .D_WIDTH(A_WIDTH)) fifo_buf_ptr(.wr_en(wr_en_ptr),
                                                          .rd_en(rd_en_ptr),
                                                          .buf_in(rx_flow_num_i_tmp),
                                                          .buf_out(buf_out_ptr) ,
                                                          .buf_empty(buf_empty_ptr),
                                                          .buf_full(buf_full_ptr),
                                                          .fifo_counter(fifo_counter_ptr),
                                                          .rst_i(1'b0),
                                                          .clk_i(clk_i)
                                                          );
 
 
//****************************************************************
//           The block that continiously writes to FIFO
//**************************************************************** 
 
always_ff @(posedge clk_i or negedge rst_i) begin : write_to_fifo
  if(!rst_i) begin
    //Wait for data come in and if FIFO is not full write
    if(pkt_size_en_i && !buf_full_data)
      begin
       wr_en_data <= 1'b1;
       wr_en_ptr <= 1'b1;
       //Use this temp value to store income data
       rx_flow_num_i_tmp <= rx_flow_num_i;
       pkt_size_i_tmp <= pkt_size_i;
      end
      else
       begin
        wr_en_data <= 1'b0;
        wr_en_ptr <= 1'b0;
       end
  end
end:write_to_fifo                                                         


//****************************************************************
//                  The block of arbiter
//**************************************************************** 
 
always_comb begin : arbiter
    //if current reading adress is equal to that to be read and writed from FIFO then writing to mem is blocked
    //it means that reading has a priority over writing because writing value can be temporaly stored in FIFO
    if((rd_flow_num_i == buf_out_ptr) && rd_stb_i) WRITE_BLOCKED = 1;
    else WRITE_BLOCKED = 0;
end:arbiter     


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
    if (rst_i)state_wr_t <= WRITE_NEXT;
      else state_wr_t <= next_state_wr_t;
end


//****************************************************************
//   Finite State machine for writing: Next State Logic
//****************************************************************
always_comb begin : set_next_state_write 
next_state_wr_t = state_wr_t;
{rd_en_data, rd_en_ptr} = 2'b00; 
     unique case(state_wr_t)
        WRITE_NEXT:
        //This state decide read or not to read from fifo
           begin
              //If FIFO buf is not emty then start writing to memory 
              if(!buf_empty_data) begin 
                //get data and ptr from FIFO
                {rd_en_data, rd_en_ptr} = 2'b11;               
                next_state_wr_t = WRITE_READ_MEM;
              end          
           end
          WRITE_READ_MEM:
            begin
              if(!WRITE_BLOCKED)
                //if cell is not blocked due to reading than update the value 
                begin
                 mem[int'(buf_out_ptr)] = mem[int'(buf_out_ptr)] + buf_out_data;
				         next_state_wr_t = WRITE_NEXT;
				        end
            end            
    endcase 
end:set_next_state_write 


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
    if (rst_i)state_r_t <= IDLE_READ;
    else state_r_t <= next_state_r_t;
end


//****************************************************************
//         Finite State machine for reading: Next State Logic
//****************************************************************
always_comb begin:set_next_state_read    
 next_state_r_t = state_r_t;
 {rd_data_val_o,rd_data_o} = 2'b00;
     unique case(state_r_t)
      IDLE_READ:
           begin
				      if(rd_stb_i)next_state_r_t = READ_M;				        
				      else next_state_r_t = READ_M;
           end
      READ_M:
            begin
           //   if(BLOCKED_ADR == UNBLOCKED) 
            //    begin
                  rd_data_o = mem[rd_flow_num_i];
                  rd_data_val_o = 1;
                  next_state_r_t = IDLE_READ;
            //    end
				     // next_state_r_t = READ_M; 
            end        
    endcase 
end:set_next_state_read 

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

/*
initial begin
clk_i = 1'b0;
pkt_size_en_i = 1'b0; 
rd_stb_i = 1'b0;
forever  
  begin 
   #50
   count2 = 2'b10<<A_WIDTH-4; 
   clk_i = !clk_i;   
   if (clk_i)
    if(count<=5)
      begin
       pkt_size_en_i = 1;
       pkt_size_i = ++count;     
       rx_flow_num_i = count;      
      end
     else if(count3<=5)
       begin
         pkt_size_en_i = 0;
         rd_stb_i = 1;
         rd_flow_num_i = count3++;
       end
     else 
      begin
       rd_stb_i = 0; 
       count = 0;
       count3 = 0;
      end
  end
end
*/

initial begin
clk_i = 1'b0;
pkt_size_en_i = 1'b0; 
rd_stb_i = 1'b0;
forever  
  begin 
   #50
   count2 = 2'b10<<A_WIDTH-4; 
   clk_i = !clk_i;   
   if (clk_i)
    if(count<=5)
      begin
       pkt_size_en_i = 1;
       pkt_size_i = ++count;     
       rx_flow_num_i = count;
       if(count==3)
        begin
         rd_stb_i = 1;
         rd_flow_num_i = 3;
       end
       else  rd_stb_i = 0;          
      end
  end
end

endmodule





