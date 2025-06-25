--------------------------------------------------------------------------------
-- Title       : EEE3027, Digital Design with VHDL - Assignment II
-- Project     : UART Calculator
--------------------------------------------------------------------------------
-- File        : character_decoder.vhd
-- University  : University of Surrey
-- Created     : Sat May  4 20:28:55 2024
-- Platform    : Vivado 2022.2
-- Standard    : VHDL-2008
-------------------------------------------------------------------------------
-- Description: 
--------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity character_decoder is

	generic (
		CLOCK_FREQUENCY : integer := 40_000_000;
		DEBUG_MODE : boolean := false
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

end entity character_decoder;

architecture Behavioral of character_decoder is

	signal start_timer      : std_logic := '0';
	signal illuminate       : boolean   := false;
	signal LED_hi_req       : std_logic := '0';
	signal LED_lo_req       : std_logic := '0';
	signal send_character_i : std_logic := '0';

begin

	decoder_table : process (clk)

		variable ASCII_value     : integer range 0 to 255 := 0;
		variable new_ASCII_value : integer range 0 to 255;
	begin
		sync_events : if rising_edge(clk) then

			send_character_i  <= '0';
			character_to_send <= (others => '0');
			start_timer       <= '0';

			data_good : if (charFromUART_valid = '1') then
				whatKind : if ((charFromUART >= X"61") and (charFromUART <= X"7A")) -- a-z

				then
					LED_lo_req        <= '1';
					LED_hi_req        <= '0';
					ASCII_value       := to_integer(unsigned(charFromUART));
					new_ASCII_value   := ASCII_value - 32;
					character_to_send <=
						std_logic_vector(to_unsigned(new_ASCII_value,8));

				elsif ((charFromUART >= X"41") and (charFromUART <= X"5A")) then -- A-Z
					LED_lo_req        <= '1';
					LED_hi_req        <= '0';
					ASCII_value       := to_integer(unsigned(charFromUART));
					new_ASCII_value   := ASCII_value + 32;
					character_to_send <=
						std_logic_vector(to_unsigned(new_ASCII_value,8));

				elsif ((charFromUART >= X"30") and (charFromUART <= X"39")) then -- 0-9
					LED_lo_req        <= '0';
					LED_hi_req        <= '1';
					character_to_send <= charFromUART;

				else
					LED_lo_req        <= '1';
					LED_hi_req        <= '1';
					character_to_send <= charFromUART;

				end if whatKind;
				start_timer      <= '1';
				send_character_i <= '1';

			end if data_good;

		end if sync_events;

	end process decoder_table;

	send_character <= send_character_i;
	mk_timer : process (clk)

		constant TERMINAL_COUNT : integer := CLOCK_FREQUENCY * 1;
		variable timer_value   : integer range 0 to TERMINAL_COUNT := 0;
		variable timer_running : boolean                           := false;
	begin

		sync_events : if rising_edge(clk) then

			start_reset_timer : if (start_timer = '1') then
				timer_value := 0;
				timer_running := true;

			end if start_reset_timer;

			do_count : if (timer_running) then
				timer_value := timer_value + 1;

			end if do_count;

			stop_timer : if (timer_value = TERMINAL_COUNT) then
				timer_running := false;

			end if stop_timer;

			illuminate <= timer_running;
		end if sync_events;
	end process mk_timer;

	do_LEDs : process (clk)

	begin

		sync_events : if rising_edge(clk) then
			LED_hi <= '0';
			LED_lo <= '0';

			LEDS_are_on : if (illuminate) then
				LED_hi <= LED_hi_req;
				LED_lo <= LED_lo_req;

			end if LEDS_are_on;

		end if sync_events;
	end process do_LEDs;
end Behavioral;