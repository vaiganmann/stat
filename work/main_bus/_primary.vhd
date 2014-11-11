library verilog;
use verilog.vl_types.all;
entity main_bus is
    generic(
        A_WIDTH         : integer := 10;
        D_WIDTH         : integer := 32
    );
    port(
        clk_i           : in     vl_logic;
        rst_i           : in     vl_logic;
        rd_data_o       : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of A_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of D_WIDTH : constant is 1;
end main_bus;
