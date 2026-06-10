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
		  cap_l_i               : in  std_logic;
		  cap_m_i               : in  std_logic;
		  cap_r_i               : in  std_logic;
		  mode_i                : in  std_logic;
		  start_i               : in  std_logic;
		  init_i                : in  std_logic;
		  nb_tour_i             : in  std_logic;
		  run_l_i               : in  std_logic;
		  run_m_i               : in  std_logic;
		  run_r_i               : in  std_logic;

		  en_mot_l_o            : out std_logic;
		  dir_mot_l_o           : out std_logic;
		  en_mot_m_o            : out std_logic;
		  dir_mot_m_o           : out std_logic;
		  en_mot_r_o            : out std_logic;
		  dir_mot_r_o           : out std_logic;
		  sel_speed_o           : out std_logic_vector(1 downto 0)



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
        MAN_STOP,
		  MAN_LEFT,
		  MAN_RIGHT,
		  MAN_BOTH,
		  MAN_MIDDLE,

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

		en_mot_l_o  <= '0';
		en_mot_m_o  <= '0';
		en_mot_r_o  <= '0';
		dir_mot_l_o <= '0';
		dir_mot_m_o <= '0';
		dir_mot_r_o <= '0';
		sel_speed_o <= "00";
		next_state_s <= INIT;
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
				when MAN_STOP =>
					en_mot_l_o <= '0';
					en_mot_m_o <= '0';
					en_mot_r_o <= '0';
					
					if(cap_m_i = '0' and run_l_i = '1' and run_m_i = '0' and run_r_i = '0') then
						next_state_s <= MAN_LEFT;
					elsif(cap_m_i = '0' and run_l_i = '0' and run_m_i = '0' and run_r_i = '1') then
						next_state_s <= MAN_RIGHT;
					elsif(cap_m_i = '0' and run_l_i = '1' and run_m_i = '0' and run_r_i = '1') then
						next_state_s <= MAN_BOTH;
					elsif(cap_l_i = '0' and cap_r_i = '0' and run_l_i = '0' 
							and run_m_i = '1' and run_r_i = '0') then
						next_state_s <= MAN_MIDDLE;
					else
						next_state_s <= MAN_STOP;
					end if;
				
				when MAN_LEFT =>
					en_mot_l_o <= '1';
					en_mot_m_o <= '0';
					en_mot_r_o <= '0';
					
					dir_mot_l_o <= '0';
					sel_speed_o <= "00";
					
					if(cap_m_i = '1' or run_l_i = '0' or run_m_i = '1') then
						next_state_s <= MAN_STOP;
					elsif(cap_m_i = '0' and run_l_i = '1' and run_m_i = '0' and run_r_i = '1') then
						next_state_s <= MAN_BOTH;
					else
						next_state_s <= MAN_LEFT;
					end if;
					
				when MAN_BOTH =>
					en_mot_l_o <= '1';
					en_mot_m_o <= '0';
					en_mot_r_o <= '1';
					
					dir_mot_l_o <= '0';
					dir_mot_r_o <= '0';
					sel_speed_o <= "00";
					
					if(cap_m_i = '1' or run_m_i = '1' or (run_l_i = '0' and run_r_i = '0')) then
						next_state_s <= MAN_STOP;
					elsif(cap_m_i = '0' and run_l_i = '1' and run_m_i = '0' and run_r_i = '0') then
						next_state_s <= MAN_LEFT;
					elsif(cap_m_i = '0' and run_l_i = '0' and run_m_i = '0' and run_r_i = '1') then
						next_state_s <= MAN_RIGHT;
					else
						next_state_s <= MAN_BOTH;
					end if;
					
				when MAN_RIGHT =>
					en_mot_l_o <= '0';
					en_mot_m_o <= '0';
					en_mot_r_o <= '1';
					
					dir_mot_r_o <= '0';
					sel_speed_o <= "00";
					
					if(cap_m_i = '1' or run_r_i = '0' or run_m_i = '1') then
						next_state_s <= MAN_STOP;
					elsif(cap_m_i = '0' and run_l_i = '1' and run_m_i = '0' and run_r_i = '1') then
						next_state_s <= MAN_BOTH;
					else
						next_state_s <= MAN_RIGHT;
					end if;
					
				when MAN_MIDDLE =>
					en_mot_l_o <= '0';
					en_mot_m_o <= '1';
					en_mot_r_o <= '0';
					
					dir_mot_m_o <= '0';
					sel_speed_o <= "00";
					
					if(cap_l_i = '1' or cap_r_i = '1' or run_l_i = '1' 
						or run_m_i = '0' or run_r_i = '1') then
						next_state_s <= MAN_STOP;
					else
						next_state_s <= MAN_MIDDLE;
					end if;
						
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
