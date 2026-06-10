-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : mot_pap_tb.vhd
--
-- Description  : Testbench for the mot pap top labo
--
-- Auteur       : L. Fournier
-- Date         : 28.05.2024
-- Version      : 1.0
--
-- Used in      : Laboratoire de SysLog2/CSN
--
--| Modifications |------------------------------------------------------------
-- Version   Auteur      Date               Description
-- 1.0       LFR         28.05.2024         First version.
-------------------------------------------------------------------------------

--| Librarys |-----------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
use work.project_logger_pkg.all;
use work.mot_pap_tb_pkg.all;
use work.test_mot_pap_pkg.all;
-------------------------------------------------------------------------------

--| Entity |-------------------------------------------------------------------
entity mot_pap_tb is
    generic(
        TESTCASE : integer := 0
    );
end mot_pap_tb;
-------------------------------------------------------------------------------

--| Architecture |-------------------------------------------------------------
architecture testbench of mot_pap_tb is

    --| Signals |--------------------------------------------------------------
    -- Tests
    signal clk_sti      : std_logic;
    signal rst_sti      : std_logic;
    signal stimulis_sti : mot_pap_stimulis_t;
    signal observed_obs : mot_pap_observed_t;
    -- Simulation
    signal sim_end_s    : boolean := false;
    ---------------------------------------------------------------------------

    --| Components |-----------------------------------------------------------
    -- DUT
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

    -- Model
    component mot_pap_model is
    port(
        clk_i 	      : in  std_logic;
        rst_i	      : in  std_logic;
        sim_end_i     : in  boolean;
        force_empty_i : in  std_logic;
        force_full_i  : in  std_logic;
        phase_i       : in  phase_t;
        cap_o	      : out	std_logic
    );
    end component;
    ---------------------------------------------------------------------------

