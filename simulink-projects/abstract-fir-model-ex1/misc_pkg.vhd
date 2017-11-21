library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

package misc_pkg is

    function log2c (N : integer) return integer; 

    component counter_mod_n is
        Generic (
            N : integer
        );
        
        Port ( 
            clk : in std_logic;
            rst : in std_logic;
            ce : in std_logic;
            clear : in std_logic;
            tc : out std_logic -- terminal count
        );
    end component;

    component counter_down is
        Generic (
            THRESHOLD : natural;
            THRESHOLD_WIDTH : natural
        );
        Port ( CLK_IN : in STD_LOGIC;
               RST: in STD_LOGIC;
               EN : in STD_LOGIC;
               COUNT : out STD_LOGIC_VECTOR(THRESHOLD_WIDTH - 1 downto 0);
               TS : out STD_LOGIC
        );
    end component;

    component counter_down_dynamic is
        Generic (
            THRESHOLD_WIDTH : natural
        );
        
        Port ( 
            clk : in std_logic;
            ce : in std_logic;
            clear : in std_logic;
            set : in std_logic;
            threshold : in std_logic_vector(THRESHOLD_WIDTH - 1 downto 0);
            tc : out std_logic -- terminal count
        );
    end component;

    component edge_detector is
        Port (
            clk, rst : in std_logic;        
            din : in std_logic;
            edge : out std_logic
        );
    end component;

    component mem_reader is
        generic (
            FILENAME : string;
            DATA_LEN : natural;
            ADDR_LEN : natural;
            NO_ITEMS : natural 
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            en : in std_logic;
            data : out std_logic_vector(DATA_LEN - 1 downto 0)
        );
    end component;

    component shift_reg is
        Generic (
            LENGTH : integer;
            DATA_WIDTH: integer
        );
        
        Port ( 
            din : in std_logic_vector(DATA_WIDTH - 1 downto 0);
            dout : out std_logic_vector(DATA_WIDTH - 1 downto 0);
            load_data : in std_logic_vector(LENGTH * DATA_WIDTH - 1 downto 0);
            load : in std_logic;
            clk : in std_logic; 
            ce : in std_logic 
        );
    end component;

end misc_pkg;

package body misc_pkg is

    function log2c (N : integer) return integer is
        variable m, p : integer;
    begin
        m := 0;
        p := 1;
        while p < N loop
            m := m + 1;
            p := p * 2;
        end loop;
        return m;
    end log2c; 

end package body;
