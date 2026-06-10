-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : bit_filter.vhd
--
-- Description  : The output bit_filt_o is the input bit_i filtered. The output
--                is updated only if the input stay the same for N cycle
--
-- Auteur       : L. Fournier
-- Date         : 21.11.2022
-- Version      : 1.0
--
-- Utilise dans : Moteur pas-à-pas
--
--| Modifications |------------------------------------------------------------
-- Version   Auteur      Date               Description
-- 1.0       LFR         see header         First version.
-------------------------------------------------------------------------------

--| Library |------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.ilog_pkg.all;

-------------------------------------------------------------------------------

--| Entity |-------------------------------------------------------------------
entity bit_filter is
    generic(
        N          : integer := 100000;   -- number of clock periode filtrage
        SIMULATION : boolean := false
    );
    port(
        clk_i      : in  std_logic;
        rst_i      : in  std_logic;
        bit_i      : in  std_logic;
        bit_filt_o : out std_logic
    );
end bit_filter;
-------------------------------------------------------------------------------

--| Architecture |-------------------------------------------------------------
architecture rtl of bit_filter is

    --| Constants |-------------------------------------------------------------
    constant CPT_SIZE : integer := ilogup(N); -- Calculate optimal register size
    ---------------------------------------------------------------------------

    --| Signals |--------------------------------------------------------------
    -- bit synchronization
    signal bit_sync1_s : std_logic;
    signal bit_sync2_s : std_logic;
    -- bit reg
    signal current_bit_s : std_logic;
    signal next_bit_s    : std_logic;
    -- counter reg
    signal current_cpt_s : unsigned(CPT_SIZE-1 downto 0);
    signal next_cpt_s    : unsigned(CPT_SIZE-1 downto 0);
    -- internal signal
    signal same_data_N_time_s : std_logic;
    ---------------------------------------------------------------------------

begin


    --| Detection bit change |------------------------------------------------------
    -- bit_sync1_s : first the bit_i is synchronized
    -- bit_sync2_s : value the clk befor to detect change
    process (clk_i, rst_i)
    begin
        if rst_i = '1' then
            bit_sync1_s <= '0';
            bit_sync2_s <= '0';
        elsif rising_edge(clk_i) then
            bit_sync1_s <= bit_i;
            bit_sync2_s <= bit_sync1_s;
        end if;
    end process;

    --| Update cpt proc |----------------------------------------------------
    -- This process update the counter
    update_cpt_proc : process(clk_i, rst_i) is
    begin
        if(rst_i = '1') then
            current_cpt_s <= (others => '0');
        elsif(rising_edge(clk_i)) then
            current_cpt_s <= next_cpt_s;
        end if;
    end process update_cpt_proc;
    ---------------------------------------------------------------------------

    --| Next counter mux chain |-----------------------------------------------
    -- Restart counter when bit_sync1_s and bit_sync2_s are different
    next_cpt_s <= (others => '0') when((bit_sync1_s xor bit_sync2_s) = '1') else
                  current_cpt_s   when current_cpt_s = N else
                  current_cpt_s + 1;
    ---------------------------------------------------------------------------

    --| Update data proc |-----------------------------------------------------
    -- This process update the bit
    update_data_proc : process(clk_i, rst_i) is
    begin
        if(rst_i = '1') then
            current_bit_s <= bit_i;
        elsif(rising_edge(clk_i)) then
            current_bit_s <= next_bit_s;
        end if;
    end process update_data_proc;
    ---------------------------------------------------------------------------

    --| Next bit mux chain |---------------------------------------------------
    next_bit_s <= bit_sync2_s when(current_cpt_s = N) else
                  current_bit_s;
    ---------------------------------------------------------------------------

    --| Outputs affectation |--------------------------------------------------
    bit_filt_o <= bit_i when(SIMULATION = true) else
                  current_bit_s;
    ---------------------------------------------------------------------------

end rtl;
-------------------------------------------------------------------------------
