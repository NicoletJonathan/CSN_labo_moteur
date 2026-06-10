-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : UC.vhd
--
-- Description  : UC pour la commande des 3 moteurs pas-a-pas
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

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

--| Entity |-------------------------------------------------------------------
entity UC is
    port(
        clk_i                 : in  std_logic;
        rst_i                 : in  std_logic;


        -- to be complted



    );
end UC;

--| Architecture |-------------------------------------------------------------
architecture fsm of UC is

    --| Types |----------------------------------------------------------------
    type state_t is (
        --General state
        INIT,
        ....

        --Init sequence
        INIT....  ,



        -- Mode Manual
        MAN_.....,

        -- Mode Automatique

        AUTO_... ,


        -- Error
        ERR
    );


    --| Signals |--------------------------------------------------------------
    -- State machine
    signal current_state_s   : state_t;
    signal next_state_s  : state_t;

    -- internal signals

begin

    --| Update state proc |----------------------------------------------------
    -- This process update the state of the state machine
    fsm_reg : process(clk_i, rst_i) is
    begin
        if(rst_i = '1') then
            current_state_s <= INIT;
        elsif(rising_edge(clk_i)) then
            current_state_s <= next_state_s;
        end if;
    end process fsm_reg;
    ---------------------------------------------------------------------------

    --| Decodeur etats futures et sorties |---------------------------------------------------
    dec_fut_sort : process(current_state_s,
                                            -- all inputs,  to be complted                    ) is
    begin
        -- Default values for generated signal
        next_state_s       <= INIT;

        -- to be complted
        -- all output  <= '0' or '1';  -- selon votre choix de valeur par defaut

        case(current_state_s) is
        --| Init |-------------------------------------------------------------
            when INIT =>

               -- to be complted
               next_state_s <= ....  ;

            when .....  =>


        --| Init sequence |----------------------------------------------------



        --| Manual sequence |--------------------------------------------------



        --| Automatic sequence |-----------------------------------------------


        --| Error |-----------------------------------------------------------

            when ERR =>


        --| For others state |-------------------------------------------------
            when others =>
               -- others signals at default value
               next_state_s <= ....  ;

        end case;
    end process dec_fut_sort;

    --| Outputs affectation |--------------------------------------------------



end fsm;
