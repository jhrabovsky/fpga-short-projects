
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
    Port (
        CLK100MHZ : in std_logic;
        RST : in std_logic;
        SW : in std_logic_vector(15 downto 0);
        LED : out std_logic_vector(15 downto 0);
        BTN_WR : in std_logic;
        AN : out std_logic_vector(7 downto 0)
    );
end top;

architecture Behavioral of top is

component dual_ram is
    generic (
        RAM_WIDTH_BITS : integer := 64;                      -- Specify RAM data width
        RAM_DEPTH_BITS : integer := 10                      
    );

    port (
        clk  : in std_logic;                       			            -- Clock
        addr_in : in std_logic_vector(RAM_DEPTH_BITS - 1 downto 0);     -- Write address bus, width determined from RAM_DEPTH
        addr_out : in std_logic_vector(RAM_DEPTH_BITS - 1 downto 0);    -- Read address bus, width determined from RAM_DEPTH
        din  : in std_logic_vector(RAM_WIDTH_BITS - 1 downto 0);	            -- RAM input data
        we   : in std_logic;                       			            -- Write enable
        dout : out std_logic_vector(RAM_WIDTH_BITS - 1 downto 0)               -- RAM output data
    );
end component;

component debounce is
    Port ( sign_in : in STD_LOGIC;
           sign_out : out STD_LOGIC;
           clk, rst : in STD_LOGIC);
end component;

constant RAM_DEPTH_BITS : natural := 4;
constant RAM_WIDTH_BITS : natural := 8;

signal addr_wr, addr_rd : std_logic_vector(RAM_DEPTH_BITS - 1 downto 0);
signal data_wr, data_rd : std_logic_vector(RAM_WIDTH_BITS - 1 downto 0);

signal wr_tick : std_logic;
signal db_btn_wr_next, db_btn_wr_reg : std_logic;

alias SW_ADDR : std_logic_vector(RAM_DEPTH_BITS - 1 downto 0) is SW(15 downto 15 - RAM_DEPTH_BITS + 1);
alias SW_DATA : std_logic_vector(RAM_WIDTH_BITS - 1 downto 0) is SW(RAM_WIDTH_BITS - 1 downto 0);
alias LED_DATA : std_logic_vector(RAM_WIDTH_BITS - 1 downto 0) is LED(RAM_WIDTH_BITS - 1 downto 0);

begin

    debounce_inst : debounce
        port map (
            sign_in => BTN_WR,
            sign_out => db_btn_wr_next,
            clk => CLK100MHZ,
            rst => RST
        );

    regs_proc : process (CLK100MHZ) is
    begin
        if (rising_edge(CLK100MHZ)) then
            if (RST = '1') then
                db_btn_wr_reg <= '0';
            else
                db_btn_wr_reg <= db_btn_wr_next;
            end if;
        end if;
    end process regs_proc;

    wr_tick <= (not db_btn_wr_reg) and db_btn_wr_next;
    
    ram_inst : dual_ram
       generic map (
            RAM_WIDTH_BITS => RAM_WIDTH_BITS,
            RAM_DEPTH_BITS => RAM_DEPTH_BITS
       )
       port map (
            clk => CLK100MHZ,
            addr_in => addr_wr,
            addr_out => addr_rd,
            din => data_wr,
            we => wr_tick,
            dout => data_rd
       ); 
       
       addr_wr <= SW_ADDR;
       addr_rd <= SW_ADDR;
       
       data_wr <= SW_DATA;
       LED_DATA <= data_rd;
       
       AN <= "11111111";
end Behavioral;
