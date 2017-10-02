library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rom_tb is
end rom_tb;

architecture RTL of rom_tb is

component rom is
    Generic (
        FILENAME : string;
        DATA_LENGTH : integer := 12;
        ADDR_LENGTH  : integer := 11
    );

    Port (
        clk : in std_logic;
        en : in std_logic;
        addr : in std_logic_vector(ADDR_LENGTH - 1 downto 0);
        data : out std_logic_vector(DATA_LENGTH - 1 downto 0)
    );
end component;

component counter is
    Generic (
        THRESHOLD : natural := 5
    );
    Port ( CLK_IN : in STD_LOGIC;
           RST: in STD_LOGIC;
           EN : in STD_LOGIC;
           COUNT : out STD_LOGIC_VECTOR(19 downto 0);
           TS : out STD_LOGIC
    );
end component;

signal mem_ce : std_logic;
signal mem_data : std_logic_vector(7 downto 0);
signal mem_addr : std_logic_vector(3 downto 0);
signal count_tmp : std_logic_vector(19 downto 0);

-- declaration of validation objects
constant T : time := 10ns;
signal clk, rst : std_logic;

begin
    
   rom_inst : rom
        generic map (
            FILENAME => "data-rom.mif",
            DATA_LENGTH => 8,
            ADDR_LENGTH => 4
        )
        port map (
            clk => clk,
            en => sec_tick,
            addr => mem_addr,
            data => mem_data
        );

    mem_addr <= count_tmp(3 downto 0);

    addr_gen_inst : counter
        generic map (
            THRESHOLD => 15
        )
        port map (
            CLK_IN => clk,
            RST => rst,
            EN => '1',
            COUNT => count_tmp,
            TS => open
        );

   clk_gen : process is
   begin
    clk <= '0';
    wait for T/2;
    clk <= '1';
    wait for T/2;
   end process clk_gen;     

    stimuli : process is
    begin
        rst <= '1';
        wait for 2*T;
        rst <= '0';
        wait;
    end process stimuli;
    
end RTL;
