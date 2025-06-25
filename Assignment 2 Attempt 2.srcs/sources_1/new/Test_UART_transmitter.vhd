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

entity Test_UART_transmitter is end; -- runs forever, use break!!

architecture Structure of Test_UART_transmitter is

    signal reset              : STD_LOGIC;
    signal clk                : STD_LOGIC;
    signal baudRateEnable     : STD_LOGIC;
    signal baudRateEnable_x16 : STD_LOGIC;
    signal parallelDataIn     : STD_LOGIC_VECTOR (7 downto 0);
    signal transmitRequest    : STD_LOGIC;
    signal ready              : STD_LOGIC;
    signal serialDataOut      : STD_LOGIC;

begin
    C : Clock(clk, 10 ns, 10 ns);
    reset <= '1', '0' after 40 ns;

    UBRGTB : UART_baudRateGenerator
        generic map(115_200, 50_000_000)
        port map (reset, clk, baudRateEnable, baudRateEnable_x16);

    xmitTB : UART_transmitter
        generic map(true)
        PORT MAP(
            reset           => reset,
            clock           => clk,
            baudRateEnable  => baudRateEnable,
            parallelDataIn  => parallelDataIn,
            transmitRequest => transmitRequest,
            ready           => ready,
            serialDataOut   => serialDataOut
        );


    testbench : process begin

        wait for 100ns;
        parallelDataIn <= X"47";
        wait for 100ns;
        transmitRequest <= '1';
        report "transmitRequest = 1" severity note;
        wait for 110us;
        transmitRequest <= '0';
        report "transmitRequest = 0" severity note;
        wait until ready = '1';
        report "UART transmitter ready." severity note;
        report "Testbench complete." severity note;
        wait for 1us; finish;
    end process;

end;
