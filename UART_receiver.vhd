--------------------------------------------------------------------------------
-- Title       : EEE3027, Digital Design with VHDL - Assignment II
-- Project     : UART Calculator
--------------------------------------------------------------------------------
-- File        : UART_receiver.vhd
-- University  : University of Surrey
-- Created     : Sat May  4 20:28:55 2024
-- Platform    : Vivado 2022.2
-- Standard    : VHDL-2008
-------------------------------------------------------------------------------
-- Description: A component that converts a UART signal using the universal UART
--				standard into a STD_LOGIC_VECTOR.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_receiver is
    generic (DEBUG_MODE : boolean := false); -- Default not in debug mode


	Port (
		reset              : in  STD_LOGIC;
		clock              : in  STD_LOGIC;
		baudRateEnable_x16 : in  STD_LOGIC;
		serialDataIn       : in  STD_LOGIC;
		parallelDataOut    : out STD_LOGIC_VECTOR (7 downto 0);
		dataValid          : out STD_LOGIC
	);

end entity UART_receiver;

architecture Behavioral of UART_receiver is

	type legalStates is (IDLE, RCV_START_BIT, RCV_DATA_BITS, RCV_STOP_BIT);

	signal rxState     : legalStates           := IDLE;
	signal countEnable : std_logic             := 'U';
	signal countDone   : std_logic             := 'U';
	signal countValue  : integer range 0 to 31 := 0;
	signal countLoad   : std_logic             := 'U';
	signal lineDown    : std_logic             := 'U';

	function stateToString(s : legalStates) return String is

	begin
		whichState : case (s) is --unused use legalState'image instead.

			when IDLE          => return "IDLE";
			when RCV_START_BIT => return "RCV_START_BIT";
			when RCV_DATA_BITS => return "RCV_DATA_BITS";
			when RCV_STOP_BIT  => return "RCV_STOP_BIT";

		end case whichState;

	end function stateToString;
begin

	rx_sm : process (clock)

		variable bitsReceived : integer range 0 to 7 := 0;
		variable lastState    : legalStates          := RCV_STOP_BIT;

	begin
		syncEvents : if rising_edge(clock) then

			resetRun : if (reset = '1') then

				rxState     <= IDLE;
				dataValid   <= '0';
				countLoad   <= '0';
				countEnable <= '0';
				lineDown    <= '0';

			else
				countLoad <= '0';
				dataValid <= '0';

				smEnabled : if (baudRateEnable_x16 = '1') then
					lastState := rxState;

					sm : case (rxState) is

						when IDLE =>
							countEnable <= '0';
							startDetect : if (serialDataIn = '0') then
								bitsReceived := 0;
								countValue   <= 7;
								countEnable  <= '1';
								countLoad    <= '1';
								rxState      <= RCV_START_BIT;

							end if startDetect;

						when RCV_START_BIT =>

							isHalfWay : if (countDone = '1') then
								stillStartBit : if (serialDataIn = '0') then
									countValue <= 15;
									countLoad <= '1';
									rxState   <= RCV_DATA_BITS;

								else
									rxState <= IDLE;

								end if stillStartBit;

							end if isHalfWay;

						when RCV_DATA_BITS =>

							countEnable <= '1';
							collectingOrDone : if (countDone = '1') then
								parallelDataOut(bitsReceived) <= serialDataIn;

								if (bitsReceived = 7) then
									rxState <= RCV_STOP_BIT;

								else
									bitsReceived := bitsReceived + 1;

								end if;
								countLoad <= '1';

							end if collectingOrDone;

						when RCV_STOP_BIT =>
							sampleStopBit : if (countDone = '1') then

								countEnable <= '0';
								isStopBit : if (serialDataIn = '1') then

									dataValid <= '1';
									rxState   <= IDLE;
								else

									lineDown <= '1';

								end if isStopBit;

							end if sampleStopBit;

							isLineDown : if (lineDown = '1') then

								checkLineLevel : if (serialDataIn = '1') then

									lineDown <= '0';
									rxState  <= IDLE;

								end if checkLineLevel;

							end if isLineDown;

					end case sm;

				end if smEnabled;

			end if resetRun;

		end if syncEvents;

	end process rx_sm;

	counter : process (clock)
		variable internalCountValue : integer range 0 to 31 := 0;

	begin

		syncEvents : if rising_edge(clock) then
			resetRun : if (reset = '1') then
				internalCountValue := 0;
				countDone <= '0';

			else
				isLoadingOrEnabled : if (countLoad = '1') then
					internalCountValue := countValue;
					countDone          <= '0';

				elsif (baudRateEnable_x16 = '1') AND (countEnable = '1') then
					countDone <= '0';

					if (internalCountValue = 1) then
						countDone <= '1';

					else
						internalCountValue := internalCountValue - 1;

					end if;

				end if isLoadingOrEnabled;

			end if resetRun;

		end if;

	end process counter;
	
--	debug_stateEvents : process (rxState) -- run process when rxState changes
--	   begin
--	      if DEBUG_MODE then -- If in debug mode, log state.
--	       report "STATE = " & legalStates'image(rxState) severity note; -- or & whichState(rxState)
--	   end if;
--	end process debug_stateEvents;

end Behavioral;