begin

    --| Clock generation |-----------------------------------------------------
    --CreateClock(clk_sti, CLK_PERIOD);
    CLK_GEN : process is
    begin
        while not(sim_end_s) loop
            clk_sti <= '0', '1' after CLK_PERIOD/2;
            wait for CLK_PERIOD;
        end loop;
        wait;
    end process CLK_GEN;
    ---------------------------------------------------------------------------

    --| Components instanciation |---------------------------------------------
    command_mot_pap : entity work.cmd_mot_pap(struct)
    generic map(
        SIMULATION => true
    )
    port map(
        clk_i       => clk_sti,
        rst_i       => rst_sti,
        cap_l_i     => observed_obs.captor.left,
        cap_m_i     => observed_obs.captor.mid,
        cap_r_i     => observed_obs.captor.right,
        mode_i      => stimulis_sti.mode,
        start_i     => stimulis_sti.start,
        init_i      => stimulis_sti.init,
        nb_tour_i   => stimulis_sti.nb_tour,
        run_l_i     => stimulis_sti.run.left,
        run_m_i     => stimulis_sti.run.mid,
        run_r_i     => stimulis_sti.run.right,
        en_l_o      => observed_obs.motor.left.en,
        dir_l_o     => observed_obs.motor.left.dir,
        en_m_o      => observed_obs.motor.mid.en,
        dir_m_o     => observed_obs.motor.mid.dir,
        en_r_o      => observed_obs.motor.right.en,
        dir_r_o     => observed_obs.motor.right.dir,
        sel_speed_o => observed_obs.speed,
        err_o       => observed_obs.err
    );

    ctrl_mot_l : entity work.controller_mot_pap(struct)
    generic map(
        SIMULATION => true
    )
    port map(
        clk_i        => clk_sti,
        rst_i        => rst_sti,
        en_i         => observed_obs.motor.left.en,
        dir_i        => observed_obs.motor.left.dir,
        full_nHalf_i => '0',
        sel_speed_i  => observed_obs.speed,
        a_o          => observed_obs.motor.left.phase.a,
        b_o          => observed_obs.motor.left.phase.b
    );

    ctrl_mot_m : entity work.controller_mot_pap(struct)
    generic map(
        SIMULATION => true
    )
    port map(
        clk_i        => clk_sti,
        rst_i        => rst_sti,
        en_i         => observed_obs.motor.mid.en,
        dir_i        => observed_obs.motor.mid.dir,
        full_nHalf_i => '0',
        sel_speed_i  => observed_obs.speed,
        a_o          => observed_obs.motor.mid.phase.a,
        b_o          => observed_obs.motor.mid.phase.b
    );

    ctrl_mot_r : entity work.controller_mot_pap(struct)
    generic map(
        SIMULATION => true
    )
    port map(
        clk_i        => clk_sti,
        rst_i        => rst_sti,
        en_i         => observed_obs.motor.right.en,
        dir_i        => observed_obs.motor.right.dir,
        full_nHalf_i => '0',
        sel_speed_i  => observed_obs.speed,
        a_o          => observed_obs.motor.right.phase.a,
        b_o          => observed_obs.motor.right.phase.b
    );

    MODEL_MOT_L : entity work.mot_pap_model(model)
    port map(
        clk_i 	      => clk_sti,
        rst_i	      => rst_sti,
        sim_end_i     => sim_end_s,
        force_empty_i => stimulis_sti.force_empty.left,
        force_full_i  => stimulis_sti.force_full.left,
        phase_i       => observed_obs.motor.left.phase,
        cap_o	      => observed_obs.captor.left
    );

    MODEL_MOT_M : entity work.mot_pap_model(model)
    port map(
        clk_i 	      => clk_sti,
        rst_i	      => rst_sti,
        sim_end_i     => sim_end_s,
        force_empty_i => stimulis_sti.force_empty.mid,
        force_full_i  => stimulis_sti.force_full.mid,
        phase_i       => observed_obs.motor.mid.phase,
        cap_o	      => observed_obs.captor.mid
    );

    MODEL_MOT_R : entity work.mot_pap_model(model)
    port map(
        clk_i 	      => clk_sti,
        rst_i	      => rst_sti,
        sim_end_i     => sim_end_s,
        force_empty_i => stimulis_sti.force_empty.right,
        force_full_i  => stimulis_sti.force_full.right,
        phase_i       => observed_obs.motor.right.phase,
        cap_o	      => observed_obs.captor.right
    );
    ---------------------------------------------------------------------------

    --| Simulation process |---------------------------------------------------
    stimulis_proc : process is
        --| Reset sequence |---------------------------------------------------
        procedure reset_seq(signal rst      : out std_logic;
                            signal stimulis : out mot_pap_stimulis_t) is
        begin
            rst                     <= '1';
            stimulis.force_empty    <= (others => '0');
            stimulis.force_full     <= (others => '0');
            stimulis.run            <= (others => '0');
            stimulis.mode           <= '0';
            stimulis.start          <= '0';
            stimulis.init           <= '0';
            stimulis.nb_tour        <= "000";
            stimulis.force_full.mid <= '1';
            cycle_fall(clk_sti, 1);
            stimulis.force_full.mid <= '0';
            cycle_fall(clk_sti, 1);
            rst                     <= '0';
            cycle_fall(clk_sti, 1);
        end reset_seq;
        -----------------------------------------------------------------------
    begin
        -- User notification
        logger.log_note(
            "" & CR &
            ">> Start of simulation"
        );

        -- Reset system at the beginning
        reset_seq(rst_sti, stimulis_sti);
        test_init_at_start(clk_sti, observed_obs, stimulis_sti);

        case TESTCASE is
            when 0 => -- run all tests
                test_init(clk_sti, observed_obs, stimulis_sti);
                test_manual(clk_sti, observed_obs, stimulis_sti);
                test_auto(clk_sti, observed_obs, stimulis_sti);
                test_error(clk_sti, observed_obs, stimulis_sti);
            when 1 =>
                test_init(clk_sti, observed_obs, stimulis_sti);
            when 2 =>
                test_manual(clk_sti, observed_obs, stimulis_sti);
            when 3 =>
                test_auto(clk_sti, observed_obs, stimulis_sti);
            when 4 =>
                test_error(clk_sti, observed_obs, stimulis_sti);
            when others =>
                null;
        end case;
        wait for 100 ns;
        sim_end_s <= true;
        wait for 100 ns;
        logger.final_report;
        wait;
    end process stimulis_proc;
    ---------------------------------------------------------------------------

    --| verif process |--------------------------------------------------------
    verif_init_left_proc : process is
    begin
        while not(sim_end_s) loop
            cycle_rise(clk_sti, 1);

            -- Wait init request
            wait until rising_edge(stimulis_sti.init)or(sim_end_s = true);
            if(sim_end_s = true) then
                exit;
            end if;

            -- test if the left motor is free, if not the motor must move until its free
            if(observed_obs.captor.left = '1')and(observed_obs.captor.mid = '0') then
                -- Wait for the motor to be free (timeout consit of the time needed for
                -- the motor to be free even if an other motor is being initalized first)
                wait until(observed_obs.captor.left = '0')or(sim_end_s = true) for TIMEOUT;
                -- The motor is still not free after the time needed to be initialized
                if(observed_obs.captor.left = '1') then
                    logger.log_error(
                        ""
                        & CR &
                        ">> Init requested with motor left not free " &
                        "but motor left didnt move"
                    );
                else
                    wait_nb_step(clk_sti, 1);
                    if(observed_obs.motor.left.en = '1') then
                        logger.log_error(
                            ""
                            & CR &
                            ">> Init motor left done " &
                            "but motor left continue to move"
                        );
                    end if;
                end if;
            end if;
        end loop;
        wait;
    end process verif_init_left_proc;

    verif_init_mid_proc : process is
    begin

        while not(sim_end_s) loop
            cycle_rise(clk_sti, 1);

            -- Wait init request
            wait until rising_edge(stimulis_sti.init)or(sim_end_s = true);
            if(sim_end_s = true) then
                exit;
            end if;

            -- test if the left motor is free, if not the motor must move until its free
            if(observed_obs.captor.mid = '1')and(observed_obs.captor.left = '0')and(observed_obs.captor.right = '0') then
                -- Wait for the motor to be free (timeout consit of the time needed for
                -- the motor to be free even if an other motor is being initalized first)
                wait until(observed_obs.captor.mid = '0')or(sim_end_s = true) for TIMEOUT;
                -- The motor is still not free after the time needed to be initialized
                if(observed_obs.captor.mid = '1') then
                    logger.log_error(
                        ""
                        & CR &
                        ">> Init requested with motor mid not free " &
                        "but motor mid didnt move"
                    );
                else
                    wait_nb_step(clk_sti, 1);
                    if(observed_obs.motor.mid.en = '1') then
                        logger.log_error(
                            ""
                            & CR &
                            ">> Init motor mid done " &
                            "but motor mid continue to move"
                        );
                    end if;
                end if;
            end if;
        end loop;
        wait;
    end process verif_init_mid_proc;

    verif_init_right_proc : process is
    begin
        while not(sim_end_s) loop
            cycle_rise(clk_sti, 1);

            -- Wait init request
            wait until rising_edge(stimulis_sti.init)or(sim_end_s = true);
            if(sim_end_s = true) then
                exit;
            end if;

            -- test if the left motor is free, if not the motor must move until its free
            if(observed_obs.captor.right = '1')and(observed_obs.captor.mid = '0') then
                -- Wait for the motor to be free (timeout consit of the time needed for
                -- the motor to be free even if an other motor is being initalized first)
                wait until(observed_obs.captor.right = '0')or(sim_end_s = true) for TIMEOUT;
                -- The motor is still not free after the time needed to be initialized
                if(observed_obs.captor.right = '1') then
                    logger.log_error(
                        ""
                        & CR &
                        ">> Init requested with motor right not free " &
                        "but motor right didnt move"
                    );
                else
                    wait_nb_step(clk_sti, 1);
                    if(observed_obs.motor.right.en = '1') then
                        logger.log_error(
                            ""
                            & CR &
                            ">> Init motor right done " &
                            "but motor right continue to move"
                        );
                    end if;
                end if;
            end if;
        end loop;
        wait;
    end process verif_init_right_proc;
    ---------------------------------------------------------------------------


    --| verif process |--------------------------------------------------------
    verif_manual_proc : process is
    begin
        while not(sim_end_s) loop
            cycle_rise(clk_sti, 1);
            wait for 1 ns;

            -- Test if the middle and another motor are requested to move,
            -- the en mean the request was accepted wich is not ok
            -- allow to test two request done when all the motor are on an
            -- empty part
            if(observed_obs.motor.mid.en = '1') then

                if(observed_obs.motor.right.en = '1')and(observed_obs.motor.left.en = '1') then
                    logger.log_error(
                        ""
                        & CR &
                        ">> All Motors tried to move at the same time"
                    );
                    wait;
                end if;

                if(observed_obs.motor.left.en = '1') then
                    logger.log_error(
                        ""
                        & CR &
                        ">> Motor left and mid tried to move at the same time"
                    );
                    wait;
                end if;

                if(observed_obs.motor.right.en = '1') then
                    logger.log_error(
                        ""
                        & CR &
                        ">> Motor right and mid tried to move at the same time"
                    );
                    wait;
                end if;
            end if;
        end loop;
        wait;
    end process verif_manual_proc;
    ---------------------------------------------------------------------------

    --| verif dir process |--------------------------------------------------------
    verif_dir_left_proc : process is
    begin

        while not(sim_end_s) loop
            cycle_rise(clk_sti, 1);
            wait for 1 ns;

            if(stimulis_sti.mode = '0') then
                if(observed_obs.motor.left.en = '1') then
                    if(observed_obs.motor.left.dir = '1') then
                        logger.log_error(
                            ""
                            & CR &
                            ">> Motor left moved with dir '1' but dir must be '0' in manual mode"
                        );
                        wait;
                    end if;
                end if;
            else
                if(observed_obs.motor.left.en = '1') then
                    if(observed_obs.motor.left.dir = '1') then
                        logger.log_error(
                            ""
                            & CR &
                            ">> Motor left moved with dir '1' but dir must be '0' in auto mode"
                        );
                        wait;
                    end if;
                end if;
            end if;
        end loop;
        wait;
    end process verif_dir_left_proc;

    verif_dir_right_proc : process is
    begin

        while not(sim_end_s) loop
            cycle_rise(clk_sti, 1);
            wait for 1 ns;

            if(stimulis_sti.mode = '0') then
                if(observed_obs.motor.right.en = '1') then
                    if(observed_obs.motor.right.dir = '1') then
                        logger.log_error(
                            ""
                            & CR &
                            ">> Motor right moved with dir '1' but dir must be '0' in manual mode"
                        );
                        wait;
                    end if;
                end if;
            else

            end if;
        end loop;
        wait;
    end process verif_dir_right_proc;

    verif_dir_mid_proc : process is
    begin

        while not(sim_end_s) loop
            cycle_rise(clk_sti, 1);
            wait for 1 ns;
            if(stimulis_sti.mode = '0') then
                if(observed_obs.motor.mid.en = '1') then
                    if(observed_obs.motor.mid.dir = '1') then
                        logger.log_error(
                            ""
                            & CR &
                            ">> Motor mid moved with dir '1' but dir must be '0' in manual mode"
                        );
                        wait;
                    end if;
                end if;
            else
                if(observed_obs.motor.mid.en = '1') then
                    if(observed_obs.motor.mid.dir = '0') then
                        logger.log_error(
                            ""
                            & CR &
                            ">> Motor mid moved with dir '0' but dir must be '1' in auto mode"
                        );
                        wait;
                    end if;
                end if;
            end if;
        end loop;
        wait;
    end process verif_dir_mid_proc;

    verif_speed_man_proc : process is
    begin

        while not(sim_end_s) loop
            cycle_rise(clk_sti, 1);
            wait for 1 ns;
            if(stimulis_sti.mode = '0') then
                if(observed_obs.speed = "00") then
                else
                    logger.log_error(
                        ""
                        & CR &
                        ">> Speed is not 00 in manual mode"
                    );
                    wait;
                end if;

            end if;
        end loop;
        wait;
    end process verif_speed_man_proc;

    verif_speed_auto_left_proc : process is
    begin
        while not(sim_end_s) loop
            cycle_rise(clk_sti, 1);
            wait for 1 ns;
            wait until rising_edge(stimulis_sti.start)or(sim_end_s = true);
            if(sim_end_s = true) then
                exit;
            end if;
            if(observed_obs.captor.mid = '0')and(observed_obs.captor.left = '0')and(observed_obs.captor.right = '0') then
                wait until(observed_obs.motor.mid.en = '1')or
                        (observed_obs.motor.left.en = '1')or
                        (observed_obs.motor.right.en = '1')or(sim_end_s = true);
                if(sim_end_s = true) then
                    exit;
                elsif(observed_obs.motor.left.en = '1')or(observed_obs.motor.right.en = '1') then
                    logger.log_error(
                        ""
                        & CR &
                        ">> Auto mode didnt start with the middle motor"
                    );
                else
                    wait until(observed_obs.motor.left.en = '1')or
                            (observed_obs.motor.right.en = '1')or(sim_end_s = true);
                    if(sim_end_s = true) then
                        exit;
                    elsif(observed_obs.motor.right.en = '1') then
                        logger.log_error(
                            ""
                            & CR &
                            ">> Auto mode second motor must be the left, not the right"
                        );
                    end if;
                end if;
            end if;
        end loop;
        wait;
    end process verif_speed_auto_left_proc;

    ---------------------------------------------------------------------------


    --| verif process |--------------------------------------------------------
    verif_auto_proc : process is
        variable motor_free_v : boolean := false;
    begin

        while not(sim_end_s) loop
            cycle_rise(clk_sti, 1);
            wait for 1 ns;

            -- Mode auto
            if(stimulis_sti.mode = '1') then

                -- Wait for start request
                wait until rising_edge(stimulis_sti.start)or(sim_end_s = true);
                if(sim_end_s = true) then
                    exit;
                end if;

                wait until(observed_obs.motor.mid.en = '1')or(sim_end_s = true);
                if(sim_end_s = true) then
                    exit;
                end if;

                motor_free_v := is_motor_free(observed_obs.captor);

                if(motor_free_v) then
                else
                    logger.log_error(
                        ""
                        & CR &
                        ">> Mode auto started but the motor were not all free"
                    );
                end if;
            end if;
        end loop;
        wait;
    end process verif_auto_proc;
    ---------------------------------------------------------------------------


    --| verif process |--------------------------------------------------------
    verif_error_proc : process is
        variable motor_unknown_v : boolean := false;
    begin

        while not(sim_end_s) loop
            cycle_rise(clk_sti, 1);
            wait for 1 ns;

            motor_unknown_v := is_motor_unknown(observed_obs.captor);

            -- Motor are in an error config
            if(motor_unknown_v = true) then
                if(stimulis_sti.mode = '0')and(stimulis_sti.init = '0') then
                    -- No error if mode manual without init
                else
                    cycle_fall(clk_sti, 10);
                    if(observed_obs.err = '0') then
                        logger.log_error(
                            ""
                            & CR &
                            ">> Motor are in a unknown config but error signal is low"
                        );
                    wait;
                    end if;
                end if;
            end if;
        end loop;
        wait;
    end process verif_error_proc;

    verif_error2_proc : process is
        variable motor_unknown_v : boolean := false;
    begin

        while not(sim_end_s) loop
            cycle_rise(clk_sti, 1);
            wait for 1 ns;

            if(observed_obs.err = '1') then
            wait until(observed_obs.err = '0')or(stimulis_sti.init = '1')or(sim_end_s = true);
                if(sim_end_s = true) then
                    exit;
                elsif(stimulis_sti.init = '0') then
                    logger.log_error(
                        ""
                        & CR &
                        ">> Error signal fall without an init request"
                    );
                    wait;
                end if;
             end if;
        end loop;
        wait;
    end process verif_error2_proc;
    ---------------------------------------------------------------------------

    --| verif process |--------------------------------------------------------
    verif_motor_proc : process is
    begin
        while not(sim_end_s) loop
            cycle_rise(clk_sti, 1);
            wait for 1 ns;

            -- Test at every clock if a motor is enabled when his neigbour doesnt
            -- allow it
            if(observed_obs.captor.mid = '1') then
                if(observed_obs.motor.left.en = '1') then
                    logger.log_error(
                        ""
                        & CR &
                        ">> Motor left try to move but motor mid block him"
                    );
                end if;

                if(observed_obs.motor.right.en = '1') then
                    logger.log_error(
                        ""
                        & CR &
                        ">> Motor right try to move but motor mid block him"
                    );
                end if;
            end if;

            if(observed_obs.captor.left = '1') then
                if(observed_obs.motor.mid.en = '1') then
                    logger.log_error(
                        ""
                        & CR &
                        ">> Motor mid try to move but motor left block him"
                    );
                end if;
            end if;

            if(observed_obs.captor.right = '1') then
                if(observed_obs.motor.mid.en = '1') then
                    logger.log_error(
                        ""
                        & CR &
                        ">> Motor mid try to move but motor right block him"
                    );
                end if;
            end if;
        end loop;
        wait;
    end process verif_motor_proc;
    ---------------------------------------------------------------------------

end testbench;
-------------------------------------------------------------------------------
