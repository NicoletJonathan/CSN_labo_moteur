-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : phase_manager.vhd
--
-- Description  : Manage the bridge input of a bipolar stepper motor with a
--                state machine
--
-- Auteur       : L. Fournier
-- Date         : 11.07.2022
-- Version      : 1.0
--
-- Utilise dans : Moteur pas-à-pas
--
--| Modifications |------------------------------------------------------------
-- Version   Auteur      Date               Description
-- 1.0       LFR         see header         First version.
-------------------------------------------------------------------------------

--| Library |------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
-------------------------------------------------------------------------------

--| Entity |-------------------------------------------------------------------
entity phase_manager is
    port (
        clk_i        : in  std_logic;
        rst_i        : in  std_logic;
        dir_i        : in  std_logic;
        full_nHalf_i : in  std_logic;
        step_i       : in  std_logic;
        a_o          : out std_logic_vector(1 downto 0);
        b_o          : out std_logic_vector(1 downto 0)
    );
end phase_manager;
-------------------------------------------------------------------------------

--| Architecture |-------------------------------------------------------------
architecture fsm of phase_manager is

    --| Types |----------------------------------------------------------------
    type state_t is (
        A_PLUS_B_OFF,
        A_PLUS_B_PLUS,
        A_OFF_B_PLUS,
        A_MINUS_B_PLUS,
        A_MINUS_B_OFF,
        A_MINUS_B_MINUS,
        A_OFF_B_MINUS,
        A_PLUS_B_MINUS
    );
    ---------------------------------------------------------------------------

    --| Signals |--------------------------------------------------------------
    -- State machine signals
    signal current_state_s : state_t;
    signal next_state_s    : state_t;
    -- Output signals
    signal a_s : std_logic_vector(a_o'range);
    signal b_s : std_logic_vector(b_o'range);
    ---------------------------------------------------------------------------

begin

    --| Update state proc |----------------------------------------------------
    -- This process update the state of the state machine
    update_state_proc : process(clk_i, rst_i) is
    begin
        if(rst_i = '1') then
            current_state_s <= A_PLUS_B_OFF;
        elsif(rising_edge(clk_i)) then
            current_state_s <= next_state_s;
        end if;
    end process update_state_proc;
    ---------------------------------------------------------------------------

    --| State machine proc |---------------------------------------------------
    -- This process is a moore state machine who manage the cmd to put on the
    -- bridge of a bipolare stepper motor for spinning it.
    --
    -- When the step signal  =  '1', the state change and a chagment of state
    -- is a step.
    --
    -- The dir signal change the rotation sens of the motor. Basically the state
    -- are called backward wich change the rotation sens of the motor.
    --
    -- The full_nHalf signal is used to rotate motor with full step or half step.
    -- This is done easily by giong trough all state for the half step and by
    -- skipping a state at each changement of state for the full step.
    --
    -- The a/b vector values table are :
    --             OFF   : "00" ou "11"
    --             PLUS  : "10"
    --             MINUS : "01"
    --
    state_machine_proc : process(current_state_s, step_i, full_nHalf_i, dir_i) is
    begin
        -- Default values for output
        next_state_s <= A_PLUS_B_OFF;
        a_s          <= "00"; -- A_OFF
        b_s          <= "00"; -- B_OFF

        case current_state_s is
            when A_PLUS_B_OFF =>
                a_s <= "10";
                if(step_i = '1')then
                    if(full_nHalf_i = '1') then
                        if(dir_i = '1') then
                            next_state_s <= A_OFF_B_PLUS;
                        else
                            next_state_s <= A_OFF_B_MINUS;
                        end if;
                    else
                        if(dir_i = '1') then
                            next_state_s <= A_PLUS_B_PLUS;
                        else
                            next_state_s <= A_PLUS_B_MINUS;
                        end if;
                    end if;
                else
                    next_state_s <= A_PLUS_B_OFF;
                end if;
            when A_PLUS_B_PLUS =>
                a_s <= "10";
                b_s <= "10";
                if(step_i = '1') then
                    if(dir_i = '1') then
                        next_state_s <= A_OFF_B_PLUS;
                    else
                        next_state_s <= A_PLUS_B_OFF;
                    end if;
                else
                    next_state_s <= A_PLUS_B_PLUS;
                end if;
            when A_OFF_B_PLUS =>
                b_s <= "10";
                if(step_i = '1') then
                    if(full_nHalf_i = '1') then
                        if(dir_i = '1') then
                            next_state_s <= A_MINUS_B_OFF;
                        else
                            next_state_s <= A_PLUS_B_OFF;
                        end if;
                    else
                        if(dir_i = '1') then
                            next_state_s <= A_MINUS_B_PLUS;
                        else
                            next_state_s <= A_PLUS_B_PLUS;
                        end if;
                    end if;
                else
                    next_state_s <= A_OFF_B_PLUS;
                end if;
            when A_MINUS_B_PLUS =>
                a_s <= "01";
                b_s <= "10";
                if(step_i = '1') then
                    if(dir_i = '1') then
                        next_state_s <= A_MINUS_B_OFF;
                    else
                        next_state_s <= A_OFF_B_PLUS;
                    end if;
                else
                    next_state_s <= A_MINUS_B_PLUS;
                end if;
            when A_MINUS_B_OFF =>
                a_s <= "01";
                if(step_i = '1') then
                    if(full_nHalf_i = '1') then
                        if(dir_i = '1') then
                            next_state_s <= A_OFF_B_MINUS;
                        else
                            next_state_s <= A_OFF_B_PLUS;
                        end if;
                    else
                        if(dir_i = '1') then
                            next_state_s <= A_MINUS_B_MINUS;
                        else
                            next_state_s <= A_MINUS_B_PLUS;
                        end if;
                    end if;
                else
                    next_state_s <= A_MINUS_B_OFF;
                end if;
            when A_MINUS_B_MINUS =>
                a_s <= "01";
                b_s <= "01";
                if(step_i = '1') then
                    if(dir_i = '1') then
                        next_state_s <= A_OFF_B_MINUS;
                    else
                        next_state_s <= A_MINUS_B_OFF;
                    end if;
                else
                    next_state_s <= A_MINUS_B_MINUS;
                end if;
            when A_OFF_B_MINUS =>
                b_s <= "01";
                if(step_i = '1') then
                    if(full_nHalf_i = '1') then
                        if(dir_i = '1') then
                            next_state_s <= A_PLUS_B_OFF;
                        else
                            next_state_s <= A_MINUS_B_OFF;
                        end if;
                    else
                        if(dir_i = '1') then
                            next_state_s <= A_PLUS_B_MINUS;
                        else
                            next_state_s <= A_MINUS_B_MINUS;
                        end if;
                    end if;
                else
                    next_state_s <= A_OFF_B_MINUS;
                end if;
            when A_PLUS_B_MINUS =>
                a_s <= "10";
                b_s <= "01";
                if(step_i = '1')then
                    if(dir_i = '1') then
                        next_state_s <= A_PLUS_B_OFF;
                    else
                        next_state_s <= A_OFF_B_MINUS;
                    end if;
                else
                    next_state_s <= A_PLUS_B_MINUS;
                end if;
            when others =>
                next_state_s <= A_PLUS_B_OFF;
        end case;
    end process state_machine_proc;
    ---------------------------------------------------------------------------

    --| Outputs affectation |--------------------------------------------------
    a_o <= a_s;
    b_o <= b_s;
    ---------------------------------------------------------------------------

end fsm;
-------------------------------------------------------------------------------