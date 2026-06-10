-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : cmd_mot_pap.vhd
--
-- Description  :
--
-- Auteur       : L. Fournier
-- Date         : 06.09.2022
-- Version      : 1.0
--
-- Utilise dans : Labo moteur pas-à-pas
--
--| Modifications |------------------------------------------------------------
-- Version   Auteur      Date               Description
-- 1.0       LFR         06.09.2022         First version.
-- 2.0       LFR         16.02.2024         2024 version for SysLog2 (MSS cplx)
--
-------------------------------------------------------------------------------

--| Library |------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
-------------------------------------------------------------------------------

--| Entity |-------------------------------------------------------------------
entity cmd_mot_pap is
    generic(
        SIMULATION : boolean := false
    );
    port(
        clk_i       : in  std_logic;
        rst_i       : in  std_logic;
        cap_l_i     : in  std_logic;
        cap_m_i     : in  std_logic;
        cap_r_i     : in  std_logic;
        mode_i      : in  std_logic;
        start_i     : in  std_logic;
        init_i      : in  std_logic;
        nb_tour_i   : in  std_logic_vector(2 downto 0);
        run_l_i     : in  std_logic;
        run_m_i     : in  std_logic;
        run_r_i     : in  std_logic;
        en_l_o      : out std_logic;
        dir_l_o     : out std_logic;
        en_m_o      : out std_logic;
        dir_m_o     : out std_logic;
        en_r_o      : out std_logic;
        dir_r_o     : out std_logic;
        sel_speed_o : out std_logic_vector(1 downto 0);
        err_o       : out std_logic
    );
end cmd_mot_pap;
-------------------------------------------------------------------------------

--| Architecture |-------------------------------------------------------------
architecture struct of cmd_mot_pap is

    --| Internal signals |-----------------------------------------------------
    signal en_l_s                : std_logic;
    signal en_m_s                : std_logic;
    signal en_r_s                : std_logic;
    signal dir_l_s               : std_logic;
    signal dir_r_s               : std_logic;
    signal dir_m_s               : std_logic;

    -- to be completed




    ---------------------------------------------------------------------------

    --| Components |-----------------------------------------------------------
    component UC is
        port(
            clk_i                 : in  std_logic;
            rst_i                 : in  std_logic;


            -- to be completed





        );
    end component;
    for all : UC use entity work.UC(fsm);

    component UT is
        port(
            clk_i                 : in  std_logic;
            rst_i                 : in  std_logic;

            -- to be completed

            --Contrainte : l'activation des moteurs est fait depuis l'UT
            --L'UT aura des elements memoires pour ces actions commandees par l'UC
            en_l_o                : out std_logic;
            en_m_o                : out std_logic;
            en_r_o                : out std_logic;
            dir_l_o               : out std_logic;
            dir_m_o               : out std_logic;
            dir_r_o               : out std_logic
        );
    end component;
    for all : UT use entity work.UT(behave);
    ---------------------------------------------------------------------------

begin
    --| Bloc de pre-traitement des entrees |------------------------------------



    -- to be completed



    --| Components instanciation |---------------------------------------------
    UC_inst : UC
    port map(
        clk_i                 => clk_i,
        rst_i                 => rst_i,


        -- to be completed



    );

    UT_inst : UT
    port map(
        clk_i                 => clk_i,
        rst_i                 => rst_i,

        -- to be completed


        en_l_o                => en_l_s,
        en_m_o                => en_m_s,
        en_r_o                => en_r_s,
        dir_l_o               => dir_l_s,
        dir_r_o               => dir_r_s,
        dir_m_o               => dir_m_s
    );

     --| Output affectation |---------------------------------------------------
    en_l_o  <= en_l_s;
    en_m_o  <= en_m_s;
    en_r_o  <= en_r_s;
    dir_l_o <= dir_l_s,
    dir_r_o <= dir_r_s,
    dir_m_o <= dir_m_s

    -- to be completed


end struct;
