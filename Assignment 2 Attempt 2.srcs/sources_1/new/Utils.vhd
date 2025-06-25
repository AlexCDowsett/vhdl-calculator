--------------------------------------------------------------------------------
-- Title       : EEE3027, Digital Design with VHDL - Assignment II
-- Project     : UART Calculator
--------------------------------------------------------------------------------
-- File        : Utils.vhd
-- University  : University of Surrey
-- Created     : Sat May  4 20:28:55 2024
-- Platform    : Vivado 2022.2
-- Standard    : VHDL-2008
-------------------------------------------------------------------------------
-- Description: Various utility functions used within testbenches in this project.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package Clock_Utils is

    procedure Clock (signal C : out std_logic; HT, LT : TIME);
end Clock_Utils;

package body Clock_Utils is
    procedure Clock (signal C : out std_logic; HT, LT : TIME) is
begin

    loop C <= '1' after LT, '0' after LT + HT; wait for LT + HT;

    end loop;

    end;

    end Clock_Utils;

    library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.numeric_std.all;

    package Utils is

        function to_ASCII (char     : character) return std_logic_vector;
        function to_character (slv8 : std_logic_vector) return character;
        function to_hstring(slv     : std_logic_vector) return string;

    end Utils;

    package body Utils is

        -- Converts a character to its ASCII value as a STD_LOGIC_VECTOR.
        function to_ASCII (char : character) return std_logic_vector is
            variable slv8 : std_logic_vector (7 downto 0);

        begin
            slv8 := std_logic_vector(to_unsigned(character'pos(char), 8));

            return slv8;

        end function to_ASCII;

        -- Converts a STD_LOGIC_VECTOR containing a ASCII value to a character.
        function to_character (slv8 : std_logic_vector) return character is
            variable char : character;

        begin
            char := character'val(to_integer(unsigned(slv8)));

            return char;

        end function to_character;




        -- Below code is from https://www.reddit.com/r/FPGA/comments/il6k82/how_to_print_an_std_logic_vector_in_report/
        -- as a workaround due to lack of to_hstring function using VHDL 2008. 
        -- It convert a STD_LOGIC_VECTOR to its hexadecimal value as a string.
        function to_hstring(slv : std_logic_vector) return string is

            constant hexlen  : integer                                 := (slv'length+3)/4;
            variable longslv : std_logic_vector(slv'length+3 downto 0) := (others => '0');
            variable hex     : string(1 to hexlen);
            variable fourbit : std_logic_vector(3 downto 0);

        begin
            longslv(slv'length-1 downto 0) := slv;

            for i in hexlen-1 downto 0 loop

                fourbit := longslv(i*4+3 downto i*4);

                case fourbit is

                    when "0000" => hex(hexlen-i) := '0';
                    when "0001" => hex(hexlen-i) := '1';
                    when "0010" => hex(hexlen-i) := '2';
                    when "0011" => hex(hexlen-i) := '3';
                    when "0100" => hex(hexlen-i) := '4';
                    when "0101" => hex(hexlen-i) := '5';
                    when "0110" => hex(hexlen-i) := '6';
                    when "0111" => hex(hexlen-i) := '7';
                    when "1000" => hex(hexlen-i) := '8';
                    when "1001" => hex(hexlen-i) := '9';
                    when "1010" => hex(hexlen-i) := 'A';
                    when "1011" => hex(hexlen-i) := 'B';
                    when "1100" => hex(hexlen-i) := 'C';
                    when "1101" => hex(hexlen-i) := 'D';
                    when "1110" => hex(hexlen-i) := 'E';
                    when "1111" => hex(hexlen-i) := 'F';
                    when "ZZZZ" => hex(hexlen-i) := 'Z';
                    when "UUUU" => hex(hexlen-i) := 'U';
                    when "XXXX" => hex(hexlen-i) := 'X';
                    when others => hex(hexlen-i) := '?';

                end case;

            end loop;

            return hex;

        end function to_hstring;

    end Utils;




	