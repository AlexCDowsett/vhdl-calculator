--------------------------------------------------------------------------------
-- Title       : EEE3027, Digital Design with VHDL - Assignment II
-- Project     : UART Calculator
--------------------------------------------------------------------------------
-- File        : Test_UART_baudRateGenerator.vhd
-- University  : University of Surrey
-- Created     : Sat May  4 20:28:55 2024
-- Platform    : Vivado 2022.2
-- Standard    : VHDL-2008
-------------------------------------------------------------------------------
-- Description: Testbench for testing the Baud Rate Generator with different
--              clock frequencies.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Utils.all;
use work.Clock_Utils.all;
use work.multi_components.all;

entity Test_UART_baudRateGenerator is end; -- runs forever, use break!!

architecture Structure of Test_UART_baudRateGenerator is


    signal reset              : STD_LOGIC;
    signal clk                : STD_LOGIC;
    signal baudRateEnable     : STD_LOGIC;
    signal baudRateEnable_x16 : STD_LOGIC;


begin
    C : Clock(clk, 10 ns, 10 ns);
    reset <= '1', '0' after 40 ns;

    UBRG : UART_baudRateGenerator
        generic map(115_200, 50_000_000, true)
        port map (reset, clk, baudRateEnable, baudRateEnable_x16);


end;
