-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : gen_top_sgn_mot.vhd
--
-- Description  : Top signal generator, the top signal is set to '1' for one
--                clock impulse each time the counter attain his max value
--
-- Auteur       : L. Fournier
-- Date         : 11.07.2022
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
-------------------------------------------------------------------------------

--| Entity |-------------------------------------------------------------------
entity gen_top_sgn_mot is
    generic(
        SIMULATION : boolean := false
    );
    port(
        clk_i       : in  std_logic;
        rst_i       : in  std_logic;
        sel_speed_i : in  std_logic_vector(1 downto 0);
        top_o       : out std_logic
    );
end gen_top_sgn_mot;
-------------------------------------------------------------------------------

--| Architecture |-------------------------------------------------------------
architecture behav of gen_top_sgn_mot is

    --| Constants |------------------------------------------------------------
    constant CPT_SIZE : integer := 20;
    ---------------------------------------------------------------------------

    --| Signals |--------------------------------------------------------------
    signal cpt_eq_zero_s   : std_logic;
    signal val_cpt_s       : unsigned(CPT_SIZE-1 downto 0);
    signal val_cpt_sim_s   : unsigned(CPT_SIZE-1 downto 0);
    signal val_cpt_synth_s : unsigned(CPT_SIZE-1 downto 0);
    signal current_cpt_s   : unsigned(CPT_SIZE-1 downto 0) := (others => '0');
    signal next_cpt_s      : unsigned(CPT_SIZE-1 downto 0);
    ---------------------------------------------------------------------------

begin

    -- Multiplexer used to define the val max to count in function of the
    -- sel_speed entry
    -- Fclk = 40MHz => Tclk = 1/(40*10⁶) = 25ns
    -- Tstep = N*Tclk => N = Tstep/Tclk
    -- Ex : Tstep = 0.5 ms => N = (0.5*10⁻³)/(25*10⁻⁹) = 20000
    with sel_speed_i select val_cpt_synth_s <=
        to_unsigned(  800000-1, CPT_SIZE) when "00", -- 20.0 ms
        to_unsigned(  400000-1, CPT_SIZE) when "01", -- 10.0 ms
        to_unsigned(  200000-1, CPT_SIZE) when "10", --  5.0 ms
        to_unsigned(  100000-1, CPT_SIZE) when "11", --  2.5 ms
        to_unsigned(       0  , CPT_SIZE) when others;

    with sel_speed_i select val_cpt_sim_s <=
        to_unsigned(  64-1, CPT_SIZE) when "00",
        to_unsigned(  32-1, CPT_SIZE) when "01",
        to_unsigned(  16-1, CPT_SIZE) when "10",
        to_unsigned(   8-1, CPT_SIZE) when "11",
        to_unsigned(     0, CPT_SIZE) when others;

    val_cpt_s <= val_cpt_sim_s when(SIMULATION) else
                 val_cpt_synth_s;

    -- Next cpt decoder for the counter
    next_cpt_s <= val_cpt_s when(cpt_eq_zero_s = '1') else
                  (current_cpt_s -1);

    --| Cpt update proc |------------------------------------------------------
    -- This process updade the counter
    cpt_update_proc : process(clk_i, rst_i) is
    begin
        if(rst_i = '1') then
            current_cpt_s <= (others => '0');
        elsif(rising_edge(clk_i)) then
            current_cpt_s <= next_cpt_s;
        end if;
    end process cpt_update_proc;
    ---------------------------------------------------------------------------

    -- Comparator used to know when cpt attain zero value
    cpt_eq_zero_s <= '1' when(current_cpt_s = 0) else
                     '0';

    --| Outputs affectation |--------------------------------------------------
    top_o <= cpt_eq_zero_s;
    ---------------------------------------------------------------------------

end behav;
-------------------------------------------------------------------------------