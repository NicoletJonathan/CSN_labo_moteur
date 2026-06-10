-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : mot_pap_model.vhd
--
-- Description  : Model emulating a stepper motor with a notched disk
--
-- Auteur       : L. Fournier
-- Date         : 29.05.2024
-- Version      : 1.0
--
-- Used in      : Laboratoire de SysLog2/CSN
--
--| Modifications |------------------------------------------------------------
-- Version   Auteur      Date               Description
-- 1.0       LFR         29.05.2024         First version.
-------------------------------------------------------------------------------

--| Library |-------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
use work.mot_pap_tb_pkg.all;
--------------------------------------------------------------------------------

--| Entity |-------------------------------------------------------------------
entity mot_pap_model is
    port(
        clk_i 	      : in  std_logic;
        rst_i	      : in  std_logic;
        sim_end_i     : in  boolean;
        force_empty_i : in  std_logic;
        force_full_i  : in  std_logic;
        phase_i       : in  phase_t;
        cap_o	      : out	std_logic
    );
end mot_pap_model;

--| Architecture |-------------------------------------------------------------
architecture model of mot_pap_model is

    --| Constants |------------------------------------------------------------
    constant NB_EMPTY_PART   : integer := 5;
    constant NB_FULL_PART    : integer := 5;
    constant EMPTY_PART_SIZE : integer := 3;
    constant FULL_PART_SIZE  : integer := 5;
    ---------------------------------------------------------------------------

    --| Types |----------------------------------------------------------------
    type state_t is (
        A_PLUS_B_OFF,
        A_PLUS_B_PLUS,
        A_OFF_B_PLUS,
        A_MINUS_B_PLUS,
        A_MINUS_B_OFF,
        A_MINUS_B_MINUS,
        A_OFF_B_MINUS,
        A_PLUS_B_MINUS,
        TURN_RIGHT,
        TURN_LEFT,
        ERR
    );
    ---------------------------------------------------------------------------

    --| Signals |--------------------------------------------------------------
    signal disk_s          : std_logic_vector(EMPTY_PART_SIZE+FULL_PART_SIZE-1 downto 0) := "01111100";
    signal step_right_s    : std_logic := '0';
    signal step_left_s     : std_logic := '0';
    signal current_state_s : state_t;
    signal next_state_s    : state_t;
    ---------------------------------------------------------------------------

