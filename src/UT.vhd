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
end UT;
-------------------------------------------------------------------------------

--| Architecture |-------------------------------------------------------------
architecture behave of UT is

    --| Constantes |-----------------------------------------------------------

    -- to be completed



    --| Signals |--------------------------------------------------------------

    -- to be completed



    --| Components |-----------------------------------------------------------

    -- to be completed


begin



    -- to be completed




end behave;
