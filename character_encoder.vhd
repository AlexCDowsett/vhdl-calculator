--------------------------------------------------------------------------------
-- Title       : EEE3027, Digital Design with VHDL - Assignment II
-- Project     : UART Calculator
--------------------------------------------------------------------------------
-- File        : character_encoder.vhd
-- University  : University of Surrey
-- Created     : Sat May  4 20:28:55 2024
-- Platform    : Vivado 2022.2
-- Standard    : VHDL-2008
-------------------------------------------------------------------------------
-- Description: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.Utils.all;

entity character_encoder is
    Generic (
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

end entity character_encoder;

architecture Behavioral of character_encoder is

	signal DIP_value : std_logic_vector(7 downto 0) := (others => 'U');
	signal DIP_valid : std_logic                    := 'U';

begin

	do_DIP : process (clk)

		variable DIP_last_value : std_logic_vector(3 downto 0) := (others => '0'); 

	begin

		sync_events : if rising_edge(clk) then
			DIP_valid <= '0';

			DIP_changed : if (DIP_dbncd /= DIP_last_value) and (DIP_dbncd /= "UUUU") then    --added  and (DIP_dbncd /= "UUUU")
				DIP_valid <= '1';

				DIP_ENCODE : case (DIP_dbncd) is

					when X"0"   => DIP_value <= X"30";
					when X"1"   => DIP_value <= X"31";
					when X"2"   => DIP_value <= X"32";
					when X"3"   => DIP_value <= X"33";
					when X"4"   => DIP_value <= X"34";
					when X"5"   => DIP_value <= X"35";
					when X"6"   => DIP_value <= X"36";
					when X"7"   => DIP_value <= X"37";
					when X"8"   => DIP_value <= X"38";
					when X"9"   => DIP_value <= X"39";
					when X"A"   => DIP_value <= X"41";
					when X"B"   => DIP_value <= X"42";
					when X"C"   => DIP_value <= X"43";
					when X"D"   => DIP_value <= X"44";
					when X"E"   => DIP_value <= X"45";
					when X"F"   => DIP_value <= X"46";
					when others => DIP_value <= X"3F";

				end case DIP_ENCODE;

			end if DIP_changed;
			if DIP_dbncd /= "UUUU" then --ADDED THIS
			DIP_last_value := DIP_dbncd; end if;
		end if sync_events;
	end process do_DIP;

	do_select : process (clk)

		variable decoder_buffer : std_logic_vector(7 downto 0) := (others => 'U');
		variable DIP_buffer   : std_logic_vector(7 downto 0) := (others => 'U');
		variable char_pending : boolean                      := false;
		variable DIP_pending  : boolean                      := false;

	begin

		sync_events : if rising_edge(clk) then
			buf_decoder : if (character_decoded = '1') then
				decoder_buffer := character_to_send;
				char_pending := true;
				--report "CHAR BUFFERED" severity note;

			end if buf_decoder;

			DIP_buf : if (DIP_valid = '1') then
				DIP_buffer  := DIP_value;
				DIP_pending := true;
				--report "DIP BUFFERED" severity note;

			end if DIP_buf;

			do_send_char : if ((tx_ready = '1') and char_pending) then
				parallelDataIn  <= decoder_buffer;
				transmitRequest <= '1';
				char_pending    := false;
				--report "CHAR SENT" severity note;

			elsif ((tx_ready = '1') and DIP_pending) then
				parallelDataIn  <= DIP_buffer;
				transmitRequest <= '1';
				DIP_pending     := false;
				--report "DIP SENT" severity note;

			else
				transmitRequest <= '0';
			end if do_send_char;

		end if sync_events;

	end process do_select;
	
	debug_DIP_valid : process (DIP_valid) begin
	   if DEBUG_MODE and DIP_valid = '1' then
	       report "DIP valid." severity note;
	       
	   end if; end process;
	   
	debug_DIP_value : process (DIP_value) begin
	   if DEBUG_MODE then
	       report "DIP value = 0x" & to_hstring(DIP_value) severity note;
	   end if; end process;
	       

end Behavioral;