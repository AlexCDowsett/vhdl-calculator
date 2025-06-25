--------------------------------------------------------------------------------
-- Title       : EEE3027, Digital Design with VHDL - Assignment II
-- Project     : UART Calculator
--------------------------------------------------------------------------------
-- File        : Test_character_decoder.vhd
-- University  : University of Surrey
-- Created     : Sat May  4 20:28:55 2024
-- Platform    : Vivado 2022.2
-- Standard    : VHDL-2008
-------------------------------------------------------------------------------
-- Description: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_textio.all;
use ieee.numeric_std.all;
use std.env.finish;
use work.Utils.all;
use work.Clock_Utils.all;
use work.multi_components.all;


entity Test_character_decoder is end; -- runs forever, use break!!

architecture Structure of Test_character_decoder is


    signal clk               : STD_LOGIC;
    signal character_to_send : STD_LOGIC_VECTOR (7 downto 0) := (others => 'U');
    signal dataValid         : STD_LOGIC;
    signal parallelDataOut   : STD_LOGIC_VECTOR(7 downto 0) := (others => 'U');
    signal LED_hi            : STD_LOGIC;
    signal LED_lo            : STD_LOGIC;
    signal send_character    : STD_LOGIC;


    type lut is array (0 to 61) of std_logic_vector(7 downto 0);

    signal ExampleInputs : lut := (
            x"30", x"31", x"32", x"33", x"34", x"35", x"36", x"37", x"38", x"39",

            x"41", x"42", x"43", x"44", x"45", x"46", x"47", x"48", x"49", x"4A",
            x"4B", x"4C", x"4D", x"4E", x"4F", x"50", x"51", x"52", x"53", x"54",
            x"55", x"56", x"57", x"58", x"59", x"5A",

            x"61", x"62", x"63", x"64", x"65", x"66", x"67", x"68", x"69", x"6A",
            x"6B", x"6C", x"6D", x"6E", x"6F", x"70", x"71", x"72", x"73", x"74",
            x"75", x"76", x"77", x"78", x"79", x"7A");

begin
    C : Clock(clk, 10 ns, 10 ns);

    decoder : character_decoder

        generic map (
            CLOCK_FREQUENCY => 5,
            DEBUG_MODE      => true
        )

        port map(
            clk                => clk,
            charFromUART_valid => dataValid,
            charFromUART       => parallelDataOut,
            LED_hi             => LED_hi,
            LED_lo             => LED_lo,
            send_character     => send_character,
            character_to_send  => character_to_send
        );

    -- different process for validation
    testbench : process begin

        --wait for 100ns;
        --character_to_send <= x"61";
        --wait for 100ns;
        --send_character <= '1';
        --wait for 100ns;
        --tx_ready <= '1';


        testbench_char : for i in 0 to 61 loop
            wait until CLK'EVENT and CLK='1'; wait for 1 ns;
            parallelDataOut <= ExampleInputs(i);
            wait for 20ns;
            dataValid <= '1', '0' after 20ns;
            wait until character_to_send'EVENT;
            wait for 120ns;
        end loop;

        report "Testbench complete.";
        finish;


    end process testbench;

    debug_LED : process(LED_hi, LED_lo) begin
        if not (LED_hi = '0' and LED_lo = '0') then
            report "LED high = " & std_logic'image(LED_hi) &
            ", LED low = " & std_logic'image(LED_lo) severity note;
        end if;

    end process;

    debug_character_to_send : process (character_to_send) begin
        if character_to_send /= x"00" then
            report "Output = 0x" & to_hstring(character_to_send) severity note;
        end if;
    end process;


    debug_ParallelDataOut : process(ParallelDataOut) begin
        report "Input = 0x" & to_hstring(ParallelDataOut) severity note;
    end process;


end;
