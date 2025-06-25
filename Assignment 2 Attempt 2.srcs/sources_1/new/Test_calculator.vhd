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
use IEEE.NUMERIC_STD.all;


entity Test_calculator is
	generic (
		BAUD_RATE  : integer := 115_200;
		CLOCK_RATE : integer := 50_000_000


	); end;

	architecture Structure of Test_calculator is



		signal input_sent      : STD_LOGIC;
		signal input           : character;
		signal input_ASCII     : STD_LOGIC_VECTOR (7 downto 0);
		signal output_received : STD_LOGIC;
		signal output          : character;
		signal output_ASCII    : STD_LOGIC_VECTOR (7 downto 0);
		signal tx_ready        : STD_LOGIC := '0';

		signal reset_pin : STD_LOGIC;
		signal clock_pin : STD_LOGIC;
		--signal serialDataIn_pin  : STD_LOGIC;
		--signal serialDataOut_pin : STD_LOGIC;
		signal LED_hi_pin : STD_LOGIC;
		signal LED_lo_pin : STD_LOGIC;
		--signal DIP_pins          : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');

		--signal ASCIIOut : STD_LOGIC_VECTOR (7 downto 0) := (others => 'U');
		--signal ASCIIIn: STD_LOGIC_VECTOR (7 downto 0) := (others => 'U');
		--signal CharOut: character;
		--signal CharIn: character;
		--signal nextInput: STD_LOGIC := '0';

		type lchar is array (0 to 61) of character;

		signal ExampleChars : lchar := (
				'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',

				'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
				'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
				'U', 'V', 'W', 'X', 'Y', 'Z',

				'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
				'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
				'u', 'v', 'w', 'x', 'y', 'z');


		component calculator
			generic (DEBUG_MODE : boolean := false); -- Default not in debug mode

			port(
				reset              : in STD_LOGIC;
				clk                : in STD_LOGIC;
				charFromUART_valid : in STD_LOGIC;
				charFromUART       : in STD_LOGIC_VECTOR (7 downto 0);

				transmitRequest : out STD_LOGIC;
				charToUART      : out STD_LOGIC_VECTOR (7 downto 0);
				tx_ready        : in  STD_LOGIC;

				LED_hi : out STD_LOGIC;
				LED_lo : out STD_LOGIC

			);
		end component;

	begin
		C : Clock(clock_pin, 10 ns, 10 ns);
		reset_pin <= '1', '0' after 40 ns;
		ClockTX : Clock(tx_ready, 19ns, 750ms);

		calc_tb : component calculator
			GENERIC MAP ( DEBUG_MODE => true)
			PORT MAP(
				reset              => reset_pin,
				clk                => clock_pin,
				charFromUART_valid => input_sent,
				transmitRequest    => output_received,
				charFromUART       => input_ASCII,
				charToUART         => output_ASCII,
				tx_ready           => tx_ready,
				LED_hi             => LED_hi_pin,
				LED_lo             => LED_lo_pin
			);


		testbench : process
			constant BAUD_PERIOD : time   := (1000000000/BAUD_RATE) * 1ns;
			constant testInput   : string := ("23*79=");
		begin
			wait until clock_pin'EVENT and clock_pin='1'; wait for 1 ns;

			wait for 100ns;

			for i in testInput'range loop
				input       <= testInput(i);
				input_ASCII <= to_ASCII(testInput(i));
				input_sent  <= '1', '0' after 20 ns;
				report "Sent digit = '" & testInput(i) & "'. (0x" & to_hstring(input_ASCII) & ").";
				wait for 1200ms;
			end loop;
			wait for 4000ms;
			finish;
		end process;

		convert_ASCII : process(output_received)
		begin
			if output_received = '1' then
				output <= to_character(output_ASCII);
			else
				if output_ASCII = X"20" then
					report "Received Space character.";
				else
					report "Received Number = " & output & " (0x" & to_hstring(output_ASCII) & ").";
				end if;
			end if;
		end process;




	end;
