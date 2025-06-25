--------------------------------------------------------------------------------
-- Title       : EEE3027, Digital Design with VHDL - Assignment II
-- Project     : UART Calculator
--------------------------------------------------------------------------------
-- File        : calculator.vhd
-- University  : University of Surrey
-- Created     : Sat May  4 20:28:55 2024
-- Platform    : Vivado 2022.2
-- Standard    : VHDL-2008
-------------------------------------------------------------------------------
-- Description: A component that encoders and decoders to UART and stores inputs for calculations, calculates and outputs.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity calculator is
	generic (
		DEBUG_MODE      : boolean := false;
		CLOCK_FREQUENCY : integer := 50_000_000

	); -- Default not in debug mode


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

end entity;

architecture Behavioral of calculator is

	type legalStates is (IDLE, ADD, SUBTRACT, DIVIDE, MULTIPLY, EQUALS, CLEAR, CLEARALL); -- STATETYPE can be either I (init), C (Check), A (Add), S (Shift), E (Exit)

	signal State     : legalStates := IDLE;
	signal nextState : legalStates := CLEAR;

	signal start_timer : std_logic             := '0';
	signal illuminate  : boolean               := false;
	signal LED_hi_req  : std_logic             := '0';
	signal LED_lo_req  : std_logic             := '0';
	signal LED_number  : integer range 0 to 15 := 0;

	signal input_current  : integer range -2048 to 2047           := 0;
	signal input_previous : integer range -2048 to 2047           := 0;
	signal output         : integer range -32768 to 32767 := 0;
	signal output_valid   : std_logic                               := '0';
	signal clear_input    : std_logic                               := '0';

	type calculateTypes is (NONE, ADD, SUBTRACT, DIVIDE, MULTIPLY, EQUALS, CANCEL);

	signal Calculate     : calculateTypes := NONE;
	signal nextCalculate : calculateTypes := NONE;
	
	type decoderStates is ();

	signal decoderState     : decoderStates := IDLE;

