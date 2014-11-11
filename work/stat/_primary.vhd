library verilog;
use verilog.vl_types.all;
entity stat is
    generic(
        A_WIDTH         : integer := 10;
        D_WIDTH         : integer := 32
    );
    port(
        clk_i           : in     vl_logic;
        rst_i           : in     vl_logic;
        rx_flow_num_i   : in     vl_logic_vector;
        pkt_size_i      : in     vl_logic_vector(15 downto 0);
        pkt_size_en_i   : in     vl_logic;
        rd_stb_i        : in     vl_logic;
        rd_flow_num_i   : in     vl_logic_vector;
        rd_data_o       : out    vl_logic_vector;
        rd_data_val_o   : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of A_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of D_WIDTH : constant is 1;
end stat;
