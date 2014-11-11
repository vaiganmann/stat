`ifndef DEFS_BUS // if the already-compiled flag is not set...
  `define DEFS_BUS // set the flag
interface main_bus
 #(	 
     parameter A_WIDTH = 10,
	   parameter D_WIDTH = 32
 )
 (
  input logic clk_i, rst_i,
  output logic [D_WIDTH-1:0] rd_data_o
 );

import definitions_bus::*;

StatesBusWrite BusStateWrite;
StatesBusRead BusStateRead;


	
endinterface
`endif
