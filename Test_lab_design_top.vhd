----------------------------- ---------------------------------------------------
-- Title       : EEE3027, Digital Design with VHDL - Assignment II
-- Project     : UART Calculator
--------------------------------------------------------------------------------
-- File        : Test_lab_design_top.vhd
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


entity Test_lab_design_top is
    generic (
        BAUD_RATE   : integer := 115_200;
        CLOCK_RATE  : integer := 50_000_000;
        DELAY_VALUE : integer := 100;
        TEST_DIP    : boolean := false
    ); end;

    architecture Structure of Test_lab_design_top is


        signal reset_pin         : STD_LOGIC;
        signal clock_pin         : STD_LOGIC;
        signal serialDataIn_pin  : STD_LOGIC;
        signal serialDataOut_pin : STD_LOGIC;
        signal LED_hi_pin        : STD_LOGIC;
        signal LED_lo_pin        : STD_LOGIC;
        signal DIP_pins          : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');

        signal ASCIIOut  : STD_LOGIC_VECTOR (7 downto 0) := (others => 'U');
        signal ASCIIIn   : STD_LOGIC_VECTOR (7 downto 0) := (others => 'U');
        signal CharOut   : character;
        signal CharIn    : character;
        signal nextInput : STD_LOGIC := '0';

        type lchar is array (0 to 61) of character;

        signal ExampleChars : lchar := (
                '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',

                'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
                'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
                'U', 'V', 'W', 'X', 'Y', 'Z',

                'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
                'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
                'u', 'v', 'w', 'x', 'y', 'z');


    begin
        C : Clock(clock_pin, 10 ns, 10 ns);
        reset_pin <= '1', '0' after 40 ns;


        ldp_component : component lab_design_top
            generic map(BAUD_RATE => BAUD_RATE,
                CLOCK_RATE  => CLOCK_RATE,
                DELAY_VALUE => DELAY_VALUE,
                DEBUG_MODE  => false)
            PORT MAP(
                reset_pin         => reset_pin,
                clock_pin         => clock_pin,
                serialDataIn_pin  => serialDataIn_pin,
                serialDataOut_pin => serialDataOut_pin,
                LED_hi_pin        => LED_hi_pin,
                LED_lo_pin        => LED_lo_pin,
                DIP_pins          => DIP_pins
            );


        testbench_sender : process
            constant BAUD_PERIOD : time := (1000000000/BAUD_RATE) * 1ns;
        begin

            wait until clock_pin'EVENT and clock_pin='1'; wait for 1 ns;
            wait for BAUD_PERIOD;
            if TEST_DIP then
                loop_DIP_Pins : for i in 0 to 15 loop
                    DIP_pins <= std_logic_vector(to_unsigned(15-i, 4));
                    wait until NextInput = '1';
                end loop;
            else

                loop_ASCII_Examples : for i in 0 to 61 loop
                    CharIn           <= ExampleChars(i);
                    ASCIIIn          <= to_ASCII(ExampleChars(i));
                    serialDataIn_pin <= '0'; --start bit
                    send_Data : for j in 0 to 7 loop
                        wait for BAUD_PERIOD;
                        serialDataIn_pin <= ASCIIIn(j); --data bit
                    end loop;
                    wait for BAUD_PERIOD;
                    serialDataIn_pin <= '1'; --stop bit
                    wait until NextInput = '1';
                end loop;
            end if;
            finish;
        end process;


        testbench_reciever : process

            constant BAUD_PERIOD : time := (1000000000/BAUD_RATE) * 1ns;
        begin
            NextInput <= '1', '0' after 20ns;
            wait until serialDataOut_pin = '0';
            wait for 0.5* BAUD_PERIOD;
            wait until clock_pin'EVENT and clock_pin='1'; wait for 1 ns;
            for i in 0 to 7 loop
                wait for BAUD_PERIOD;
                ASCIIOut(i) <= serialDataOut_pin;
            --report "Recieved data bit " & integer'image(i) & " = "& std_logic'image(serialDataOut_pin) severity note;
            end loop;
            wait for BAUD_PERIOD;
            if serialDataOut_pin = '1' then
                CharOut <= to_character(ASCIIOut);
            else -- No stop bit detected.
                ASCIIOut <= "XXXXXXXX";
                CharOut  <= '?';
            end if;
            wait for 20ns;
        end process;


        debug_LED : process(LED_hi_pin, LED_lo_pin) begin
            if not (LED_hi_pin = '0' and LED_lo_pin = '0') then
                report "LED high = " & std_logic'image(LED_hi_pin) &
                ", LED low = " & std_logic'image(LED_lo_pin) severity note;
            end if;

        end process;

        debug_CharOut : process(CharOut) begin
            if TEST_DIP then
                report "Character recieved from UART for DIP value of 0x" & to_hstring(DIP_pins) & " = '" & CharOut & "' (0x" & to_hstring(ASCIIOut) & ")." severity note;
            elsif ASCIIOut = "XXXXXXXX" then
                report "No stop bit recieved." severity error;
            elsif (to_integer(unsigned(ASCIIIn)) - to_integer(unsigned(ASCIIOut))) = 32 then
                report "Character recieved from UART = '" & CharOut & "' (0x" & to_hstring(ASCIIOut) & ") is correct and been capatilised by DECODER." severity note;
            elsif (to_integer(unsigned(ASCIIOut)) - to_integer(unsigned(ASCIIIn))) = 32 then
                report "Character recieved from UART = '" & CharOut & "' (0x" & to_hstring(ASCIIOut) & ") is correct and been uncapatilised by DECODER." severity note;
            elsif CharIn = CharOut then
                report "Character recieved from UART = '" & CharOut & "' (0x" & to_hstring(ASCIIOut) & ") is correct." severity note;
            else
                report "Character recieved from UART = '" & CharOut & "' (0x" & to_hstring(ASCIIOut) & ") is incorrect." severity error;
            end if;
        end process;

        debug_CharIn : process(CharIn) begin
            report "Character sent to UART = " & CharIn & " (0x" & to_hstring(ASCIIIn) & ")." severity note;
        end process;
    end;
