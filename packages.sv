`ifndef DEFS_PACK // if the already-compiled flag is not set...
  `define DEFS_PACK // set the flag

`include "packages.sv"
 
`define A_W 10
`define D_W 32
 
 
package definitions_main;
 
//typedef enum {IDLE, READ, READ_M, OP_M, WRITE_M} states_write;
typedef enum {IDLE_WRITE, WRITE_M} states_write;
typedef enum {IDLE_READ, READ_M} states_read; 
endpackage

package definitions_bus;

parameter A_WIDTH = `A_W;
parameter D_WIDTH = `D_W;
 
typedef struct {
	bit write_flag_into_mem, read_flag_mem_wr;
	logic [A_WIDTH-1:0] rx_flow_num_i;
	logic [15:0] pkt_size_i;
} StatesBusWrite;

typedef struct {
	bit read_flag_from_mem;	
	logic [A_WIDTH-1:0] rd_flow_num_i;
	logic [15:0] pkt_size_i;
} StatesBusRead;

  
endpackage

package definitions_mem;
 
//typedef enum {IDLE_WR_MEM, GET_WR_MEM, WRITE_FIFO, COMP_WR_MEM, WAIT_WR_MEM, WRITE_WR_MEM} states_mem_write;
typedef enum {IDLE_WR_MEM, WR_MEM} states_mem_write;
typedef enum {IDLE_R_MEM, R_MEM} states_mem_read;
  
endpackage
  
`endif