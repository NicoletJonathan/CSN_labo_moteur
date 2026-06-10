-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : mot_pap_tb_pkg.vhd
--
-- Description  : Package for the mot pap testbench. Contain some types and
--                procedures.
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
--------------------------------------------------------------------------------

--| Package |-------------------------------------------------------------------
package mot_pap_tb_pkg is

    --| Constants |------------------------------------------------------------
    constant CLK_PERIOD  : time := 2 us;
    constant STEP_PERIOD : time := 64 * CLK_PERIOD;
    constant TIMEOUT     : time := 12 * STEP_PERIOD;
    ---------------------------------------------------------------------------

    --| Types |-----------------------------------------------------------------
    type mot_pap_in_t is record
        left  : std_logic;
        mid   : std_logic;
        right : std_logic;
    end record;

    type mot_pap_stimulis_t is record
        run         : mot_pap_in_t;
        force_empty : mot_pap_in_t;
        force_full  : mot_pap_in_t;
        mode        : std_logic;
        start       : std_logic;
        init        : std_logic;
        nb_tour     : std_logic_vector(2 downto 0);
    end record;

    type phase_t is record
        a  : std_logic_vector(1 downto 0);
        b  : std_logic_vector(1 downto 0);
    end record;

    type motor_t is record
        phase : phase_t;
        en    : std_logic;
        dir   : std_logic;
    end record;

    type mot_pap_out_t is record
        left  : motor_t;
        mid   : motor_t;
        right : motor_t;
    end record;

    type mot_pap_observed_t is record
        motor  : mot_pap_out_t;
        captor : mot_pap_in_t;
        speed  : std_logic_vector(1 downto 0);
        err    : std_logic;
    end record;
    ----------------------------------------------------------------------------

    --| Procedures |------------------------------------------------------------
    procedure cycle_fall(signal clk      : in std_logic;
                                nb_cycle : in integer := 1);

    procedure cycle_rise(signal clk      : in std_logic;
                                nb_cycle : in integer := 1);

    procedure wait_nb_step(signal clk     : in std_logic;
                                  nb_step : in integer := 1);
    ----------------------------------------------------------------------------

    --| Functions |-------------------------------------------------------------
    function is_motor_free(captors : mot_pap_in_t) return boolean;

    function is_motor_unknown(captors : mot_pap_in_t) return boolean;
    ----------------------------------------------------------------------------

end mot_pap_tb_pkg;
--------------------------------------------------------------------------------


--| Package body |--------------------------------------------------------------
package body mot_pap_tb_pkg is

    --| Procedures |------------------------------------------------------------
    procedure cycle_fall(signal clk      : in std_logic;
                                nb_cycle : in integer := 1) is
    begin
        for i in 1 to nb_cycle loop
            wait until falling_edge(clk);
        end loop;
    end cycle_fall;

    procedure cycle_rise(signal clk      : in std_logic;
                                nb_cycle : in integer := 1) is
    begin
        for i in 1 to nb_cycle loop
            wait until rising_edge(clk);
        end loop;
    end cycle_rise;

    procedure wait_nb_step(signal clk     : in std_logic;
                                  nb_step : in integer := 1) is
    begin
        wait for(nb_step * STEP_PERIOD);
    end wait_nb_step;
    ----------------------------------------------------------------------------

    --| Functions |-------------------------------------------------------------
    function is_motor_free(captors : mot_pap_in_t) return boolean is
        variable motor_free : boolean := false;
    begin
        if(captors.left = '0')and(captors.mid = '0')and(captors.right = '0') then
            motor_free := true;
        else
            motor_free := false;
        end if;

        return motor_free;
    end is_motor_free;

    function is_motor_unknown(captors : mot_pap_in_t) return boolean is
        variable motor_unknown : boolean := false;
    begin
        if(captors.mid = '1')and((captors.right = '1')or(captors.right = '1')) then
            motor_unknown := true;
        else
            motor_unknown := false;
        end if;

        return motor_unknown;
    end is_motor_unknown;
    ----------------------------------------------------------------------------

end mot_pap_tb_pkg;
--------------------------------------------------------------------------------