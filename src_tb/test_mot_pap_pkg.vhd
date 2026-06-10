-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : mot_pap_top_tb_pkg.vhd
--
-- Description  : Package containing the different tests procedure
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

--| Library |-------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
use work.project_logger_pkg.all;
use work.mot_pap_tb_pkg.all;
--------------------------------------------------------------------------------

--| Package |-------------------------------------------------------------------
package test_mot_pap_pkg is

    --| Test |------------------------------------------------------------------
    procedure test_init_at_start(signal clk      : in  std_logic;
                                 signal observed : in  mot_pap_observed_t;
                                 signal stimulis : out mot_pap_stimulis_t);

    procedure test_init(signal clk      : in  std_logic;
                        signal observed : in  mot_pap_observed_t;
                        signal stimulis : out mot_pap_stimulis_t);

    procedure test_manual(signal clk      : in  std_logic;
                          signal observed : in  mot_pap_observed_t;
                          signal stimulis : out mot_pap_stimulis_t);

    procedure test_auto(signal clk      : in  std_logic;
                        signal observed : in  mot_pap_observed_t;
                        signal stimulis : out mot_pap_stimulis_t);

    procedure test_error(signal clk      : in  std_logic;
                         signal observed : in  mot_pap_observed_t;
                         signal stimulis : out mot_pap_stimulis_t);
    ----------------------------------------------------------------------------

end test_mot_pap_pkg;
--------------------------------------------------------------------------------

