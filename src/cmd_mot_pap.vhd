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
-- 3.0       FOR         14.06.2026         Description entrées et sorties
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

    -- Signaux de commande (UC -> UT)
    signal en_mot_m_s            : std_logic;
    signal en_mot_r_s            : std_logic;
    signal en_mot_l_s            : std_logic;
    signal en_mot_change_s       : std_logic;
    signal inc_moteur_s          : std_logic;
    signal load_moteur_s         : std_logic;
    signal dec_tour_s            : std_logic;
    signal load_tour_s           : std_logic;
    signal dec_vitesse_s         : std_logic;
    signal inc_vitesse_s         : std_logic;
    signal load_vitesse_s        : std_logic;
    signal inc_n_encoches_s      : std_logic;
    signal load_n_encoches_s     : std_logic;

    -- Signaux d'état / Drapeaux (UT -> UC)
    signal vitesse_max_s         : std_logic;
    signal vitesse_min_s         : std_logic;
    signal fin_de_tour_s         : std_logic;
    signal tour_complet_s        : std_logic;
    signal dernier_tour_s        : std_logic;
    signal fin_seq_auto_s        : std_logic;
    signal moteur_s              : std_logic_vector(1 downto 0);
    
    -- Signaux  
    signal cap_l_s                : std_logic;
    signal cap_m_s                : std_logic;
    signal cap_r_s                : std_logic;
    signal mode_s                 : std_logic;
    signal start_s                : std_logic;
    signal init_s                 : std_logic;
    signal nb_tour_s              : std_logic_vector(2 downto 0);
    signal run_l_s                : std_logic;
    signal run_m_s                : std_logic;
    signal run_r_s                : std_logic;
    signal reg_pres_s             : std_logic_vector(11 downto 0);
    signal reg_fut_s              : std_logic_vector(11 downto 0);

    ---------------------------------------------------------------------------

    --| Components |-----------------------------------------------------------
    component UC is
        port(
            clk_i                 : in  std_logic;
            rst_i                 : in  std_logic;
            
            -- Entrées externes
            cap_l_i               : in  std_logic;
            cap_m_i               : in  std_logic;
            cap_r_i               : in  std_logic;
            mode_i                : in  std_logic;
            start_i               : in  std_logic;
            init_i                : in  std_logic;
            run_l_i               : in  std_logic;
            run_m_i               : in  std_logic;
            run_r_i               : in  std_logic;

            -- Entrées d'état (venant de l'UT)
            vitesse_max_i         : in  std_logic;
            vitesse_min_i         : in  std_logic;
            fin_de_tour_i         : in  std_logic;
            tour_complet_i        : in  std_logic;
            fin_seq_auto_i        : in  std_logic;
				dernier_tour_i        : in  std_logic;
            moteur_i              : std_logic_vector(1 downto 0);

            -- Sorties de commande (vers l'UT)
            en_mot_m_o            : out std_logic;
            en_mot_r_o            : out std_logic;
            en_mot_l_o            : out std_logic;
            en_mot_change_o       : out std_logic;
            inc_moteur_o          : out std_logic;
            load_moteur_o         : out std_logic;
            dec_tour_o            : out std_logic;
            load_tour_o           : out std_logic;
            dec_vitesse_o         : out std_logic;
            inc_vitesse_o         : out std_logic;
            load_vitesse_o        : out std_logic;
            inc_n_encoches_o      : out std_logic;
            load_n_encoches_o     : out std_logic;

            -- Sortie externe
            err_o                 : out std_logic
        );
    end component;
    for all : UC use entity work.UC(fsm);

    component UT is
        port(
            clk_i                 : in  std_logic;
            rst_i                 : in  std_logic;

            -- Entrées de Configuration (Extérieur -> UT)
            mode_i                : in  std_logic;
            nb_tour_i             : in  std_logic_vector(2 downto 0);

            -- Commandes de l'UC (UC -> UT)
            en_mot_m_i            : in  std_logic;
            en_mot_r_i            : in  std_logic;
            en_mot_l_i            : in  std_logic;
            en_mot_change_i       : in  std_logic;
            inc_moteur_i          : in  std_logic;
            load_moteur_i         : in  std_logic;
            dec_tour_i            : in  std_logic;
            load_tour_i           : in  std_logic;
            dec_vitesse_i         : in  std_logic;
            inc_vitesse_i         : in  std_logic;
            load_vitesse_i        : in  std_logic;
            inc_n_encoches_i      : in  std_logic;
            load_n_encoches_i     : in  std_logic;

            -- Sorties d'État / Drapeaux (UT -> UC)
            vitesse_max_o         : out std_logic;
            vitesse_min_o         : out std_logic;
            fin_de_tour_o         : out std_logic;
            tour_complet_o        : out std_logic;
            dernier_tour_o        : out std_logic;
            fin_seq_auto_o        : out std_logic;

            -- Sorties Physiques Moteurs (UT -> Top)
            vitesse_o             : out std_logic_vector(1 downto 0);
				moteur_o             : out std_logic_vector(1 downto 0);

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

    reg_fut_s <= cap_l_i & cap_m_i & cap_r_i & mode_i & start_i & init_i & nb_tour_i & run_l_i & run_m_i & run_r_i;
 
    synchro : process (clk_i, rst_i)
    begin
        if rst_i = '1' then
     reg_pres_s <= (others => '0');
 elsif rising_edge(clk_i) then
     reg_pres_s <= reg_fut_s;
 end if;
    end process;
    
    cap_l_s   <= reg_pres_s(11);
    cap_m_s   <= reg_pres_s(10);
    cap_r_s   <= reg_pres_s(9);
    mode_s    <= reg_pres_s(8);
    start_s   <= reg_pres_s(7);
    init_s    <= reg_pres_s(6);
    nb_tour_s <= reg_pres_s(5 downto 3);
    run_l_s   <= reg_pres_s(2);
    run_m_s   <= reg_pres_s(1);
    run_r_s   <= reg_pres_s(0);

    --| Components instanciation |---------------------------------------------
    UC_inst : UC
    port map(
        clk_i                 => clk_i,
        rst_i                 => rst_i,
        
        cap_l_i               => cap_l_s,
        cap_m_i               => cap_m_s,
        cap_r_i               => cap_r_s,
        mode_i                => mode_s,
        start_i               => start_s,
        init_i                => init_s,
		  run_l_i               => run_l_s,
		  run_m_i               => run_m_s,
		  run_r_i               => run_r_s,
        vitesse_max_i         => vitesse_max_s,
        vitesse_min_i         => vitesse_min_s,
        fin_de_tour_i         => fin_de_tour_s,
        tour_complet_i        => tour_complet_s,
        dernier_tour_i        => dernier_tour_s,
        fin_seq_auto_i        => fin_seq_auto_s,
        moteur_i              => moteur_s,
        en_mot_m_o            => en_mot_m_s,
        en_mot_r_o            => en_mot_r_s,
        en_mot_l_o            => en_mot_l_s,
        en_mot_change_o       => en_mot_change_s,
        inc_moteur_o          => inc_moteur_s,
        load_moteur_o         => load_moteur_s,
        dec_tour_o            => dec_tour_s,
        load_tour_o           => load_tour_s,
        dec_vitesse_o         => dec_vitesse_s,
        inc_vitesse_o         => inc_vitesse_s,
        load_vitesse_o        => load_vitesse_s,
        inc_n_encoches_o      => inc_n_encoches_s,
        load_n_encoches_o     => load_n_encoches_s,
        err_o                 => err_o
    );

    UT_inst : UT
    port map(
        clk_i                 => clk_i,
        rst_i                 => rst_i,

        mode_i                => mode_s,
        nb_tour_i             => nb_tour_s,
        en_mot_m_i            => en_mot_m_s,
        en_mot_r_i            => en_mot_r_s,
        en_mot_l_i            => en_mot_l_s,
        en_mot_change_i       => en_mot_change_s,
        inc_moteur_i          => inc_moteur_s,
        load_moteur_i         => load_moteur_s,
        dec_tour_i            => dec_tour_s,
        load_tour_i           => load_tour_s,
        dec_vitesse_i         => dec_vitesse_s,
        inc_vitesse_i         => inc_vitesse_s,
        load_vitesse_i        => load_vitesse_s,
        inc_n_encoches_i      => inc_n_encoches_s,
        load_n_encoches_i     => load_n_encoches_s,
        vitesse_max_o         => vitesse_max_s,
        vitesse_min_o         => vitesse_min_s,
        fin_de_tour_o         => fin_de_tour_s,
        tour_complet_o        => tour_complet_s,
        dernier_tour_o        => dernier_tour_s,
        fin_seq_auto_o        => fin_seq_auto_s,
        moteur_o              => moteur_s,
        vitesse_o             => sel_speed_o,

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
    dir_l_o <= dir_l_s;
    dir_r_o <= dir_r_s;
    dir_m_o <= dir_m_s;


end struct;