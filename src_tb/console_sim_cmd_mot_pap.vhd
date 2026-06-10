-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : console_sim_uc.vhd
--
-- Description  : Ce fichier permet l'utilisation de la console generique du REDS.
-- 
-- Auteur       : Etienne Messerli
-- Date         : 17.05.2024
-- 
-- Utilise      : -
-- 
--| Modifications |------------------------------------------------------------
-- Ver   Qui   Date         Description
-- 0.0   EMI   17.05.2024   Version initial
--  
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity console_sim is
  port(
    -- 16 switchs
    S0_sti       : in     std_logic;
    S1_sti       : in     std_logic;
    S2_sti       : in     std_logic;
    S3_sti       : in     std_logic;
    S4_sti       : in     std_logic;
    S5_sti       : in     std_logic;
    S6_sti       : in     std_logic;
    S7_sti       : in     std_logic;
    S8_sti       : in     std_logic;
    S9_sti       : in     std_logic;
    S10_sti      : in     std_logic;
    S11_sti      : in     std_logic;
    S12_sti      : in     std_logic;
    S13_sti      : in     std_logic;
    S14_sti      : in     std_logic;
    S15_sti      : in     std_logic;
    -- 2 valeurs sur 16 bits
    Val_A_sti    : in     std_logic_vector (15 downto 0);
    Val_B_sti    : in     std_logic_vector (15 downto 0);
    -- 16 LEDs
    L0_obs       : out    std_logic;
    L1_obs       : out    std_logic;
    L2_obs       : out    std_logic;
    L3_obs       : out    std_logic;
    L4_obs       : out    std_logic;
    L5_obs       : out    std_logic;
    L6_obs       : out    std_logic;
    L7_obs       : out    std_logic;
    L8_obs       : out    std_logic;
    L9_obs       : out    std_logic;
    L10_obs      : out    std_logic;
    L11_obs      : out    std_logic;
    L12_obs      : out    std_logic;
    L13_obs      : out    std_logic;
    L14_obs      : out    std_logic;
    L15_obs      : out    std_logic;
    -- 2 valeurs hexadecimales
    Hex0_obs     : out    Std_Logic_Vector ( 3 downto 0);
    Hex1_obs     : out    Std_Logic_Vector ( 3 downto 0);
    -- 2 resultats sur 16 bits
    Result_A_obs : out    std_logic_vector (15 downto 0);
    Result_B_obs : out    std_logic_vector (15 downto 0);
    -- 1 affichage 7 segments
    -- seg7_obs(0) -> DP (pas present)
    -- seg7_obs(1) -> G
    -- seg7_obs(2) -> F
    -- seg7_obs(3) -> E
    -- seg7_obs(4) -> D
    -- seg7_obs(5) -> C
    -- seg7_obs(6) -> B
    -- seg7_obs(7) -> A
    seg7_obs     : out    std_logic_vector ( 7 downto 0)
  );

-- Declarations

end console_sim ;

architecture struct of console_sim is
  
   -- Internal signal declarations
   signal clk_s  : Std_Logic := '1';  -- clock for the simulation
   constant PERIODE : time := 100 ns;
   
   component cmd_mot_pap
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
   for all : cmd_mot_pap use entity work.cmd_mot_pap;

   --signaux interne pour la simulation
   signal sel_speed_s : std_logic_vector(1 downto 0);

begin

  -- Clock generator for the simulation ---------------------------------------
  process
  begin
    clk_s <= '0', '1' after PERIODE/4, '0' after 3 * PERIODE/4;
    wait for PERIODE;
  end process;

  -- affichage etat motuer stop via Result_A_obs
  Result_A_obs(1 downto 0) <= sel_speed_s;
  Result_A_obs(15 downto 2) <= (others => '0');

  -- Instance port mappings.
  UUT : cmd_mot_pap port map (
        clk_i         => clk_s,
        rst_i         => S15_sti,
        cap_l_i       => S7_sti,
        cap_m_i       => S8_sti,
        cap_r_i       => S9_sti,
        mode_i        => S0_sti,
        start_i       => S1_sti,
        init_i        => S2_sti,
        nb_tour_i     => Val_A_sti(2 downto 0),
        run_l_i       => S3_sti,
        run_m_i       => S4_sti,
        run_r_i       => S5_sti,
        en_l_o        => L0_obs,
        dir_l_o       => L1_obs,
        en_m_o        => L2_obs,
        dir_m_o       => L3_obs,
        en_r_o        => L4_obs,
        dir_r_o       => L5_obs,
        sel_speed_o   => sel_speed_s,
        err_o         => L6_obs
        );

end struct;