--| Body |----------------------------------------------------------------------
package body test_mot_pap_pkg is

    --| Test |------------------------------------------------------------------
    procedure test_init_at_start(signal clk      : in  std_logic;
                                 signal observed : in  mot_pap_observed_t;
                                 signal stimulis : out mot_pap_stimulis_t) is
    begin

        -- User notification
        logger.log_note(
            "" & CR &
            ">> Test init at reset "
        );
        -- 3 step move the motor from middle full to empty
        -- (Only middle disk was set in middle full at reset) -> init done
        wait_nb_step(clk, 3);

        cycle_fall(clk, 2);

    end test_init_at_start;

    procedure test_init(signal clk      : in  std_logic;
                        signal observed : in  mot_pap_observed_t;
                        signal stimulis : out mot_pap_stimulis_t) is
    begin

        -- Wait a little bit before each test to differentiate them better on
        -- the chronogramme
        wait_nb_step(clk, 5);

        -- User notification
        logger.log_note(
            "" & CR &
            ">> Test init "
        );

        -- Set left motor on full dik part and
        -- Try an init
        cycle_fall(clk, 3);
        stimulis.force_full.right <= '1';
        cycle_fall(clk, 1);
        stimulis.force_full.right <= '0';
        stimulis.init             <= '1';
        cycle_fall(clk, 10); -- to be sure the init is taken
        stimulis.init             <= '0';
        wait_nb_step(clk, 3);

        -- Set right motor on full dik part and
        -- Try an init
        cycle_fall(clk, 3);
        stimulis.force_full.left <= '1';
        cycle_fall(clk, 1);
        stimulis.force_full.left <= '0';
        stimulis.init            <= '1';
        cycle_fall(clk, 10); -- to be sure the init is taken
        stimulis.init            <= '0';
        wait_nb_step(clk, 3);

        -- Set middle motor on full dik part and
        -- Try an init
        cycle_fall(clk, 3);
        stimulis.force_full.mid <= '1';
        cycle_fall(clk, 1);
        stimulis.force_full.mid <= '0';
        stimulis.init            <= '1';
        cycle_fall(clk, 10); -- to be sure the init is taken
        stimulis.init            <= '0';
        wait_nb_step(clk, 3);


        -- Set left and right motor on full dik part and
        -- Try an init
        cycle_fall(clk, 3);
        stimulis.force_full.right <= '1';
        stimulis.force_full.left  <= '1';
        cycle_fall(clk, 1);
        stimulis.force_full.right <= '0';
        stimulis.force_full.left  <= '0';
        stimulis.init             <= '1';
        cycle_fall(clk, 10);
        stimulis.init             <= '0';
        wait_nb_step(clk, 6);

    end test_init;

    procedure test_manual(signal clk      : in  std_logic;
                          signal observed : in  mot_pap_observed_t;
                          signal stimulis : out mot_pap_stimulis_t) is
    begin
        -- Wait a little bit before each test to differentiate them better on
        -- the chronogramme
        wait_nb_step(clk, 5);
        -- User notification
        logger.log_note(
            "" & CR &
            ">> Test manual "
        );
        -- After init -> all motor are on empty part

        -- Run the left motor for 8 step
        -- 2 step to go on a full part(started in the middle of an empty part)
        -- 5 step to go on empty (full range of a full part)
        -- 1 step to go on middle of empty
        stimulis.run.left <= '1';
        wait_nb_step(clk, 8);

        -- Try to run Mid and left together
        -- the two are in the middle of an empty part
        stimulis.run.mid  <= '1';
        wait_nb_step(clk, 2);

        -- Stop the left, and run the middle for 8 step
        -- 2 step to go on a full part(started in the middle of an empty part)
        -- 5 step to go on empty (full range of a full part)
        -- 1 step to go on middle of empty
        stimulis.run.left <= '0';
        wait_nb_step(clk, 8);

        -- Try to run Mid and right together
        -- the two are in the middle of an empty part
        stimulis.run.right  <= '1';
        wait_nb_step(clk, 2);

        -- Stop the mid, and run the left and the right for 8 step
        -- 2 step to go on a full part(started in the middle of an empty part)
        -- 5 step to go on empty (full range of a full part)
        -- 1 step to go on middle of empty
        stimulis.run.mid  <= '0';
        stimulis.run.left <= '1';
        wait_nb_step(clk, 8);

        stimulis.run.left   <= '0';
        stimulis.run.right  <= '0';
        cycle_fall(clk, 2);
    end test_manual;

    procedure test_auto(signal clk      : in  std_logic;
                        signal observed : in  mot_pap_observed_t;
                        signal stimulis : out mot_pap_stimulis_t) is
    begin
        -- Wait a little bit before each test to differentiate them better on
        -- the chronogramme
        wait_nb_step(clk, 5);
        -- User notification
        logger.log_note(
            "" & CR &
            ">> Test automatique "
        );
        stimulis.mode    <= '1';
        stimulis.nb_tour <= "011";
        wait_nb_step(clk, 1);

        stimulis.start <= '1';
        wait_nb_step(clk, 1);
        stimulis.start <= '0';
        wait_nb_step(clk, 150);

        stimulis.nb_tour <= "001";
        wait_nb_step(clk, 1);

        stimulis.start <= '1';
        wait_nb_step(clk, 1);
        stimulis.start <= '0';
        wait_nb_step(clk, 150);

    end test_auto;

    procedure test_error(signal clk      : in  std_logic;
                         signal observed : in  mot_pap_observed_t;
                         signal stimulis : out mot_pap_stimulis_t) is
    begin
        -- Wait a little bit before each test to differentiate them better on
        -- the chronogramme
        wait_nb_step(clk, 5);
        -- User notification
        logger.log_note(
            "" & CR &
            ">> Test error "
        );

        -- Set all motor to a full part
        cycle_fall(clk, 3);
        stimulis.force_full.right <= '1';
        stimulis.force_full.left  <= '1';
        stimulis.force_full.mid   <= '1';
        stimulis.mode <= '1';
        cycle_fall(clk, 1);
        stimulis.force_full.right <= '0';
        stimulis.force_full.left  <= '0';
        stimulis.force_full.mid   <= '0';
        stimulis.start <= '1';
        wait_nb_step(clk, 1);

        -- Try to start a motor
        stimulis.start    <= '0';
        stimulis.run.left <= '1';
        wait_nb_step(clk, 1);
        stimulis.run.left  <= '0';
        stimulis.run.right <= '1';
        wait_nb_step(clk, 1);
        stimulis.run.right <= '0';
        stimulis.run.mid   <= '1';
        wait_nb_step(clk, 1);
        stimulis.run.mid <= '0';
        wait_nb_step(clk, 1);
        stimulis.init <= '1';
        wait_nb_step(clk, 1);
        stimulis.init <= '0';
        wait_nb_step(clk, 1);

        -- Go out of error with an init
        cycle_fall(clk, 3);
        stimulis.force_empty.mid <= '1';
        cycle_fall(clk, 1);
        stimulis.force_empty.mid <= '0';
        cycle_fall(clk, 10);
        stimulis.init <= '1';
        wait_nb_step(clk, 1);
        stimulis.init <= '0';
        wait_nb_step(clk, 6);

    end test_error;
    ----------------------------------------------------------------------------

end test_mot_pap_pkg;
--------------------------------------------------------------------------------