--------------------------------------------------------------------------------
-- Title       : EEE3027, Digital Design with VHDL - Assignment II
-- Project     : UART Calculator
--------------------------------------------------------------------------------
-- File        : UART_baudRateGenerator.vhd
-- University  : University of Surrey
-- Created     : Sat May  4 20:28:55 2024
-- Platform    : Vivado 2022.2
-- Standard    : VHDL-2008
-------------------------------------------------------------------------------
-- Description: Creates a new Baud clock that is powered through the normal
--				circuit clock. Baud frequency is determined by its generic values.
--------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_baudRateGenerator is

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

	constant nCountsPerBaud     : integer := CLOCK_RATE / BAUD_RATE;
	constant nCountsPerBaud_X16 : integer := nCountsPerBaud / 16;

end entity UART_baudRateGenerator;


architecture BEHAVIORAL of UART_baudRateGenerator is

begin

	make_x16en : process (clock)
		variable clockCount : integer range 0 to nCountsPerBaud_X16 := 0; -- Range 0 to 27 for nCountsPerBaud_X16 at C = 50MHz, B = 115.2kHz

	begin
		syncEvents : if rising_edge(clock) then

			baudRateEnable_x16 <= '0';
			clockCount         := clockCount + 1;

			isCountDone : if (clockCount = nCountsPerBaud_X16) then
				baudRateEnable_x16 <= '1';
				clockCount         := 0;

			end if isCountDone;

		end if syncEvents;

	end process make_x16en;


	make_baudEn : process (clock)
		variable clockCount : integer range 0 to nCountsPerBaud := 0; -- Range 0 to 434 for nCountsPerBaud at C = 50MHz, B = 115.2kHz

	begin
		syncEvents : if rising_edge(clock) then
			baudRateEnable <= '0';
			clockCount := clockCount + 1;

			isCountDone : if (clockCount = nCountsPerBaud) then

				baudRateEnable <= '1';
				clockCount     := 0;

			end if isCountDone;

		--report "clockCount = " & integer'image(clockCount);

		end if syncEvents;

	end process make_baudEn;


--	debug : process(reset)

--	begin
--		if DEBUG_MODE and reset = '1' then

--			report "BAUD_RATE = " & integer'image(BAUD_RATE) &
--			", CLOCK_RATE = " & integer'image(CLOCK_RATE) &
--			", nCountsPerBaud = " & integer'image(nCountsPerBaud) &
--			", nCountsPerBaud_X16 = " & integer'image(nCountsPerBaud_X16) severity note;

--		end if;

--	end process debug;

end architecture BEHAVIORAL;