--------------------------------------------------------------------------------
-- Title       : EEE3027, Digital Design with VHDL - Assignment II
-- Project     : UART Calculator
--------------------------------------------------------------------------------
-- File        : multi_components.vhd
-- University  : University of Surrey
-- Created     : Sat May  4 20:28:55 2024
-- Platform    : Vivado 2022.2
-- Standard    : VHDL-2008
-------------------------------------------------------------------------------
-- Description: File that defines each component used in this project and their 
-- 				baports and generic values.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package multi_components is


	component UART_baudRateGenerator

		generic (
			BAUD_RATE  : integer := 19200;
			CLOCK_RATE : integer := 100000000;
			DEBUG_MODE : boolean := false
		);

		port (
			reset              : in  STD_LOGIC;
			clock              : in  STD_LOGIC;
			baudRateEnable     : out STD_LOGIC;
			baudRateEnable_x16 : out STD_LOGIC
		);
	end component;


	component UART_transmitter

		generic (
			DEBUG_MODE : boolean := false
		);

		port (
			reset           : in  STD_LOGIC;
			clock           : in  STD_LOGIC;
			baudRateEnable  : in  STD_LOGIC;
			parallelDataIn  : in  STD_LOGIC_VECTOR (7 downto 0);
			transmitRequest : in  STD_LOGIC;
			ready           : out STD_LOGIC;
			serialDataOut   : out STD_LOGIC
		);

	end component;


	component UART_receiver

		generic (
			DEBUG_MODE : boolean := false
		);

		port (
			reset              : in  STD_LOGIC;
			clock              : in  STD_LOGIC;
			baudRateEnable_x16 : in  STD_LOGIC;
			serialDataIn       : in  STD_LOGIC;
			parallelDataOut    : out STD_LOGIC_VECTOR (7 downto 0);
			dataValid          : out STD_LOGIC
		);

	end component;


	component character_encoder

		generic (
			DEBUG_MODE : boolean := false
		);

		Port (
			clk               : in  STD_LOGIC;
			character_decoded : in  STD_LOGIC;
			character_to_send : in  STD_LOGIC_VECTOR (7 downto 0);
			tx_ready          : in  STD_LOGIC;
			parallelDataIn    : out STD_LOGIC_VECTOR (7 downto 0);
			transmitRequest   : out STD_LOGIC;
			DIP_dbncd         : in  STD_LOGIC_VECTOR (3 downto 0)
		);

	end component;


	component character_decoder

		generic (
			CLOCK_FREQUENCY : integer := 40_000_000;
			DEBUG_MODE      : boolean := false
		);

		port (
			clk                : in  STD_LOGIC;
			charFromUART_valid : in  STD_LOGIC;
			charFromUART       : in  STD_LOGIC_VECTOR(7 downto 0);
			LED_hi             : out STD_LOGIC;
			LED_lo             : out STD_LOGIC;
			send_character     : out STD_LOGIC;
			character_to_send  : out STD_LOGIC_VECTOR (7 downto 0)
		);

	end component;


	component debouncer

		generic (
			DELAY_VALUE : integer := 100;
			DEBUG_MODE  : boolean := false
		);

		port (
			clk        : in  STD_LOGIC;
			signal_in  : in  STD_LOGIC;
			signal_out : out STD_LOGIC
		);

	end component;


	component UART

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

	end component;


	component lab_design_top

		generic (
			BAUD_RATE   : integer := 115200;
			CLOCK_RATE  : integer := 50000000;
			DELAY_VALUE : integer := 50000000;
			DEBUG_MODE  : boolean := false
		);

		port (
			reset_pin         : in  STD_LOGIC;
			clock_pin         : in  STD_LOGIC;
			serialDataIn_pin  : in  STD_LOGIC;
			serialDataOut_pin : out STD_LOGIC;
			LED_hi_pin        : out STD_LOGIC;
			LED_lo_pin        : out STD_LOGIC;
			DIP_pins          : in  STD_LOGIC_VECTOR (3 downto 0)
		);

	end component;

	component calculator
		generic (
		  DEBUG_MODE      : boolean := false;
		  CLOCK_FREQUENCY : integer := 50_000_000
	    );
	   
	    port(
	       reset              : in  STD_LOGIC;
	       clk              : in  STD_LOGIC;
	       charFromUART_valid     : in STD_LOGIC;
	       charFromUART  : in STD_LOGIC_VECTOR (7 downto 0);
           transmitRequest : out STD_LOGIC;
	       charToUART :out STD_LOGIC_VECTOR (7 downto 0);
	       tx_ready          : in  STD_LOGIC;
	       LED_hi : out STD_LOGIC;
	       LED_lo : out STD_LOGIC
	);
	end component;
	
		component lab_design_top_calc

		generic (
			BAUD_RATE   : integer := 115200;
			CLOCK_RATE  : integer := 50000000;
			DELAY_VALUE : integer := 50000000;
			DEBUG_MODE  : boolean := false
		);

		port (
			reset_pin         : in  STD_LOGIC;
			clock_pin         : in  STD_LOGIC;
			serialDataIn_pin  : in  STD_LOGIC;
			serialDataOut_pin : out STD_LOGIC;
			LED_hi_pin        : out STD_LOGIC;
			LED_lo_pin        : out STD_LOGIC;
			DIP_pins          : in  STD_LOGIC_VECTOR (3 downto 0)
		);

	end component;
end package;