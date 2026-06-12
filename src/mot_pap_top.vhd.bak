-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : mot_pap_top.vhd
--
-- Description  : Top component of the labo mot pap
-- Auteur       : L. Fournier
-- Date         : 06.09.2022
-- Version      : 1.0
--
-- Utilise dans : Labo moteur pas-à-pas
--
--| Modifications |------------------------------------------------------------
-- Version   Auteur      Date               Description
-- 1.0       LFR         06.09.2022         First version.
-- 2.0       LFR         16.02.2024         2024 version for SysLog2
-------------------------------------------------------------------------------

--| Library |------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
-------------------------------------------------------------------------------

--| Entity |-------------------------------------------------------------------
entity mot_pap_top is
    port(
        clk_i       : in  std_logic;
        nRst_i      : in  std_logic;
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
        en_bridge_i : in  std_logic;
        l_a1_o      : out std_logic;
        l_a2_o      : out std_logic;
        l_b1_o      : out std_logic;
        l_b2_o      : out std_logic;
        l_en_o      : out std_logic;
        m_a1_o      : out std_logic;
        m_a2_o      : out std_logic;
        m_b1_o      : out std_logic;
        m_b2_o      : out std_logic;
        m_en_o      : out std_logic;
        r_a1_o      : out std_logic;
        r_a2_o      : out std_logic;
        r_b1_o      : out std_logic;
        r_b2_o      : out std_logic;
        r_en_o      : out std_logic;
        err_o       : out std_logic
    );
end mot_pap_top;
-------------------------------------------------------------------------------

--| Architecture |-------------------------------------------------------------
architecture struct of mot_pap_top is

    --| Signals |--------------------------------------------------------------
    -- reset polarity
    signal rst_s : std_logic;
    -- Cmd to controller
    signal en_l_s      : std_logic;
    signal en_m_s      : std_logic;
    signal en_r_s      : std_logic;
    signal dir_l_s     : std_logic;
    signal dir_m_s     : std_logic;
    signal dir_r_s     : std_logic;
    signal sel_speed_s : std_logic_vector(1 downto 0);
    signal err_s       : std_logic;
    -- Phase motor
    signal mot_l_a_s : std_logic_vector(1 downto 0);
    signal mot_l_b_s : std_logic_vector(1 downto 0);
    signal mot_m_a_s : std_logic_vector(1 downto 0);
    signal mot_m_b_s : std_logic_vector(1 downto 0);
    signal mot_r_a_s : std_logic_vector(1 downto 0);
    signal mot_r_b_s : std_logic_vector(1 downto 0);
    ---------------------------------------------------------------------------

    --| Components |-----------------------------------------------------------
    component cmd_mot_pap is
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
    end component;
    for all : cmd_mot_pap use entity work.cmd_mot_pap(struct);

    component controller_mot_pap is
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
    end component;
    for all : controller_mot_pap use entity work.controller_mot_pap(struct);
    ---------------------------------------------------------------------------

begin

    -- Polarity adaptation
    rst_s <= not(nRst_i);

    --| Components instanciation |---------------------------------------------
    command_mot_pap : cmd_mot_pap
    generic map(
        SIMULATION : boolean := false
    )
    port map(
        clk_i       => clk_i,
        rst_i       => rst_s,
        cap_l_i     => cap_l_i,
        cap_m_i     => cap_m_i,
        cap_r_i     => cap_r_i,
        mode_i      => mode_i,
        start_i     => start_i,
        init_i      => init_i,
        nb_tour_i   => nb_tour_i,
        run_l_i     => run_l_i,
        run_m_i     => run_m_i,
        run_r_i     => run_r_i,
        en_l_o      => en_l_s,
        dir_l_o     => dir_l_s,
        en_m_o      => en_m_s,
        dir_m_o     => dir_m_s,
        en_r_o      => en_r_s,
        dir_r_o     => dir_r_s,
        sel_speed_o => sel_speed_s,
        err_o       => err_s
    );

    ctrl_mot_l : controller_mot_pap
    generic map(
        SIMULATION => false
    )
    port map(
        clk_i        => clk_i,
        rst_i        => rst_s,
        en_i         => en_l_s,
        dir_i        => dir_l_s,
        full_nHalf_i => '0',
        sel_speed_i  => sel_speed_s,
        a_o          => mot_l_a_s,
        b_o          => mot_l_b_s
    );

    ctrl_mot_m : controller_mot_pap
    generic map(
        SIMULATION => false
    )
    port map(
        clk_i        => clk_i,
        rst_i        => rst_s,
        en_i         => en_m_s,
        dir_i        => dir_m_s,
        full_nHalf_i => '0',
        sel_speed_i  => sel_speed_s,
        a_o          => mot_m_a_s,
        b_o          => mot_m_b_s
    );

    ctrl_mot_r : controller_mot_pap
    generic map(
        SIMULATION => false
    )
    port map(
        clk_i        => clk_i,
        rst_i        => rst_s,
        en_i         => en_r_s,
        dir_i        => dir_r_s,
        full_nHalf_i => '0',
        sel_speed_i  => sel_speed_s,
        a_o          => mot_r_a_s,
        b_o          => mot_r_b_s
    );

    ---------------------------------------------------------------------------

    --| Outputs affectation |--------------------------------------------------
    l_a1_o <= mot_l_a_s(1);
    l_a2_o <= mot_l_a_s(0);
    l_b1_o <= mot_l_b_s(1);
    l_b2_o <= mot_l_b_s(0);
    l_en_o <= en_bridge_i;

    m_a1_o <= mot_m_a_s(1);
    m_a2_o <= mot_m_a_s(0);
    m_b1_o <= mot_m_b_s(1);
    m_b2_o <= mot_m_b_s(0);
    m_en_o <= en_bridge_i;

    r_a1_o <= mot_r_a_s(1);
    r_a2_o <= mot_r_a_s(0);
    r_b1_o <= mot_r_b_s(1);
    r_b2_o <= mot_r_b_s(0);
    r_en_o <= en_bridge_i;

    err_o   <= err_s;
    ---------------------------------------------------------------------------

end struct;
-------------------------------------------------------------------------------