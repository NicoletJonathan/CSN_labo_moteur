-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : UC.vhd
--
-- Description  : UC pour la commande des 3 moteurs pas-a-pas
--
-- Auteur       : Jonathan Nicolet & Robin Forestier
-- Date         : 14.06.2026
-- Version      : 1.0
--
-- Utilise dans : Labo moteur pas-à-pas (MSS cplx)
--
--| Modifications |------------------------------------------------------------
-- Version   Auteur      Date               Description
--
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

--| Entity |-------------------------------------------------------------------
ENTITY UC IS
	PORT (
		clk_i : IN STD_LOGIC;
		rst_i : IN STD_LOGIC;

		-- Entrées externes
		cap_l_i : IN STD_LOGIC;
		cap_m_i : IN STD_LOGIC;
		cap_r_i : IN STD_LOGIC;
		mode_i : IN STD_LOGIC;
		start_i : IN STD_LOGIC;
		init_i : IN STD_LOGIC;
		run_l_i : IN STD_LOGIC;
		run_m_i : IN STD_LOGIC;
		run_r_i : IN STD_LOGIC;

		-- Entrées d'état (venant de l'UT)
		vitesse_max_i : IN STD_LOGIC;
		vitesse_min_i : IN STD_LOGIC;
		fin_de_tour_i : IN STD_LOGIC;
		tour_complet_i : IN STD_LOGIC;
		fin_seq_auto_i : IN STD_LOGIC;
		dernier_tour_i : IN STD_LOGIC;
		moteur_i : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

		-- Sorties de commande (vers l'UT)
		en_mot_m_o : OUT STD_LOGIC;
		en_mot_r_o : OUT STD_LOGIC;
		en_mot_l_o : OUT STD_LOGIC;
		en_mot_change_o : OUT STD_LOGIC;
		inc_moteur_o : OUT STD_LOGIC;
		load_moteur_o : OUT STD_LOGIC;
		dec_tour_o : OUT STD_LOGIC;
		load_tour_o : OUT STD_LOGIC;
		dec_vitesse_o : OUT STD_LOGIC;
		inc_vitesse_o : OUT STD_LOGIC;
		load_vitesse_o : OUT STD_LOGIC;
		inc_n_encoches_o : OUT STD_LOGIC;
		load_n_encoches_o : OUT STD_LOGIC;

		-- Sortie externe
		err_o : OUT STD_LOGIC
	);
END UC;

--| Architecture |-------------------------------------------------------------
ARCHITECTURE fsm OF UC IS

	--| Types |----------------------------------------------------------------
	TYPE state_t IS (
		--General state
		INIT,

		--Init sequence
		INIT_SEQUENCE,
		INIT_TRY_MIDDLE,
		INIT_MIDDLE,
		INIT_TRY_RIGHT,
		INIT_RIGHT,
		INIT_TRY_LEFT,
		INIT_LEFT,
		INIT_REQUEST,

		-- Mode Manual
		MAN_STOP,
		MAN_LEFT,
		MAN_RIGHT,
		MAN_BOTH,
		MAN_MIDDLE,

		-- Mode Automatique
		AUTO_INIT,
		AUTO_CHECK,
		AUTO_WAIT_CAP_LOW,
		AUTO_EN_LEFT,
		AUTO_EN_MIDDLE,
		AUTO_EN_RIGHT,
		AUTO_WAIT_CAP_HIGH,
		AUTO_STOP,
		AUTO_INC_SPEED,
		AUTO_DEC_SPEED,
		AUTO_END_TOUR,
		AUTO_DEC_TOUR,
		AUTO_NEXT,

		-- Error
		ERR
	);
	--| Signals |--------------------------------------------------------------
	-- State machine
	SIGNAL current_state_s : state_t;
	SIGNAL next_state_s : state_t;