begin

    --| Update state proc |----------------------------------------------------
    update_state_proc : process(clk_i, rst_i) is
    begin
        if(rst_i = '1') then
            current_state_s <= A_PLUS_B_OFF;
        elsif(rising_edge(clk_i)) then
            current_state_s <= next_state_s;
        end if;
    end process update_state_proc;
    ---------------------------------------------------------------------------

    --| Detection direction |--------------------------------------------------
    det_dir_proc : process(current_state_s, phase_i) is
    begin
        -- default value
        next_state_s <= A_PLUS_B_OFF;
        step_right_s <= '0';
        step_left_s  <= '0';

        case(current_state_s) is
            when(A_PLUS_B_OFF) =>
                if(phase_i.a = "10")and(phase_i.b = "00") then
                    next_state_s <= A_PLUS_B_OFF;
                elsif(phase_i.a = "00")and(phase_i.b = "10") then
                    next_state_s <= TURN_RIGHT;
                elsif(phase_i.a = "00")and(phase_i.b = "01") then
                    next_state_s <= TURN_LEFT;
                elsif(phase_i.a = "10")and(phase_i.b = "10") then
                    next_state_s <= TURN_RIGHT;
                elsif(phase_i.a = "10")and(phase_i.b = "01") then
                    next_state_s <= TURN_LEFT;
                else
                    next_state_s <= ERR;
                end if;
            when(A_PLUS_B_PLUS) =>
                if(phase_i.a = "10")and(phase_i.b = "10") then
                    next_state_s <= A_PLUS_B_PLUS;
                elsif(phase_i.a = "00")and(phase_i.b = "10") then
                    next_state_s <= TURN_RIGHT;
                elsif(phase_i.a = "10")and(phase_i.b = "00") then
                    next_state_s <= TURN_LEFT;
                else
                    next_state_s <= ERR;
                end if;
            when(A_OFF_B_PLUS) =>
                if(phase_i.a = "00")and(phase_i.b = "10") then
                    next_state_s <= A_OFF_B_PLUS;
                elsif(phase_i.a = "01")and(phase_i.b = "00") then
                    next_state_s <= TURN_RIGHT;
                elsif(phase_i.a = "10")and(phase_i.b = "00") then
                    next_state_s <= TURN_LEFT;
                elsif(phase_i.a = "01")and(phase_i.b = "10") then
                    next_state_s <= TURN_RIGHT;
                elsif(phase_i.a = "10")and(phase_i.b = "10") then
                    next_state_s <= TURN_LEFT;
                else
                    next_state_s <= ERR;
                end if;
            when(A_MINUS_B_PLUS) =>
                if(phase_i.a = "01")and(phase_i.b = "10") then
                    next_state_s <= A_MINUS_B_PLUS;
                elsif(phase_i.a = "01")and(phase_i.b = "00") then
                    next_state_s <= TURN_RIGHT;
                elsif(phase_i.a = "00")and(phase_i.b = "10") then
                    next_state_s <= TURN_LEFT;
                else
                    next_state_s <= ERR;
                end if;
            when(A_MINUS_B_OFF) =>
                if(phase_i.a = "01")and(phase_i.b = "00") then
                    next_state_s <= A_MINUS_B_OFF;
                elsif(phase_i.a = "00")and(phase_i.b = "01") then
                    next_state_s <= TURN_RIGHT;
                elsif(phase_i.a = "00")and(phase_i.b = "10") then
                    next_state_s <= TURN_LEFT;
                elsif(phase_i.a = "01")and(phase_i.b = "01") then
                    next_state_s <= TURN_RIGHT;
                elsif(phase_i.a = "01")and(phase_i.b = "10") then
                    next_state_s <= TURN_LEFT;
                else
                    next_state_s <= ERR;
                end if;
            when(A_MINUS_B_MINUS) =>
                if(phase_i.a = "01")and(phase_i.b = "01") then
                    next_state_s <= A_MINUS_B_MINUS;
                elsif(phase_i.a = "00")and(phase_i.b = "01") then
                    next_state_s <= TURN_RIGHT;
                elsif(phase_i.a = "01")and(phase_i.b = "00") then
                    next_state_s <= TURN_LEFT;
                else
                    next_state_s <= ERR;
                end if;
            when(A_OFF_B_MINUS) =>
                if(phase_i.a = "00")and(phase_i.b = "01") then
                    next_state_s <= A_OFF_B_MINUS;
                elsif(phase_i.a = "10")and(phase_i.b = "00") then
                    next_state_s <= TURN_RIGHT;
                elsif(phase_i.a = "01")and(phase_i.b = "00") then
                    next_state_s <= TURN_LEFT;
                elsif(phase_i.a = "10")and(phase_i.b = "01") then
                    next_state_s <= TURN_RIGHT;
                elsif(phase_i.a = "01")and(phase_i.b = "01") then
                    next_state_s <= TURN_LEFT;
                else
                    next_state_s <= ERR;
                end if;
            when(A_PLUS_B_MINUS) =>
                if(phase_i.a = "10")and(phase_i.b = "01") then
                    next_state_s <= A_PLUS_B_MINUS;
                elsif(phase_i.a = "10")and(phase_i.b = "00") then
                    next_state_s <= TURN_RIGHT;
                elsif(phase_i.a = "00")and(phase_i.b = "01") then
                    next_state_s <= TURN_LEFT;
                else
                    next_state_s <= ERR;
                end if;
            when(TURN_RIGHT) =>
                step_right_s <= '1';
                if(phase_i.a = "10")and(phase_i.b = "00") then
                    next_state_s <= A_PLUS_B_OFF;
                elsif(phase_i.a = "10")and(phase_i.b = "10") then
                    next_state_s <= A_PLUS_B_PLUS;
                elsif(phase_i.a = "00")and(phase_i.b = "10") then
                    next_state_s <= A_OFF_B_PLUS;
                elsif(phase_i.a = "01")and(phase_i.b = "10") then
                    next_state_s <= A_MINUS_B_PLUS;
                elsif(phase_i.a = "01")and(phase_i.b = "00") then
                    next_state_s <= A_MINUS_B_OFF;
                elsif(phase_i.a = "01")and(phase_i.b = "01") then
                    next_state_s <= A_MINUS_B_MINUS;
                elsif(phase_i.a = "00")and(phase_i.b = "01") then
                    next_state_s <= A_OFF_B_MINUS;
                elsif(phase_i.a = "10")and(phase_i.b = "01") then
                    next_state_s <= A_PLUS_B_MINUS;
                else
                    next_state_s <= ERR;
                end if;
            when(TURN_LEFT) =>
                step_left_s <= '1';
                if(phase_i.a = "10")and(phase_i.b = "00") then
                    next_state_s <= A_PLUS_B_OFF;
                elsif(phase_i.a = "10")and(phase_i.b = "10") then
                    next_state_s <= A_PLUS_B_PLUS;
                elsif(phase_i.a = "00")and(phase_i.b = "10") then
                    next_state_s <= A_OFF_B_PLUS;
                elsif(phase_i.a = "01")and(phase_i.b = "10") then
                    next_state_s <= A_MINUS_B_PLUS;
                elsif(phase_i.a = "01")and(phase_i.b = "00") then
                    next_state_s <= A_MINUS_B_OFF;
                elsif(phase_i.a = "01")and(phase_i.b = "01") then
                    next_state_s <= A_MINUS_B_MINUS;
                elsif(phase_i.a = "00")and(phase_i.b = "01") then
                    next_state_s <= A_OFF_B_MINUS;
                elsif(phase_i.a = "10")and(phase_i.b = "01") then
                    next_state_s <= A_PLUS_B_MINUS;
                else
                    next_state_s <= ERR;
                end if;
            when(ERR) =>
                if(phase_i.a = "10")and(phase_i.b = "00") then
                    next_state_s <= A_PLUS_B_OFF;
                elsif(phase_i.a = "10")and(phase_i.b = "10") then
                    next_state_s <= A_PLUS_B_PLUS;
                elsif(phase_i.a = "00")and(phase_i.b = "10") then
                    next_state_s <= A_OFF_B_PLUS;
                elsif(phase_i.a = "01")and(phase_i.b = "10") then
                    next_state_s <= A_MINUS_B_PLUS;
                elsif(phase_i.a = "01")and(phase_i.b = "00") then
                    next_state_s <= A_MINUS_B_OFF;
                elsif(phase_i.a = "01")and(phase_i.b = "01") then
                    next_state_s <= A_MINUS_B_MINUS;
                elsif(phase_i.a = "00")and(phase_i.b = "01") then
                    next_state_s <= A_OFF_B_MINUS;
                elsif(phase_i.a = "10")and(phase_i.b = "01") then
                    next_state_s <= A_PLUS_B_MINUS;
                else
                    next_state_s <= ERR;
                end if;
            when others =>
                next_state_s <= A_PLUS_B_OFF;
        end case;
    end process det_dir_proc;
    ---------------------------------------------------------------------------

    --| Gestion position capt |------------------------------------------------
    counter_proc : process(clk_i, rst_i, force_full_i, force_empty_i) is
    begin
        if(rst_i = '1') then
            if(force_empty_i = '1') then
                disk_s <= "01111100";
            elsif(force_full_i = '1') then
                disk_s <= "11000111";
            end if;
        elsif(rising_edge(clk_i)) then
            if(force_empty_i = '1') then
                disk_s <= "01111100";
            elsif(force_full_i = '1') then
                disk_s <= "11000111";
            else
                if(step_right_s = '1')or(step_left_s = '1') then
                    if(step_right_s = '1') then
                        disk_s <= disk_s(disk_s'low) & disk_s(disk_s'high downto 1);
                    else
                        disk_s <= disk_s(disk_s'high-1 downto 0) & disk_s(disk_s'high);
                    end if;
                end if;
            end if;
        end if;
    end process counter_proc;
    ----------------------------------------------------------------------------

    cap_o <= disk_s(0);
end model;
--------------------------------------------------------------------------------