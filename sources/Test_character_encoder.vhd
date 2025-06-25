--------------------------------------------------------------------------------
-- Title       : EEE3027, Digital Design with VHDL - Assignment II
-- Project     : UART Calculator
--------------------------------------------------------------------------------
-- File        : Test_character_encoder.vhd
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


entity Test_character_encoder is end; -- runs forever, use break!!

architecture Structure of Test_character_encoder is


    signal clk               : STD_LOGIC;
    signal character_to_send : STD_LOGIC_VECTOR (7 downto 0) := (others => 'U');
    signal tx_ready          : STD_LOGIC;
    signal parallelDataIn    : STD_LOGIC_VECTOR (7 downto 0);
    signal transmitRequest   : STD_LOGIC;
    signal DIP_to_send       : STD_LOGIC_VECTOR (3 downto 0) := (others => 'U');
    signal send_character    : std_logic                     := 'U';

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

    encoder : character_encoder
        generic map (DEBUG_MODE => false)
        port map(
            clk               => clk,
            character_decoded => send_character,
            character_to_send => character_to_send,
            tx_ready          => tx_ready,
            parallelDataIn    => parallelDataIn,
            transmitRequest   => transmitRequest,
            DIP_dbncd         => DIP_to_send
        );

    -- different process for validation
    testbench : process begin

        testbench_DIP : for i in 0 to 15 loop
            wait until CLK'EVENT and CLK='1'; wait for 1 ns;
            DIP_to_send <= std_logic_vector(to_unsigned(i, 4));
            report "DIP loaded.";
            wait for 40ns;
            tx_ready <= '1', '0' after 20ns;
            wait until parallelDataIn'EVENT;
        end loop;

        report "Testbench complete for DIP inputs. Now testing character inputs." severity note;

        testbench_char : for i in 0 to 61 loop
            wait until CLK'EVENT and CLK='1'; wait for 1 ns;
            character_to_send <= ExampleInputs(i);
            wait for 20ns;
            send_character <= '1'; wait for 20ns;
            tx_ready       <= '1', '0' after 20ns;
            wait until parallelDataIn'EVENT;
        end loop;

        report "Testbench complete.";
        finish;


    end process testbench;

    debug_ParallelDataIn : process(ParallelDataIn) begin
        report "ParallelDataIn = 0x" & to_hstring(ParallelDataIn) severity note;
    end process;

    debug_DIP_to_send : process (DIP_to_send) begin
        report "DIP_to_send = 0x" & to_hstring(DIP_to_send) severity note;
    end process;

    debug_character_to_send : process (character_to_send) begin
        report "character_to_send = 0x" & to_hstring(character_to_send) severity note;
    end process;

    debug_tx_ready : process (tx_ready) begin
        if tx_ready = '1' then report "TX is ready." severity note; end if;
    end process;
end;
