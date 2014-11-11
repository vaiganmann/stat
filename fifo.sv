`ifndef DEFS_FIFO // if the already-compiled flag is not set...
  `define DEFS_FIFO // set the flag
module fifo
#
(
	parameter FIFO_WIDTH = 10,
	parameter D_WIDTH = 32
)
( 
  
input     logic            rst_i, clk_i, wr_en, rd_en,   
// reset, system clock, write enable and read enable.
input     logic [D_WIDTH-1:0]           buf_in,                   
// data input to be pushed to buffer
output    logic [D_WIDTH-1:0]           buf_out,                  
// port to output the data using pop.
output    bit          buf_empty, buf_full,      
// buffer empty and full indication 
output    logic [FIFO_WIDTH-1:0] fifo_counter             
// number of data pushed in to buffer  
);

bit [FIFO_WIDTH-1:0]     rd_ptr, wr_ptr;           // pointer to read and write addresses  
bit [D_WIDTH-1:0] buf_mem [FIFO_WIDTH:0];  

always_comb
begin
   buf_empty = (fifo_counter==0);
   buf_full = (fifo_counter== FIFO_WIDTH);
end

always_ff @(posedge clk_i or posedge rst_i)
begin
   if( rst_i )
       fifo_counter <= 0;

   else if( (!buf_full && wr_en) && ( !buf_empty && rd_en ) )
       fifo_counter <= fifo_counter;

   else if( !buf_full && wr_en )
       fifo_counter <= fifo_counter + 1;

   else if( !buf_empty && rd_en )
       fifo_counter <= fifo_counter - 1;
   else
      fifo_counter <= fifo_counter;
end

always_ff @( posedge clk_i or posedge rst_i)
begin
   if( rst_i )
      buf_out <= 0;
   else
   begin
      if( rd_en && !buf_empty )
         buf_out <= buf_mem[rd_ptr];

      else
         buf_out <= buf_out;

   end
end

always_ff @(posedge clk_i)
begin

   if( wr_en && !buf_full )
      buf_mem[ wr_ptr ] <= buf_in;

   else
      buf_mem[ wr_ptr ] <= buf_mem[ wr_ptr ];
end

always_ff @(posedge clk_i or posedge rst_i)
begin
   if( rst_i )
   begin
      wr_ptr <= 0;
      rd_ptr <= 0;
   end
   else
   begin
      if( !buf_full && wr_en )    wr_ptr <= wr_ptr + 1;
          else  wr_ptr <= wr_ptr;

      if( !buf_empty && rd_en )   rd_ptr <= rd_ptr + 1;
      else rd_ptr <= rd_ptr;
   end

end
endmodule

`endif