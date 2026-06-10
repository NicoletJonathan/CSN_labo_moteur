-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : controller_mot_pap.vhd
--
-- Description  :
--
-- Auteur       : L. Fournier
-- Date         : 12.07.2022
-- Version      : 1.0
--
-- Utilise dans : Labo moteur pas-à-pas
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
entity controller_mot_pap is
    generic(
        SIMULATION : boolean := false
    );
    port(
        clk_i        : in  std_logic;
        rst_i        : in  std_logic;
        en_i         : in  std_logic;
        dir_i        : in  std_logic;
        full_nHalf_i : in  std_logic;
        sel_speed_i  : in  std_logic_vector(1 downto 0);
        a_o          : out std_logic_vector(1 downto 0);
        b_o          : out std_logic_vector(1 downto 0)
    );
end controller_mot_pap;
-------------------------------------------------------------------------------

--| Architecture |-------------------------------------------------------------
architecture struct of controller_mot_pap is

    --| Signals |--------------------------------------------------------------
    signal top_s  : std_logic;
    signal step_s : std_logic;
    ---------------------------------------------------------------------------

    --| Components |-----------------------------------------------------------
    component gen_top_sgn_mot
        generic(
            SIMULATION : boolean := false
        );
        port(
            clk_i       : in  std_logic;
            rst_i       : in  std_logic;
            sel_speed_i : in  std_logic_vector(1 downto 0);
            top_o       : out std_logic
        );
    end component;
    for all : gen_top_sgn_mot use entity work.gen_top_sgn_mot(behav);

    component phase_manager is
        port(
            clk_i        : in  std_logic;
            rst_i        : in  std_logic;
            dir_i        : in  std_logic;
            full_nHalf_i : in  std_logic;
            step_i       : in  std_logic;
            a_o          : out std_logic_vector(1 downto 0);
            b_o          : out std_logic_vector(1 downto 0)
        );
    end component;
    for all : phase_manager use entity work.phase_manager(fsm);
    ---------------------------------------------------------------------------

begin

    -- The motor must do a step when en and top are at '1'
    step_s <= (en_i)and(top_s);

    --| Components instanciation |---------------------------------------------
    top_sgn: gen_top_sgn_mot
    generic map(
        SIMULATION => SIMULATION
    )
    port map(
        clk_i       => clk_i,
        rst_i       => rst_i,
        sel_speed_i => sel_speed_i,
        top_o       => top_s
    );

    MSS_stepper : phase_manager
    port map(
        clk_i        => clk_i,
        rst_i        => rst_i,
        dir_i        => dir_i,
        full_nHalf_i => full_nHalf_i,
        step_i       => step_s,
        a_o          => a_o,
        b_o          => b_o
    );
    ---------------------------------------------------------------------------

end struct;
-------------------------------------------------------------------------------