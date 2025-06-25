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
use work.Utils.all;
use work.Clock_Utils.all;
use work.multi_components.all;

entity Test_UART is end; -- runs forever, use break!!

architecture Structure of Test_UART is


    signal  reset              : STD_LOGIC;
	signal	clk              : STD_LOGIC;
    signal  parallelDataIn  : STD_LOGIC_VECTOR (7 downto 0);
    signal  parallelDataOut  : STD_LOGIC_VECTOR (7 downto 0);
    signal	serialDataIn   : STD_LOGIC := '1';
    signal	serialDataOut   : STD_LOGIC := '1';
	signal	dataValid           : STD_LOGIC := '0';
	signal  txIsReady       : STD_LOGIC;
	signal transmitRequest : STD_LOGIC := '0';
	
	signal ExampleInput : std_logic_vector (7 downto 0) := "01000111";
	

begin
    C : Clock(clk, 10 ns, 10 ns);
    reset <= '1', '0' after 1 ns;
    
     make_UART : UART

      generic map (
         BAUD_RATE => 115_200,
         CLOCK_RATE => 50_000_000
      )

      port map(
         reset           => reset,
         clock           => clk,
         serialDataIn    => serialDataIn,
         parallelDataOut => parallelDataOut,
         dataValid       => dataValid,
         parallelDataIn  => parallelDataIn,
         transmitRequest => transmitRequest,
         txIsReady       => txIsReady,
         serialDataOut   => serialDataOut
      );


process begin



        wait for 100ns;
        parallelDataIn <= X"47";
        wait for 100ns;
        transmitRequest <= '1';
        
        
        wait for 8680ns;
        serialDataIn <= '0'; --start bit
        report "Start bit Sent";
        
        for i in 0 to 7 loop
            wait for 8680ns;
            serialDataIn <= ExampleInput(i);  -- number i data bit
            report "Data Bit Sent = " & STD_LOGIC'image(ExampleInput(i));
        end loop;
        
        wait for 8680ns;
        serialDataIn <= '1'; --stop bit
        report "Stop bit Sent";
        
        transmitRequest <= '0';
        
        wait for 1000us;
        
    end process;

end;
