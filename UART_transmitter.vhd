--------------------------------------------------------------------------------
-- Title       : EEE3027, Digital Design with VHDL - Assignment II
-- Project     : UART Calculator
--------------------------------------------------------------------------------
-- File        : UART_transmitter.vhd
-- University  : University of Surrey
-- Created     : Sat May  4 20:28:55 2024
-- Platform    : Vivado 2022.2
-- Standard    : VHDL-2008
-------------------------------------------------------------------------------
-- Description: A component that transmits a STD_LOGIC_VECTOR ASCII value through
-- a 1 wide signal using the universal UART standard.
--------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_transmitter is

	Generic (
		DEBUG_MODE : boolean := false
	);

	Port (
		reset           : in  STD_LOGIC;
		clock           : in  STD_LOGIC;
		baudRateEnable  : in  STD_LOGIC;
		parallelDataIn  : in  STD_LOGIC_VECTOR (7 downto 0);
		transmitRequest : in  STD_LOGIC;
		ready           : out STD_LOGIC;
		serialDataOut   : out STD_LOGIC
	);

end entity UART_transmitter;


architecture Behavioral of UART_transmitter is
	type legalStates is (IDLE, SEND_START_BIT, SEND_DATA_BITS, SEND_STOP_BIT);
	signal txState : legalStates := IDLE;

begin
	tx_sm : process (clock)

		variable dataToTX  : std_logic_vector(7 downto 0);
		variable bitToSend : integer range 0 to 7 := 0;
		variable go        : std_logic            := '0';

	begin
		syncEvents : if rising_edge(clock) then

			resetRun : if (reset = '1') then

				txState       <= IDLE;
				ready         <= '0';
				go            := '0';
				serialDataOut <= '1';

			else

				catchStart : if (transmitRequest = '1') then

					go       := '1';
					ready <= '0'; -- ADDED to disable tx_ready quicker. Helps with calculator.
					dataToTx := parallelDataIn;

				end if catchStart;

				smEnabled : if (baudRateEnable = '1') then

					sm : case (txState) is

						when IDLE =>
							ready         <= '1';
							serialDataOut <= '1';
							timeToStart : if (go = '1') then
								go        := '0';
								bitToSend := 0;
								ready     <= '0';
								txState   <= SEND_START_BIT;

							end if timeToStart;

						when SEND_START_BIT =>
							serialDataOut <= '0';
							txState <= SEND_DATA_BITS;

						when SEND_DATA_BITS =>
							serialDataOut <= dataToTx(bitToSend);

							whenDone : if (bitToSend = 7) then
								txState <= SEND_STOP_BIT;

							else
								bitToSend := bitToSend + 1;

							end if whenDone;

						when SEND_STOP_BIT =>
							serialDataOut <= '1';

							if (transmitRequest = '0') then
								txState <= IDLE;
								go      := '0';

							end if;

					end case sm;

				end if smEnabled;

			end if resetRun;


		end if syncEvents;

	end process tx_sm;


--	debug_stateEvents : process(txState)

--	begin

--		if DEBUG_MODE then

--			report "STATE = " & legalStates'image(txState) severity note;

--		end if;
		
--	end process;



end architecture Behavioral;