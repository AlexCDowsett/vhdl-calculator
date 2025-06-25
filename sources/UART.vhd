--------------------------------------------------------------------------------
-- Title       : EEE3027, Digital Design with VHDL - Assignment II
-- Project     : UART Calculator
--------------------------------------------------------------------------------
-- File        : UART.vhd
-- University  : University of Surrey
-- Created     : Sat May  4 20:28:55 2024
-- Platform    : Vivado 2022.2
-- Standard    : VHDL-2008
-------------------------------------------------------------------------------
-- Description: Compiles UART reciever, transmitter, Baud Rate Generator into a
--				single component.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity UART is

	generic (
		BAUD_RATE  : integer := 115200;
		CLOCK_RATE : integer := 25000000;
		DEBUG_MODE : boolean := false
	);

	port (
		reset           : in  STD_LOGIC;
		clock           : in  STD_LOGIC;
		serialDataIn    : in  STD_LOGIC;
		parallelDataOut : out STD_LOGIC_VECTOR (7 downto 0);
		dataValid       : out STD_LOGIC;
		parallelDataIn  : in  STD_LOGIC_VECTOR (7 downto 0);
		transmitRequest : in  STD_LOGIC;
		txIsReady       : out STD_LOGIC;
		serialDataOut   : out STD_LOGIC
	);

end entity UART;


architecture Behavioral of UART is

	use work.multi_components.all;

	signal baudRateEnable     : std_logic := 'U';
	signal baudRateEnable_x16 : std_logic := 'U';

begin

	rateGen : UART_baudRateGenerator

		generic map (
			BAUD_RATE  => BAUD_RATE,
			CLOCK_RATE => CLOCK_RATE,
			DEBUG_MODE => DEBUG_MODE
		)

		port map(
			reset              => reset,
			clock              => clock,
			baudRateEnable     => baudRateEnable,
			baudRateEnable_x16 => baudRateEnable_x16
		);

	xmit : UART_transmitter

		generic map (
			DEBUG_MODE => DEBUG_MODE
		)

		PORT MAP(
			reset           => reset,
			clock           => clock,
			baudRateEnable  => baudRateEnable,
			parallelDataIn  => parallelDataIn,
			transmitRequest => transmitRequest,
			ready           => txIsReady,
			serialDataOut   => serialDataOut
		);

	rcvr : UART_receiver

		generic map (
			DEBUG_MODE => DEBUG_MODE
		)

		PORT MAP(
			reset              => reset,
			clock              => clock,
			baudRateEnable_x16 => baudRateEnable_x16,
			serialDataIn       => serialDataIn,
			parallelDataOut    => parallelDataOut,
			dataValid          => dataValid
		);


end architecture Behavioral;