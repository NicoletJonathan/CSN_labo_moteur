------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : maxv_top.vhd
-- Author               : Gilles Curchod
-- Date                 : 28.05.2013
-- Target Devices       : Altera MAXV 5M570ZF256C5
--
-- Context              : Max_V_Board Project : Hardware bring-up
--
------------------------------------------------------------------------------------------
-- Description :
--   Top of the CPLD
------------------------------------------------------------------------------------------
-- Information :
--   30.09.2014  EMI  Adaptation for the aff_min_max lab
--
------------------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Engineer     Changes
-- 0.0   See header  GCD          Initial version
-- 1.0   25.09.2014  EMI          Modified to use for CSN lab
-- 1.1   01.10.2014  GHR          Adaptation to use with the Aff_Min_Max.tcl
--                                and the board Console-USB2 to test circuit
-- 1.2   22.12.2016  FCC          Added connections for DSUB25 connector
--
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity maxv_top is
    port(
        --| Clocks, Reset |-------------------------------------------------------------------
        Clk_Gen_i                : in    std_logic;                      -- CLK_GEN
        Clk_Main_i               : in    std_logic;                      -- CLK_MAIN
        --| Inout devices |-------------------------------------------------------------------
        Con_25p_io               : inout std_logic_vector(25 downto 1);  -- CON_25P_*
        Con_80p_io               : inout std_logic_vector(79 downto 2);  -- CON_80P_*
        Mezzanine_io             : inout std_logic_vector(20 downto 5);  -- MEZZANINE_*
        --| Input devices |-------------------------------------------------------------------
        Encoder_A_i              : in    std_logic;                      -- ENCODER_A
        Encoder_B_i              : in    std_logic;                      -- ENCODER_B
        nButton_i                : in    std_logic_vector( 8 downto 1);  -- NBUTTON_*
        nReset_i                 : in    std_logic;                      -- NRESET
        Switch_i                 : in    std_logic_vector( 7 downto 0);  -- SWITCH_*
        --| Output devices |------------------------------------------------------------------
        nLed_o                   : out   std_logic_vector( 7 downto 0);  -- NLED_*
        Led_RGB_o                : out   std_logic_vector( 2 downto 0);  -- LED_RGB_*
        nSeven_Seg_o             : out   std_logic_vector( 7 downto 0)   -- NDSP_SEG (dp, g downto a)
    );
end maxv_top;