begin

	-- Determine the next state synchronously, based on
	-- the current state and the input
	cal_sm_sync : process (clk, reset)
		variable stateBuffer : legalStates := IDLE;
	begin
		syncEvents : if rising_edge(clk) then

			resetRun : if (reset = '1') then
				State <= CLEARALL;

			else
				case State is

					when ADD =>
						Calculate <= ADD;
						State     <= EQUALS;

					when SUBTRACT =>
						Calculate <= SUBTRACT;
						State     <= EQUALS;

					when DIVIDE =>
						Calculate <= DIVIDE;
						State     <= EQUALS;

					when MULTIPLY =>
						Calculate <= MULTIPLY;
						State     <= EQUALS;

					when EQUALS =>
						if output_valid = '1' then
							input_previous <= output;
							Calculate      <= NONE;
							clear_input    <= '1';
							State          <= CLEAR;
						end if;

					when CLEARALL =>
						nextState <= CLEAR;
						State     <= CLEAR;


					when CLEAR =>
						if nextCalculate = NONE then
							clear_input <= '0';
							State       <= IDLE;
						end if;



					when IDLE =>

						if clear_input <= '0' then

							stateBuffer := nextState;

							clear_input <= '0';
							if nextCalculate /= NONE and nextState = CLEAR then
								clear_input <= '1';
							end if;

							case nextCalculate is
								when ADD =>
									nextState <= ADD;
									State     <= stateBuffer;
								when SUBTRACT =>
									nextState <= SUBTRACT;
									State     <= stateBuffer;
								when DIVIDE =>
									nextState <= DIVIDE;
									State     <= stateBuffer;
								when MULTIPLY =>
									nextState <= MULTIPLY;
									State     <= stateBuffer;
								when EQUALS =>
									clear_input <= '0';
									State       <= nextState;
									nextState   <= CLEAR;
								when CANCEL =>
									clear_input <= '1';
									State       <= CLEARALL;
								when NONE =>
									State <= IDLE;

							end case;

							if nextState = CLEAR then
								input_previous <= input_current;
							end if;
						end if;

				end case;
			end if resetRun;
		end if syncEvents;

	end process cal_sm_sync;



	-- Determine the output based only on the current state
	-- and the input (do not wait for a clock edge).
	cal_sm_async : process (State, input_current)

	begin
		case State is
			when IDLE =>

			when ADD =>

			when SUBTRACT =>

			when DIVIDE =>

			when MULTIPLY =>

			when EQUALS =>

			when CLEAR =>

			when CLEARALL =>

		end case;
	end process cal_sm_async;
	
	
		cal_sm_sync : process (clk, reset)
		variable begin_decode := '0'
	begin
		syncEvents : if rising_edge(clk) then

			resetRun : if (reset = '1') then
				State <= ...;

			else
				case State is

					when => IDLE
					   if output_valid = '1'
                            begin_decode := '1';
                       end if;
	character_encoder : process (clk)

		variable decoder_raw_buffer : integer range -32768 to 32767 := 0;
		type digits is array (0 to 4) of integer range -1 to 9 ;
		variable digits_buffer : digits := (others => -1);
		variable digits_length : integer range 1 to 5 := 1;
		variable char_buffer   : integer range 0 to 9;
		variable char_pending  : boolean := false;
		variable negative      : boolean := false;
		variable cooldown      : boolean := false;
		variable factor : integer range 0 to 10000 := 0;
		variable counter : integer range 0 to 5 := 0;


	begin

		sync_events : if rising_edge(clk) then
		   
			buf_decoder : if (output_valid = '1') then
				decoder_raw_buffer := output;
				negative := false;

				digits_buffer := (others => 0);
				digits_length := 1;
                factor := 10000;
                counter := 5;

				if decoder_raw_buffer < 0 then
					negative           := true;
					decoder_raw_buffer := decoder_raw_buffer * (-1);
				end if;

            end if buf_decoder;
            
            if counter > 0 then 
                    
				if (decoder_raw_buffer mod factor) /= decoder_raw_buffer then
					digits_buffer(counter-1)   := decoder_raw_buffer / factor;
					decoder_raw_buffer := decoder_raw_buffer - (digits_buffer(counter-1) * factor);
					
					if digits_length = 1 then
						digits_length := counter;
					end if;
				end if;
				if counter = 1 then 
					 char_pending := true; 
				end if;
		
				factor := factor / 10;
				counter := counter - 1;
				
				
				
            end if;
		




			do_send_char : if ((tx_ready = '1') and char_pending) then
				if cooldown then
					transmitRequest <= '0';
					cooldown        := false;
				else

					send_type : if negative then
						charToUART      <= X"2D";
						transmitRequest <= '1';
						negative        := false;
						cooldown        := true;

					elsif digits_length > 0 then
						char_buffer := digits_buffer(digits_length - 1);
						encode : case (char_buffer) is

							when 0 => charToUART <= X"30";
							when 1 => charToUART <= X"31";
							when 2 => charToUART <= X"32";
							when 3 => charToUART <= X"33";
							when 4 => charToUART <= X"34";
							when 5 => charToUART <= X"35";
							when 6 => charToUART <= X"36";
							when 7 => charToUART <= X"37";
							when 8 => charToUART <= X"38";
							when 9 => charToUART <= X"39";
						end case encode;
						transmitRequest <= '1';
						cooldown        := true;

						digits_length := digits_length - 1;

					else
						charToUART      <= X"20";
						transmitRequest <= '1';
						char_pending    := false;

					end if send_type;
				end if;
			else
				transmitRequest <= '0';
			end if do_send_char;


		end if sync_events;

	end process character_encoder;

	character_decoder : process (clk)
		variable input_buffer : integer range -32768 to 32767 := 0;
	begin

		syncEvents : if rising_edge(clk) then
			input_buffer := 10 * input_current;
			clear_inputs : if clear_input = '1' or reset = '1' then
				input_buffer  := 0;
				input_current <= 0;
				nextCalculate <= NONE;
			end if clear_inputs;

			start_timer <= '0';

			data_good : if (charFromUART_valid = '1') then
				whatKind : if ((charFromUART >= X"30") and (charFromUART <= X"39")) then -- 0-9
					LED_lo_req    <= '0';
					LED_hi_req    <= '1';
					LED_number    <= to_integer(unsigned(charFromUART)) - 47;
					input_current <= input_buffer + to_integer(unsigned(charFromUART)) - 48;


				elsif charFromUART = X"2A" then -- *
					LED_lo_req    <= '1';
					LED_hi_req    <= '0';
					LED_number    <= 3;
					nextCalculate <= MULTIPLY;

				elsif charFromUART = X"2B" then -- +
					LED_lo_req    <= '1';
					LED_hi_req    <= '0';
					LED_number    <= 1;
					nextCalculate <= ADD;

				elsif charFromUART = X"2D" then -- -
					LED_lo_req    <= '1';
					LED_hi_req    <= '0';
					LED_number    <= 2;
					nextCalculate <= SUBTRACT;

				elsif charFromUART = X"2F" then -- /
					LED_lo_req    <= '1';
					LED_hi_req    <= '0';
					LED_number    <= 4;
					nextCalculate <= DIVIDE;

				elsif charFromUART = X"3D" then -- =
					LED_lo_req    <= '1';
					LED_hi_req    <= '1';
					LED_number    <= 2;
					nextCalculate <= EQUALS;

				elsif charFromUART = X"18" then -- CLEAR
					LED_lo_req    <= '1';
					LED_hi_req    <= '1';
					LED_number    <= 3;
					nextCalculate <= CANCEL;
				else
					LED_lo_req <= '0';
					LED_hi_req <= '0';
					LED_number <= 1;
					-- Invalid character for calculator

				end if whatKind;
				start_timer <= '1';

			end if;
		end if syncEvents;
	end process character_decoder;

	calculator : process (clk)
		--variable input_current : signed (15 downto 0) := (others => '0'); -- 16-bit.   (-32768 to 32767)

	begin

		syncEvents : if rising_edge(clk) then
			do_calculate : if Calculate /= NONE then
				output_valid <= '1';
				whatKind : if Calculate = DIVIDE then -- /
					output <= input_previous / input_current;

				elsif Calculate = MULTIPLY then -- *
					output <= input_previous * input_current;

				elsif Calculate = ADD then -- +
					output <= input_previous + input_current;

				elsif Calculate = SUBTRACT then -- -
					output <= input_previous - input_current;

				end if whatKind;
			else
				output_valid <= '0';
			end if do_calculate;
		end if syncEvents;
	end process calculator;

	--mk_timer : process (clk)

	--	variable TERMINAL_COUNT : integer := CLOCK_FREQUENCY * 1;
	--	variable timer_value   : integer range 0 to TERMINAL_COUNT := 0;
	--	variable timer_running : integer range 0 to 15             := 0;
	--begin

	--	sync_events : if rising_edge(clk) then

	--		start_reset_timer : if (start_timer = '1') then
	--			timer_value := 0;
	--			timer_running  := LED_number * 2;
	--			TERMINAL_COUNT := CLOCK_FREQUENCY / (LED_number*2);

	--		end if start_reset_timer;

	--		do_count : if (timer_running /= 0) then
	--			timer_value := timer_value + 1;

	--	end if do_count;

		--	stop_timer : if (timer_value = TERMINAL_COUNT) then
		--		timer_running := timer_running - 1;
		--		timer_value   := 0;

	--		end if stop_timer;

	--		ifEven : if (timer_running mod 2) = 0 and timer_running /= 0 then
		--		illuminate <= true;
		--	else
		--		illuminate <= false;
		--	end if ifEven;

--		end if sync_events;
--	end process mk_timer;

--	do_LEDs : process (clk)

--	begin

--		sync_events : if rising_edge(clk) then
--			LED_hi <= '0';
--			LED_lo <= '0';

--			LEDS_are_on : if illuminate then
--				LED_hi <= LED_hi_req;
--				LED_lo <= LED_lo_req;

--			end if LEDS_are_on;

--		end if sync_events;
--	end process do_LEDs;


end;