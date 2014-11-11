library verilog;
use verilog.vl_types.all;
entity fifo is
    generic(
        FIFO_WIDTH      : integer := 10;
        D_WIDTH         : integer := 32
    );
    port(
        rst_i           : in     vl_logic;
        clk_i           : in     vl_logic;
        wr_en           : in     vl_logic;
        rd_en           : in     vl_logic;
        buf_in          : in     vl_logic_vector;
        buf_out         : out    vl_logic_vector;
        buf_empty       : out    vl_logic;
        buf_full        : out    vl_logic;
        fifo_counter    : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of FIFO_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of D_WIDTH : constant is 1;
end fifo;
