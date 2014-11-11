library verilog;
use verilog.vl_types.all;
entity testbench is
    generic(
        A_WIDTH         : integer := 10;
        D_WIDTH         : integer := 32
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of A_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of D_WIDTH : constant is 1;
end testbench;
