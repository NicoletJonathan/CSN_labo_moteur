-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : UT.vhd
--
-- Description  : UT pour la commande des 3 moteurs pas-a-pas
--
-- Auteur       : ....
-- Date         : 21.05.2024
-- Version      : 1.0
--
-- Utilise dans : Labo moteur pas-à-pas (MSS cplx)
--
--| Modifications |------------------------------------------------------------
-- Version   Auteur      Date               Description
--
--
-------------------------------------------------------------------------------

--| Library |------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
-------------------------------------------------------------------------------

--| Entity |-------------------------------------------------------------------
entity UT is
    port(
        clk_i                 : in  std_logic;
        rst_i                 : in  std_logic;

        --| Entrées de Configuration (Extérieur -> UT)
        mode_i                : in  std_logic;
        nb_tour_i             : in  std_logic_vector(2 downto 0); -- 0 à 7 donc 3 bit
        
        --| Commandes de l'UC (UC -> UT)
        en_mot_m_i              : in  std_logic;
        en_mot_r_i              : in  std_logic;
        en_mot_l_i              : in  std_logic;
        en_mot_change_i         : in  std_logic;
        inc_moteur_i            : in  std_logic;
        load_moteur_i           : in  std_logic;
        dec_tour_i              : in  std_logic;
        load_tour_i             : in  std_logic;
        dec_vitesse_i           : in  std_logic;
        inc_vitesse_i           : in  std_logic;
        load_vitesse_i          : in  std_logic;
        inc_n_encoches_i        : in  std_logic;
        load_n_encoches_i       : in  std_logic;
        
        --| Sorties d'État (UT -> UC)
        vitesse_max_o         : out std_logic;
        vitesse_min_o         : out std_logic;
        vitesse_o             : out std_logic_vector(1 downto 0);
		  moteur_o              : out std_logic_vector(1 downto 0);
        fin_de_tour_o         : out std_logic;
        tour_complet_o        : out std_logic;
        dernier_tour_o        : out std_logic;
        fin_seq_auto_o        : out std_logic;

        --Contrainte : l'activation des moteurs est fait depuis l'UT
        --L'UT aura des elements memoires pour ces actions commandees par l'UC
        en_l_o                : out std_logic;
        en_m_o                : out std_logic;
        en_r_o                : out std_logic;
        dir_l_o               : out std_logic;
        dir_m_o               : out std_logic;
        dir_r_o               : out std_logic
    );
end UT;
-------------------------------------------------------------------------------

--| Architecture |-------------------------------------------------------------
architecture behave of UT is

    --| Constantes |-----------------------------------------------------------

    --| Signals |--------------------------------------------------------------

    --| Signals internes pour les compteurs (type unsigned pour l'arithmétique) |
    signal tour_s       : unsigned(2 downto 0); -- 0 à 7 donc 3 bit
    signal moteur_s     : unsigned(1 downto 0); -- 0 à 2 donc 2 bit
    signal n_coches_s   : unsigned(2 downto 0); -- 0 à 4 donc 3 bit
    signal vitesse_s    : unsigned(1 downto 0); -- 0 à 2 donc 2 bit
    
    signal fin_de_tour_int_s : std_logic;

    --| Components |-----------------------------------------------------------

    -- to be completed

begin
    
    --| Process Synchrone : Bascules et Compteurs |----------------------------
    process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            -- Reset Asynchrone
            en_l_o      <= '0';
            en_m_o      <= '0';
            en_r_o      <= '0';
            tour_s      <= (others => '0');
            moteur_s    <= (others => '0');
            n_coches_s  <= (others => '0');
            vitesse_s   <= (others => '0');

        elsif rising_edge(clk_i) then
            
            -- 1. Bascules D d'activation des moteurs
            if en_mot_change_i = '1' then
                en_l_o <= en_mot_l_i;
            end if;
            
            if en_mot_change_i = '1' then
                en_m_o <= en_mot_m_i;
            end if;
            
            if en_mot_change_i = '1' then
                en_r_o <= en_mot_r_i;
            end if;

            -- 2. Compteur "tour"
            if load_tour_i = '1' then
                tour_s <= unsigned(nb_tour_i);
            elsif dec_tour_i = '1' then
                tour_s <= tour_s - 1;
            end if;

            -- 3. Compteur "moteur"
            if load_moteur_i = '1' then
                moteur_s <= (others => '0'); -- Charge 0 selon schéma
            elsif inc_moteur_i = '1' then
                moteur_s <= moteur_s + 1;
            end if;

            -- 4. Compteur "n_coches"
            if load_n_encoches_i = '1' then
                n_coches_s <= (others => '0'); -- Charge 0 selon schéma
            elsif inc_n_encoches_i = '1' then
                n_coches_s <= n_coches_s + 1;
            end if;

            -- 5. Compteur "vitesse"
            if load_vitesse_i = '1' then
                vitesse_s <= (others => '0'); -- Charge 0 selon schéma
            elsif inc_vitesse_i = '1' then
                vitesse_s <= vitesse_s + 1;
            elsif dec_vitesse_i = '1' then
                vitesse_s <= vitesse_s - 1;
            end if;

        end if;
    end process;
    
    --| Logique Combinatoire : Comparateurs (UT -> UC) |-----------------------
    
    -- Comparateurs Vitesse
    vitesse_max_o <= '1' when vitesse_s = 3 else '0';
    vitesse_min_o <= '1' when vitesse_s = 0 else '0';
	
	 vitesse_o <= std_logic_vector(vitesse_s);
	 moteur_o <= std_logic_vector(moteur_s);
    -- Comparateurs Tours et Coches
    fin_de_tour_int_s <= '1' when tour_s = 0 else '0';
    dernier_tour_o    <= '1' when tour_s = 1 else '0';
    fin_de_tour_o     <= fin_de_tour_int_s;
    
    tour_complet_o    <= '1' when n_coches_s = 5 else '0';

    -- Condition complexe : fin de séquence automatique (Porte AND)
    fin_seq_auto_o    <= '1' when (moteur_s >= 2 and fin_de_tour_int_s = '1') else '0';

    --| Logique Combinatoire : MUX Direction |---------------------------------
    -- Selon le schéma, mode_i sélectionne entre '0' et le bit de poids faible de s_moteur
    -- Cette sortie pilote dir_mot_m_o et dir_mot_l_o. (dir_r_o est forcé à '0' par sécurité).
    
    dir_m_o <= std_logic(moteur_s(0)) when mode_i = '1' else '0';
    dir_l_o <= std_logic(moteur_s(0)) when mode_i = '1' else '0';
    dir_r_o <= '0';

end behave;