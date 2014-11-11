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

//Define memory storage
logic [D_WIDTH-1:0] mem [int'(2'b10<<(A_WIDTH-1))-1:0];


//****************************************************************
//                  Memory Writing
//****************************************************************
always_ff @(posedge bus.clk_i or posedge bus.rst_i) begin
    if (!bus.rst_i) begin
      if(bus.BusStateWrite.write_flag_into_mem) mem[int'(bus.BusStateWrite.rx_flow_num_i)] = bus.BusStateWrite.pkt_size_i;
    end
end

//****************************************************************
//                   Memory Reading
//****************************************************************
always_ff @(posedge bus.clk_i or posedge bus.rst_i) begin
    if (!bus.rst_i) begin
        if(bus.BusStateRead.read_flag_from_mem) bus.rd_data_o = mem[int'(bus.BusStateRead.rd_flow_num_i)];
    end
end

endmodule
`endif