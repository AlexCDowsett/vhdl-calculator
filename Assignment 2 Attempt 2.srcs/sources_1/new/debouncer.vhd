--------------------------------------------------------------------------------
-- Title       : EEE3027, Digital Design with VHDL - Assignment II
-- Project     : UART Calculator
--------------------------------------------------------------------------------
-- File        : debouncer.vhd
-- University  : University of Surrey
-- Created     : Sat May  4 20:28:55 2024
-- Platform    : Vivado 2022.2
-- Standard    : VHDL-2008
-------------------------------------------------------------------------------
-- Description: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity debouncer is
	Generic (
		DELAY_VALUE : integer := 100;
		DEBUG_MODE : boolean := false
	);

	Port (
		clk        : in  STD_LOGIC;
		signal_in  : in  STD_LOGIC;
		signal_out : out STD_LOGIC
	);

end entity debouncer;

architecture Behavioral of debouncer is

	type legalStates is (INIT_OUTPUT, IDLING, WAITING, CHANGING);

	signal countReset : std_logic := 'U';
	signal countDone  : std_logic := 'U';

begin

	dbnceSM : process (clk)

		variable state     : legalStates := INIT_OUTPUT;
		variable lastInput : std_logic   := '0';

	begin

		sync_events : if rising_edge(clk) then

			case state is

				when INIT_OUTPUT =>
					signal_out <= '0';
					state      := IDLING;

				when IDLING =>
					countReset <= '1'; -- Start countdown

					if ((lastInput /= signal_in) and (lastInput /= 'U')) then
						countReset <= '0';
						state      := WAITING;

					end if;
					lastInput := signal_in;
					--report "lastInput" & std_logic'image(lastInput);

				when WAITING =>
					countReset <= '0';

					if (lastInput /= signal_in) then
						lastInput  := signal_in;
						countReset <= '1';

					end if;

					if (countDone = '1') then
						signal_out <= signal_in;
						countReset <= '1';
						state      := IDLING;

					end if;

				when others =>
					signal_out <= 'U';

			end case;

		end if sync_events;
	end process dbnceSM;

	cntr : process (clk)

		constant adjLimit : integer := DELAY_VALUE - 3;
		variable internalCount : integer range 0 to adjLimit := adjLimit;

	begin
		if rising_edge(clk) then

			if (countReset = '1') then

				internalCount := adjLimit;
				countDone <= '0';

			else
				countDone <= '0';

				if (internalCount = 0) then
					countDone <= '1';

				else
					internalCount := internalCount - 1;

				end if;
			end if;
		end if;
	end process cntr;
	
	
	debug_countResetEvents : process(countReset)
	begin
	   if DEBUG_MODE and countReset = '1' then
	       report "Count reset." severity note;
	   end if;
	end process;
	
	
	debug_countDoneEvents : process(countDone)
	begin
	   if DEBUG_MODE and countDone = '1' then
	       report "Count done." severity note;
	   end if;
	end process;

	
	
end Behavioral;