architecture struct of maxv_top is

    --| Intermediate signals |--------------------------------------------------------------
    signal Con_25p_DI_s   : std_logic_vector(Con_25p_io'range);
    signal Con_25p_DO_s   : std_logic_vector(Con_25p_io'range);
    signal Con_25p_OE_s   : std_logic_vector(Con_25p_io'range);
    signal Con_80p_DI_s   : std_logic_vector(Con_80p_io'range);
    signal Con_80p_DO_s   : std_logic_vector(Con_80p_io'range);
    signal Con_80p_OE_s   : std_logic_vector(Con_80p_io'range);
    signal Mezzanine_DI_s : std_logic_vector(Mezzanine_io'range);
    signal Mezzanine_DO_s : std_logic_vector(Mezzanine_io'range);
    signal Mezzanine_OE_s : std_logic;
    signal Button_s       : std_logic_vector(nButton_i'range);
    signal Led_s          : std_logic_vector(nLed_o'range);
    signal Seven_Seg_s    : std_logic_vector(nSeven_Seg_o'range); -- order: dp, g f e d c b a

    --| Internal signals |------------------------------------------------------------------
    signal cpt_s         : unsigned(19 downto 0);
    signal blink_1hz_s   : std_logic;
    signal osc_s         : std_logic;

    --| Comp signals |------------------------------------------------------------------
    -- Inputs
    signal cap_l_s     : std_logic;
    signal cap_m_s     : std_logic;
    signal cap_r_s     : std_logic;
    signal start_s     : std_logic;
    signal init_s      : std_logic;
    signal mode_s      : std_logic;
    signal nb_tour_s   : std_logic_vector(2 downto 0);
    signal run_l_s     : std_logic;
    signal run_m_s     : std_logic;
    signal run_r_s     : std_logic;
    signal en_bridge_s : std_logic;
    -- Outputs
    signal l_en_s     : std_logic;
    signal l_a1_s     : std_logic;
    signal l_a2_s     : std_logic;
    signal l_b1_s     : std_logic;
    signal l_b2_s     : std_logic;
    signal m_en_s     : std_logic;
    signal m_a1_s     : std_logic;
    signal m_a2_s     : std_logic;
    signal m_b1_s     : std_logic;
    signal m_b2_s     : std_logic;
    signal r_en_s     : std_logic;
    signal r_a1_s     : std_logic;
    signal r_a2_s     : std_logic;
    signal r_b1_s     : std_logic;
    signal r_b2_s     : std_logic;
    signal err_s      : std_logic;

    --| Components declaration |------------------------------------------------------------
    component mot_pap_top is
        port(
            clk_i       : in  std_logic;
            nRst_i      : in  std_logic;
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
            en_bridge_i : in  std_logic;
            l_a1_o      : out std_logic;
            l_a2_o      : out std_logic;
            l_b1_o      : out std_logic;
            l_b2_o      : out std_logic;
            l_en_o      : out std_logic;
            m_a1_o      : out std_logic;
            m_a2_o      : out std_logic;
            m_b1_o      : out std_logic;
            m_b2_o      : out std_logic;
            m_en_o      : out std_logic;
            r_a1_o      : out std_logic;
            r_a2_o      : out std_logic;
            r_b1_o      : out std_logic;
            r_b2_o      : out std_logic;
            r_en_o      : out std_logic;
            err_o       : out std_logic
    );
    end component;
    for all : mot_pap_top use entity work.mot_pap_top(struct);
    ----------------------------------------------------------------------------------------
begin

    ----------------------------------------------------------------------------------------
    --| INPUTS PROCESSING |-----------------------------------------------------------------
    Button_s <= not nButton_i;

    ----------------------------------------------------------------------------------------
    --| OUTPUT PROCESSING |-----------------------------------------------------------------
    nLed_o       <= not Led_s;
    nSeven_Seg_o <= not Seven_Seg_s;

    -----------------------------------------------
    -- Tri-state declaration for the 25p connector

    ---- 25p EINEV 287 console interface:
    -- Tri-state declaration :
    Con_25p_OE_s( 8 downto  1) <= (others => '1'); -- outputs
    Con_25p_OE_s(16 downto  9) <= (others => '0'); -- inputs
    Con_25p_OE_s(24 downto 17) <= (others => '1'); -- outputs
    Con_25p_OE_s(25) <= '0'; -- input
    -- In/out pin map :
    -- Con_25p_DO_s( 8 downto  1) : LED (L7 downto L0)
    -- Con_25p_DI_s(16 downto  9) : Switch (S7 downto S0)
    -- Con_25p_DO_s(20 downto 17) : Hex0 (LSB) (D3 to D0)
    -- Con_25p_DO_s(24 downto 21) : Hex1 (MSB) (D3 to D0)
    -- Con_25p_DI_s(25)           : Clk

    tri_state_25p_loop: for I in Con_25p_io'right to Con_25p_io'left generate
        Con_25p_io(I) <= Con_25p_DO_s(I) when Con_25p_OE_s(I) = '1' else 'Z';
    end generate;

    Con_25p_DI_s <= to_X01(Con_25p_io);

    -----------------------------------------------
    -- Tri-state declaration for the 80p connector
    Con_80p_OE_s(34 downto  2) <= (others => '0'); -- used as inputs
    Con_80p_OE_s(79 downto 35) <= (others => '1'); -- outputs, leds_o

    tri_state_80p_loop: for I in Con_80p_io'right to Con_80p_io'left generate
        Con_80p_io(I) <= Con_80p_DO_s(I) when Con_80p_OE_s(I) = '1' else 'Z';
    end generate;

    Con_80p_DI_s <= to_X01(Con_80p_io);

    ----------------------------------------------------------------------------------------
    --| Unused output allocation |----------------------------------------------------------
    Led_RGB_o <= (others => '0');
    Seven_Seg_s(Seven_Seg_s'high-1 downto 1)  <= (others => '0');
    Seven_Seg_s(Seven_Seg_s'high) <= blink_1hz_s; -- decimal point blink at 1Hz
    ----------------------------------------------------------------------------------------

    --| Components intanciation |-----------------------------------------------------------
    mot_pap_top_inst : mot_pap_top
        port map(
            clk_i       => Clk_Gen_i,
            nRst_i      => nReset_i,
            cap_l_i     => cap_l_s,
            cap_m_i     => cap_m_s,
            cap_r_i     => cap_r_s,
            mode_i      => mode_s,
            start_i     => start_s,
            init_i      => init_s,
            nb_tour_i   => nb_tour_s,
            run_l_i     => run_l_s,
            run_m_i     => run_m_s,
            run_r_i     => run_r_s,
            en_bridge_i => en_bridge_s,
            l_a1_o      => l_a1_s,
            l_a2_o      => l_a2_s,
            l_b1_o      => l_b1_s,
            l_b2_o      => l_b2_s,
            l_en_o      => l_en_s,
            m_a1_o      => m_a1_s,
            m_a2_o      => m_a2_s,
            m_b1_o      => m_b1_s,
            m_b2_o      => m_b2_s,
            m_en_o      => m_en_s,
            r_a1_o      => r_a1_s,
            r_a2_o      => r_a2_s,
            r_b1_o      => r_b1_s,
            r_b2_o      => r_b2_s,
            r_en_o      => r_en_s,
            err_o       => err_s
        );

    cap_l_s <= Con_80p_DI_s(4);
    cap_r_s <= Con_80p_DI_s(6);
    cap_m_s <= Con_80p_DI_s(3);

    -- Show captor and error on led carte mot pap
    Con_80p_DO_s(38) <= not(cap_l_s);
    Con_80p_DO_s(36) <= not(cap_r_s);
    Con_80p_DO_s(35) <= not(cap_m_s);
    Con_80p_DO_s(40) <= '1'; --LED unused
    Con_80p_DO_s(37) <= '1'; --LED unused
    Con_80p_DO_s(39) <= not(err_s);


    Con_80p_DO_s(51) <= l_en_s;
    Con_80p_DO_s(49) <= l_a1_s;
    Con_80p_DO_s(47) <= l_a2_s;
    Con_80p_DO_s(41) <= l_en_s;
    Con_80p_DO_s(45) <= l_b1_s;
    Con_80p_DO_s(43) <= l_b2_s;

    Con_80p_DO_s(65) <= m_en_s;
    Con_80p_DO_s(63) <= m_a1_s;
    Con_80p_DO_s(61) <= m_a2_s;
    Con_80p_DO_s(55) <= m_en_s;
    Con_80p_DO_s(59) <= m_b1_s;
    Con_80p_DO_s(57) <= m_b2_s;

    Con_80p_DO_s(79) <= r_en_s;
    Con_80p_DO_s(77) <= r_a1_s;
    Con_80p_DO_s(75) <= r_a2_s;
    Con_80p_DO_s(69) <= r_en_s;
    Con_80p_DO_s(73) <= r_b1_s;
    Con_80p_DO_s(71) <= r_b2_s;


    -- Connection all sgn needed maxv to con 80
    -- Buttons maxv sw1 to sw8
    start_s <= Button_s(1);
    init_s  <= Button_s(3);

    run_l_s <= Button_s(7);
    run_m_s <= Button_s(6);
    run_r_s <= Button_s(5);

    -- Connection dipswitch maxv
    en_bridge_s <= Switch_i(7);
    mode_s      <= Switch_i(6);
    nb_tour_s   <= Switch_i(2 downto 0);

    -- Leds maxv LD0 to LD7
    led_s(2)          <= cap_l_s;
    led_s(1)          <= cap_m_s;
    led_s(0)          <= cap_r_s;
    led_s(3)          <= '0';
    led_s(6 downto 4) <= (others => '0');
    led_s(7)          <= err_s;

    ----------------------------------------------------------------------------------------
    --| Signal blink at 1Hz |------------------------------------------------------------------
    process (nReset_i, Clk_Main_i)
    begin
        if nReset_i = '0' then
            Cpt_s <= (others => '0');
        elsif rising_edge(Clk_Main_i) then
            Cpt_s <= Cpt_s +1;
        end if;
    end process;

    -- signal for test
    blink_1hz_s <= cpt_s(cpt_s'high);
    -- signal ocsl_s generation:
    --     use fonction "cpt_s(9) and cpt_s(8) and cpt_s(7)" to have a frequency from 1KHz
    ---    with duty cycle of 12% on/ 75% off (25% on: very small difference!)
    osc_s <= cpt_s(9) and cpt_s(8) and cpt_s(7);

end struct;