BEGIN

	--| Update state proc |----------------------------------------------------
	-- This process update the state of the state machine
	fsm_reg : PROCESS (clk_i, rst_i) IS
	BEGIN
		IF (rst_i = '1') THEN
			current_state_s <= INIT;
		ELSIF (rising_edge(clk_i)) THEN
			current_state_s <= next_state_s;
		END IF;
	END PROCESS fsm_reg;
	---------------------------------------------------------------------------

	--| Decodeur etats futures et sorties |---------------------------------------------------
	dec_fut_sort : PROCESS (current_state_s, cap_l_i, cap_m_i, cap_r_i, mode_i, start_i, init_i, run_l_i, run_m_i, run_r_i, vitesse_max_i, vitesse_min_i, fin_de_tour_i, tour_complet_i, fin_seq_auto_i, dernier_tour_i, moteur_i) IS
	BEGIN
		-- Default values for generated signal
		-- (at default motors are off, set to minimal speed and anti-clockwise)
		next_state_s <= INIT;

		en_mot_m_o <= '0';
		en_mot_r_o <= '0';
		en_mot_l_o <= '0';
		en_mot_change_o <= '0';
		inc_moteur_o <= '0';
		load_moteur_o <= '0';
		dec_tour_o <= '0';
		load_tour_o <= '0';
		dec_vitesse_o <= '0';
		inc_vitesse_o <= '0';
		load_vitesse_o <= '0';
		inc_n_encoches_o <= '0';
		load_n_encoches_o <= '0';
		err_o <= '0';

		CASE(current_state_s) IS
			--| Init |-------------------------------------------------------------
			WHEN INIT =>
			en_mot_change_o <= '1';
			next_state_s <= INIT_SEQUENCE;

			--| Init sequence |----------------------------------------------------
			-- move motors if needed so that they don't block each others
			WHEN INIT_SEQUENCE =>
			en_mot_change_o <= '1';
			load_vitesse_o <= '1'; -- vitesse initial à 0 (will load 0 in the counter)
			IF (cap_m_i = '1' AND (cap_l_i = '1' OR cap_r_i = '1')) THEN -- cannot init
				next_state_s <= ERR;
			ELSE
				next_state_s <= INIT_TRY_MIDDLE;
			END IF;

			WHEN INIT_TRY_MIDDLE => -- test if middle motoris proprely placed. If it is the case, go to INIT_MIDDLE. then do the same for the others 2.
			en_mot_change_o <= '1';
			IF (cap_m_i = '1') THEN
				next_state_s <= INIT_MIDDLE;
			ELSE
				next_state_s <= INIT_TRY_RIGHT;
			END IF;

			WHEN INIT_MIDDLE =>
			en_mot_change_o <= '1';
			IF (cap_l_i = '1' OR cap_r_i = '1') THEN
				next_state_s <= ERR;
				en_mot_m_o <= '0';
			ELSIF (cap_m_i = '1') THEN
				next_state_s <= INIT_MIDDLE;
				en_mot_m_o <= '1';
			ELSE
				next_state_s <= INIT_TRY_RIGHT;
			END IF;

			WHEN INIT_TRY_RIGHT =>
			en_mot_change_o <= '1';
			IF (cap_r_i = '1') THEN
				next_state_s <= INIT_RIGHT;
			ELSE
				next_state_s <= INIT_TRY_LEFT;
			END IF;

			WHEN INIT_RIGHT =>
			en_mot_change_o <= '1';
			IF (cap_m_i = '1') THEN
				en_mot_r_o <= '0';
				next_state_s <= ERR;
			ELSIF (cap_r_i = '1') THEN
				en_mot_r_o <= '1';
				next_state_s <= INIT_RIGHT;
			ELSE
				next_state_s <= INIT_TRY_LEFT;
			END IF;

			WHEN INIT_TRY_LEFT =>
			en_mot_change_o <= '1';
			IF (cap_l_i = '1') THEN
				next_state_s <= INIT_LEFT;
			ELSE
				next_state_s <= INIT_REQUEST; -- all motors are good, we can continue
			END IF;

			WHEN INIT_LEFT =>
			en_mot_change_o <= '1';
			IF (cap_m_i = '1') THEN
				en_mot_l_o <= '0';
				next_state_s <= ERR;
			ELSIF (cap_l_i = '1') THEN
				en_mot_l_o <= '1';
				next_state_s <= INIT_LEFT;
			ELSE
				next_state_s <= INIT_REQUEST;
			END IF;

			WHEN INIT_REQUEST => -- Will choose whether we want to INIT again, go in MANUAL mode or in AUTO mode (if allowed).
			en_mot_change_o <= '1';
			IF (init_i = '1') THEN
				next_state_s <= INIT_SEQUENCE;
			ELSIF (mode_i = '0') THEN
				next_state_s <= MAN_STOP;
			ELSIF (start_i = '0') THEN -- mode auto but start not true -> we stay here.
				next_state_s <= INIT_REQUEST;
			ELSIF ( cap_m_i = '1' AND (cap_l_i = '1' OR cap_r_i = '1') ) THEN
				next_state_s <= ERR;
			ELSIF (cap_l_i = '0' AND cap_m_i = '0' AND cap_r_i = '0') THEN -- everything good, go in AUTO mode
				next_state_s <= AUTO_INIT;
			ELSE
				next_state_s <= INIT; -- INIT again cause motors are nod proprely placed
			END IF;

			--| Manual sequence |--------------------------------------------------
			-- mode_i = '1' while in any of the MAN state will make us leave MANUAL mode and go to INIT_SEQUENCE
			WHEN MAN_STOP => -- initial MANUAL state, will check if we want to move a motor and if we are allowed to
			en_mot_change_o <= '1';
			en_mot_m_o <= '0';
			en_mot_r_o <= '0';
			en_mot_l_o <= '0';
			IF (init_i = '1') THEN
				next_state_s <= INIT_SEQUENCE;
			ELSIF (mode_i = '1') THEN
				next_state_s <= INIT_REQUEST;
			ELSIF (cap_m_i = '0' AND run_l_i = '1' AND run_m_i = '0' AND run_r_i = '0') THEN
				next_state_s <= MAN_LEFT;
			ELSIF (cap_m_i = '0' AND run_l_i = '0' AND run_m_i = '0' AND run_r_i = '1') THEN
				next_state_s <= MAN_RIGHT;
			ELSIF (cap_m_i = '0' AND run_l_i = '1' AND run_m_i = '0' AND run_r_i = '1') THEN
				next_state_s <= MAN_BOTH;
			ELSIF (cap_l_i = '0' AND cap_r_i = '0' AND run_l_i = '0' AND run_m_i = '1' AND run_r_i = '0') THEN
				next_state_s <= MAN_MIDDLE;
			ELSE
				next_state_s <= MAN_STOP;
			END IF;

			WHEN MAN_LEFT => -- can switch to MAN_BOTH if right boutton is pressed, or to MAN_STOP
			en_mot_change_o <= '1';
			en_mot_l_o <= '1';
			IF (mode_i = '1') THEN
				en_mot_l_o <= '0';
				next_state_s <= INIT_REQUEST;
			ELSIF (cap_m_i = '1' OR run_l_i = '0' OR run_m_i = '1') THEN
				en_mot_l_o <= '0';
				next_state_s <= MAN_STOP;
			ELSIF (cap_m_i = '0' AND run_l_i = '1' AND run_m_i = '0' AND run_r_i = '1') THEN
				next_state_s <= MAN_BOTH;
			ELSE
				en_mot_l_o <= '1';
				next_state_s <= MAN_LEFT;
			END IF;

			WHEN MAN_RIGHT => -- can switch to MAN_BOTH if left boutton is pressed, or to MAN_STOP
			en_mot_change_o <= '1';
			en_mot_r_o <= '1';
			IF (mode_i = '1') THEN
				en_mot_r_o <= '0';
				next_state_s <= INIT_REQUEST;
			ELSIF (cap_m_i = '1' OR run_r_i = '0' OR run_m_i = '1') THEN
				en_mot_r_o <= '0';
				next_state_s <= MAN_STOP;
			ELSIF (cap_m_i = '0' AND run_l_i = '1' AND run_m_i = '0' AND run_r_i = '1') THEN
				en_mot_l_o <= '1';
				next_state_s <= MAN_BOTH;
			ELSE
				en_mot_r_o <= '1';
				next_state_s <= MAN_RIGHT;
			END IF;

			WHEN MAN_BOTH => -- can swith to MAN_LEFT, RIGHT or STOP
			en_mot_change_o <= '1';
			en_mot_l_o <= '1';
			en_mot_r_o <= '1';
			IF (mode_i = '1') THEN
				en_mot_l_o <= '0';
				en_mot_r_o <= '0';
				next_state_s <= INIT_REQUEST;
			ELSIF (cap_m_i = '1' OR run_m_i = '1' OR (run_l_i = '0' AND run_r_i = '0')) THEN
				en_mot_l_o <= '0';
				en_mot_r_o <= '0';
				next_state_s <= MAN_STOP;
			ELSIF (cap_m_i = '0' AND run_l_i = '1' AND run_m_i = '0' AND run_r_i = '0') THEN
				en_mot_r_o <= '0';
				next_state_s <= MAN_LEFT;
			ELSIF (cap_m_i = '0' AND run_l_i = '0' AND run_m_i = '0' AND run_r_i = '1') THEN
				en_mot_l_o <= '0';
				next_state_s <= MAN_RIGHT;
			ELSE
				en_mot_l_o <= '1';
				en_mot_r_o <= '1';
				next_state_s <= MAN_BOTH;
			END IF;

			WHEN MAN_MIDDLE => -- can only switch to MAN_STOP
			en_mot_change_o <= '1';
			en_mot_m_o <= '1';
			IF (mode_i = '1') THEN
				en_mot_m_o <= '0';
				next_state_s <= INIT_REQUEST;
			ELSIF (cap_l_i = '1' OR cap_r_i = '1' OR run_l_i = '1'
				OR run_m_i = '0' OR run_r_i = '1') THEN
				en_mot_m_o <= '0';
				next_state_s <= MAN_STOP;
			ELSE
				en_mot_m_o <= '1';
				next_state_s <= MAN_MIDDLE;
			END IF;

			--| Automatic sequence |-----------------------------------------------
			WHEN AUTO_INIT => -- init the UT for this mode
			en_mot_change_o <= '1';
			load_tour_o <= '1';
			load_vitesse_o <= '1';
			load_n_encoches_o <= '1';
			load_moteur_o <= '1';
			next_state_s <= AUTO_CHECK;

			WHEN AUTO_CHECK => -- check if error or if the number of revolutions is 0
			en_mot_change_o <= '1';
			IF (mode_i = '0') THEN
				next_state_s <= INIT_REQUEST;
			ELSIF (fin_de_tour_i = '1') then
				next_state_s <= INIT_REQUEST;
			ELSIF (cap_r_i = '1' OR cap_l_i = '1') THEN
				next_state_s <= ERR;
			ELSE
				next_state_s <= AUTO_WAIT_CAP_LOW;
			END IF;

			WHEN AUTO_WAIT_CAP_LOW => -- we go in the mode that correspond to the motor we have to run, if it is allowed to
			IF (mode_i = '0') THEN
				next_state_s <= INIT_REQUEST;
			ELSIF (cap_m_i = '0' AND moteur_i = "00") THEN
				IF (cap_l_i = '1' OR cap_r_i = '1') THEN
					next_state_s <= ERR;
				ELSE
					next_state_s <= AUTO_EN_MIDDLE;
				END IF;
			ELSIF (cap_l_i = '0' AND moteur_i = "01") THEN
				IF (cap_m_i = '1') THEN
					next_state_s <= ERR;
				ELSE
					next_state_s <= AUTO_EN_LEFT;
				END IF;
			ELSIF (cap_r_i = '0' AND moteur_i = "10") THEN
				IF (cap_m_i = '1') THEN
					next_state_s <= ERR;
				ELSE
					next_state_s <= AUTO_EN_RIGHT;
				END IF;
			ELSE
				next_state_s <= AUTO_WAIT_CAP_LOW;
			END IF;

			WHEN AUTO_EN_LEFT => -- will make the motor turn and go to AUTO_WAIT_CAP_HIGH
			en_mot_change_o <= '1';
			en_mot_l_o <= '1';
			IF (mode_i = '0') THEN
				en_mot_l_o <= '0';
				next_state_s <= INIT_REQUEST;
			ELSIF (cap_m_i = '1') THEN
				en_mot_l_o <= '0';
				next_state_s <= ERR;
			ELSIF (cap_l_i = '1') THEN
				next_state_s <= AUTO_WAIT_CAP_HIGH;
			ELSE
				en_mot_l_o <= '1';
				next_state_s <= AUTO_EN_LEFT;
			END IF;

			WHEN AUTO_EN_MIDDLE => -- will make the motor turn and go to AUTO_WAIT_CAP_HIGH
			en_mot_change_o <= '1';
			en_mot_m_o <= '1';
			IF (mode_i = '0') THEN
				en_mot_m_o <= '0';
				next_state_s <= INIT_REQUEST;
			ELSIF (cap_l_i = '1' OR cap_r_i = '1') THEN
				en_mot_m_o <= '0';
				next_state_s <= ERR;
			ELSIF (cap_m_i = '1') THEN
				next_state_s <= AUTO_WAIT_CAP_HIGH;
			ELSE
				en_mot_m_o <= '1';
				next_state_s <= AUTO_EN_MIDDLE;
			END IF;

			WHEN AUTO_EN_RIGHT => -- will make the motor turn and go to AUTO_WAIT_CAP_HIGH
			en_mot_change_o <= '1';
			en_mot_r_o <= '1';
			IF (mode_i = '0') THEN
				en_mot_r_o <= '0';
				next_state_s <= INIT_REQUEST;
			ELSIF (cap_m_i = '1') THEN
				en_mot_r_o <= '0';
				next_state_s <= ERR;
			ELSIF (cap_r_i = '1') THEN
				next_state_s <= AUTO_WAIT_CAP_HIGH;
			ELSE
				en_mot_r_o <= '1';
				next_state_s <= AUTO_EN_RIGHT;
			END IF;

			WHEN AUTO_WAIT_CAP_HIGH => -- will wait until every motors are proprely aligned (only the one running isn't) then go to AUTO_STOP
				                       -- because en_mot_change_o = '0', the motor that is running won't stop
			IF (mode_i = '0') THEN
				next_state_s <= INIT_REQUEST;
			ELSIF (cap_l_i = '0' AND cap_m_i = '0' AND cap_r_i = '0') THEN
				next_state_s <= AUTO_STOP;
			ELSE
				next_state_s <= AUTO_WAIT_CAP_HIGH;
			END IF;

			WHEN AUTO_STOP => -- will stop the motor and decide rather we need to increment the speed, decrement or simply continue
			en_mot_change_o <= '1';
			inc_n_encoches_o <= '1';
			IF (mode_i = '0') THEN
				next_state_s <= INIT_REQUEST;
			ELSIF (dernier_tour_i = '0') THEN
				IF (vitesse_max_i = '1') THEN
					next_state_s <= AUTO_END_TOUR;
				ELSE
					next_state_s <= AUTO_INC_SPEED;
				END IF;
			ELSE -- dernier_tour_i = '1'
				IF (vitesse_min_i = '1') THEN
					next_state_s <= AUTO_END_TOUR;
				ELSE
					next_state_s <= AUTO_DEC_SPEED;
				END IF;
			END IF;

			WHEN AUTO_INC_SPEED => -- at the end of the first turn, speed is max. wich means that if we are in this case we cannot be at the end of  a turn
			inc_vitesse_o <= '1';
			next_state_s <= AUTO_WAIT_CAP_LOW;

			WHEN AUTO_DEC_SPEED =>
			dec_vitesse_o <= '1';
			next_state_s <= AUTO_WAIT_CAP_LOW;

			WHEN AUTO_END_TOUR => -- will decrement the amount of revolutions left or will go to AUTO_NEXT if this motor have finished his sequence
			IF (mode_i = '0') THEN
				next_state_s <= INIT_REQUEST;
			ELSIF (tour_complet_i = '0') THEN
				next_state_s <= AUTO_WAIT_CAP_LOW;
			ELSE -- tour_complet_i = '1'
				dec_tour_o <= '1';
				load_n_encoches_o <= '1';
				IF (dernier_tour_i = '1') THEN
					next_state_s <= AUTO_NEXT;
				ELSE
					next_state_s <= AUTO_WAIT_CAP_LOW;
				END IF;
			END IF;

			WHEN AUTO_NEXT => -- will  switch to the next motor or exit AUTO mode if we have finished it
			en_mot_change_o <= '1';
			IF (moteur_i = "10") THEN
				next_state_s <= INIT_REQUEST;
			ELSE
				inc_moteur_o <= '1';
				load_tour_o <= '1';
				next_state_s <= AUTO_WAIT_CAP_LOW;
			END IF;

			--| Error |-----------------------------------------------------------

			WHEN ERR =>
			en_mot_change_o <= '1';
			en_mot_m_o <= '0';
			en_mot_r_o <= '0';
			en_mot_l_o <= '0';
			err_o <= '1';
			IF (init_i = '0' OR (cap_m_i = '1' AND (cap_l_i = '1' OR cap_r_i = '1'))) THEN
				next_state_s <= ERR;
			ELSE
				next_state_s <= INIT_SEQUENCE;
			END IF;
			
			--| For others state |-------------------------------------------------
			WHEN OTHERS =>
			-- others signals at default value
			next_state_s <= INIT;

		END CASE;

		-- To be sure that we catch every error cases, we do it outside of the MSS. We also turn of the motor immediatly instead of in ERR 1 tick later
        IF (cap_m_i = '1' AND (cap_l_i = '1' OR cap_r_i = '1')) THEN 
				next_state_s <= ERR;
				en_mot_change_o <= '1';
			    en_mot_m_o <= '0';
			    en_mot_r_o <= '0';
			    en_mot_l_o <= '0';
		END IF;
	END PROCESS dec_fut_sort;

END fsm;
