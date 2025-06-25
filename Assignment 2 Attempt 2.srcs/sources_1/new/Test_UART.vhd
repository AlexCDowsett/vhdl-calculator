--------------------------------------------------------------------------------
-- Title       : EEE3027, Digital Design with VHDL - Assignment II
-- Project     : UART Calculator
--------------------------------------------------------------------------------
-- File        : Test_UART.vhd
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
use std.env.finish;
use work.Utils.all;
use work.Clock_Utils.all;
use work.multi_components.all;



entity Test_UART is end; -- runs forever, use break!!

architecture Structure of Test_UART is


    signal reset           : STD_LOGIC;
    signal clk             : STD_LOGIC;
    signal parallelDataIn  : STD_LOGIC_VECTOR (7 downto 0);
    signal parallelDataOut : STD_LOGIC_VECTOR (7 downto 0);

    signal serialData      : STD_LOGIC := '1';
    signal dataValid       : STD_LOGIC := '0';
    signal txIsReady       : STD_LOGIC;
    signal transmitRequest : STD_LOGIC := '0';

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
    reset <= '1', '0' after 1 ns;

    make_UART : UART

        generic map (
            BAUD_RATE  => 115_200,
            CLOCK_RATE => 50_000_000
        )

        port map(
            reset           => reset,
            clock           => clk,
            serialDataIn    => serialData,
            parallelDataOut => parallelDataOut,
            dataValid       => dataValid,
            parallelDataIn  => parallelDataIn,
            transmitRequest => transmitRequest,
            txIsReady       => txIsReady,
            serialDataOut   => serialData
        );

    -- different process for validation
    testbench : process begin

        wait for 100ns;
        for i in 0 to 61 loop
            parallelDataIn <= ExampleInputs(i);

            wait until CLK'EVENT and CLK='1'; wait for 1 ns;
            transmitRequest <= '1', '0' after 20 ns;

            wait until txIsReady = '1';
        end loop;

        report "Testbench complete.";
        finish;


    end process testbench;

    reportData : process (parallelDataIn) begin
        report "Data Sent = 0x" & to_hstring(parallelDataIn) severity note;
    end process reportData;

    isValid : process (dataValid) begin
        if dataValid = '1' then
            if parallelDataIn = parallelDataOut then
                report "Recieved data correct" severity note;
            else
                report "Recieved data correct" severity warning;
                finish;
            end if;
        end if;
    end process isValid;

end;
