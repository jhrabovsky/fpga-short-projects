
library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

library UNISIM;
    use UNISIM.VCOMPONENTS.ALL;

library UNIMACRO;
    use UNIMACRO.VCOMPONENTS.ALL;

entity bram_fifo is
    Port (
        CLK100MHZ : in std_logic;
        RST : in std_logic;
        LED : out std_logic_vector(15 downto 0);
        SW : in std_logic_vector(15 downto 0);
        BTN_WR : in std_logic;
        BTN_RD : in std_logic;
        AN : out std_logic_vector(7 downto 0)
    );      
end bram_fifo;

architecture arch of bram_fifo is

component counter is
    Generic (
        THRESHOLD : natural
    );
    Port ( CLK_IN : in STD_LOGIC;
           RST: in STD_LOGIC;
           EN : in STD_LOGIC;
           COUNT : out STD_LOGIC_VECTOR(19 downto 0);
           TS : out STD_LOGIC
    );
end component;

component debounce is
    Port ( sign_in : in STD_LOGIC;
           sign_out : out STD_LOGIC;
           clk, rst : in STD_LOGIC
    );
end component;

--------------------------
--      CONSTANTS       --
--------------------------

constant DATA_LEN : natural := 8;

--------------------------
--      SIGNALS         --
--------------------------

signal empty, full, almost_empty, almost_full : std_logic;
signal db_btn_wr_reg, db_btn_wr_next, wr_tick : std_logic;
signal db_btn_rd_reg, db_btn_rd_next, rd_tick : std_logic;

signal data_wr, data_rd : std_logic_vector(DATA_LEN - 1 downto 0);
signal data_out_next, data_out_reg : std_logic_vector(DATA_LEN - 1 downto 0);

--------------------------
--      ALIASES         --
--------------------------

alias LED_DATA : std_logic_vector(DATA_LEN - 1 downto 0) is LED(DATA_LEN - 1 downto 0);
alias LED_FULL : std_logic is LED(15);
alias LED_ALMOST_FULL : std_logic is LED(14);
alias LED_EMPTY : std_logic is LED(13);
alias LED_ALMOST_EMPTY : std_logic is LED(12); 

alias SW_DATA : std_logic_vector(DATA_LEN - 1 downto 0) is SW(DATA_LEN - 1 downto 0);

--------------------------
--      FSM             --
--------------------------

begin
    db_btn_wr_inst : debounce port map( sign_in=>BTN_WR, sign_out=>db_btn_wr_next, clk=>CLK100MHZ, rst=>RST);
    db_btn_rd_inst : debounce port map( sign_in=>BTN_RD, sign_out=>db_btn_rd_next, clk=>CLK100MHZ, rst=>RST);
  
    reg_update: process(CLK100MHZ, RST) is
    begin 
        if (RST = '1') then
            db_btn_wr_reg <= '0';
            db_btn_rd_reg <= '0';
            data_out_reg <= (others => '0');
        elsif (rising_edge(CLK100MHZ)) then
            db_btn_wr_reg <= db_btn_wr_next;
            db_btn_rd_reg <= db_btn_rd_next;
            data_out_reg <= data_out_next;
        end if;
    end process reg_update;
     
    -- SOURCE: ug953-vivado-7series-libraries.pdf [p167]
       
    FIFO_BRAM_inst : FIFO_SYNC_MACRO
        generic map (
            DEVICE => "7SERIES",
            ALMOST_EMPTY_OFFSET => X"0001",
            ALMOST_FULL_OFFSET => X"0001",
            DATA_WIDTH => DATA_LEN,
            FIFO_SIZE => "18Kb",
            DO_REG => 0 -- ked pouzijem interny reg => vystup sa nezobrazuje, preto nahradim ext reg.
        )
        port map (
            almostempty => almost_empty,
            almostfull => almost_full,
            do => data_rd,
            empty => empty,
            full => full,
            rdcount => open,
            rderr => open,
            wrcount => open,
            wrerr => open,
            clk => CLK100MHZ,
            di => data_wr,
            rden => rd_tick,
            rst => RST,
            wren => wr_tick
        );

    wr_tick <= (not db_btn_wr_reg) and (db_btn_wr_next);
    rd_tick <= (not db_btn_rd_reg) and (db_btn_rd_next);
    
    data_out_next <= data_rd;
    
    LED_DATA <= data_out_reg;
    LED_FULL <= full;
    LED_ALMOST_FULL <= almost_full;
    LED_EMPTY <= empty;
    LED_ALMOST_EMPTY <= almost_empty;

    data_wr <= SW_DATA;

    AN <= "11111111"; -- disable all 7seg displays
        
end arch;
