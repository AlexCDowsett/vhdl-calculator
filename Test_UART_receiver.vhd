--------------------------------------------------------------------------------
-- Title       : EEE3027, Digital Design with VHDL - Assignment II
-- Project     : UART Calculator
--------------------------------------------------------------------------------
-- File        : Test_UART_transmitter.vhd
-- University  : University of Surrey
-- Created     : Sat May  4 20:28:55 2024
-- Platform    : Vivado 2022.2
-- Standard    : VHDL-2008
-------------------------------------------------------------------------------
-- Description: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Utils.all;
use work.Clock_Utils.all;
use work.multi_components.all;
use std.env.finish;


entity Test_UART_receiver is
    generic (
        BAUD_RATE  : integer := 115_200;
        CLOCK_RATE : integer := 50_000_000
    ); end;

    architecture Structure of Test_UART_receiver is


        signal reset              : STD_LOGIC;
        signal clk                : STD_LOGIC;
        signal baudRateEnable     : STD_LOGIC;
        signal baudRateEnable_x16 : STD_LOGIC;
        signal parallelDataOut    : STD_LOGIC_VECTOR (7 downto 0);
        signal dataValid          : STD_LOGIC;
        signal serialDataIn       : STD_LOGIC := '1';

        signal ExampleInput : std_logic_vector (7 downto 0) := x"47"; --"01000111"


    begin
        C : Clock(clk, 10 ns, 10 ns);
        reset <= '1', '0' after 40 ns;


        UBRGTB : UART_baudRateGenerator
            generic map(BAUD_RATE, CLOCK_RATE)
            port map (reset, clk, baudRateEnable, baudRateEnable_x16);

        rcvrTB : UART_receiver
            generic map(true)
            PORT MAP(
                reset              => reset,
                clock              => clk,
                baudRateEnable_x16 => baudRateEnable_x16,
                serialDataIn       => serialDataIn,
                parallelDataOut    => parallelDataOut,
                dataValid          => dataValid
            );


        testbench : process
            constant nCountsPerBaud : integer := CLOCK_RATE / BAUD_RATE;
            variable BAUD_PERIOD    : time;
        begin

            BAUD_PERIOD := (1000000000/BAUD_RATE) * 1ns;
            --report "BAUD_PERIOD = " & time'image(BAUD_PERIOD) severity note;

            wait for BAUD_PERIOD;
            serialDataIn <= '0'; --start bit
                                 --report "Testbench sent start bit" severity note;

            for i in 0 to 7 loop
                wait for BAUD_PERIOD;
                serialDataIn <= ExampleInput(i); -- number i data bit
                                                 --report "Testbench sent data bit = " & STD_LOGIC'image(ExampleInput(i)) severity note;
            end loop;

            wait for BAUD_PERIOD;
            serialDataIn <= '1'; --stop bit
                                 --report "Testbench sent stop bit" severity note;

            wait until dataValid = '1';
            if ExampleInput = parallelDataOut then
                report "Testbench complete. Recieved data is correct" severity note;
            else
                report "Testbench complete. Recieved data is incorrect" severity warning;
            end if;
            wait for 1us;
            finish;

        end process;

    end;
