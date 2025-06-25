--------------------------------------------------------------------------------
-- Title       : EEE3027, Digital Design with VHDL - Assignment II
-- Project     : UART Calculator
--------------------------------------------------------------------------------
-- File        : Test_lab_design_top_calc.vhd
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


entity Test_lab_design_top_calc is
    generic (
        BAUD_RATE   : integer := 115_200;
        CLOCK_RATE  : integer := 50_000_000;
        DELAY_VALUE : integer := 100
    ); end;

    architecture Structure of Test_lab_design_top_calc is


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

        constant Input : string := ("25+67=");


    begin
        C : Clock(clock_pin, 10 ns, 10 ns);
        reset_pin <= '1', '0' after 40 ns;


        ldp_component : component lab_design_top_calc
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
            wait for 10us;
            wait until clock_pin'EVENT and clock_pin='1'; wait for 1 ns;
            wait for BAUD_PERIOD;

            loop_ASCII_Examples : for i in 1 to Input'LENGTH loop
                CharIn           <= Input(i);
                ASCIIIn          <= to_ASCII(Input(i));
                serialDataIn_pin <= '0'; --start bit
                send_Data : for j in 0 to 7 loop
                    wait for BAUD_PERIOD;
                    serialDataIn_pin <= ASCIIIn(j); --data bit
                end loop;
                wait for BAUD_PERIOD;
                serialDataIn_pin <= '1'; --stop bit
                wait for BAUD_PERIOD;
            end loop;
            wait for 6000us;
            finish;
        end process;


        testbench_reciever : process

            constant BAUD_PERIOD : time := (1000000000/BAUD_RATE) * 1ns;
        begin
            wait until serialDataOut_pin = '0';
            wait for 0.5* BAUD_PERIOD;
            wait until clock_pin'EVENT and clock_pin='1'; wait for 1 ns;
            for i in 0 to 7 loop
                wait for BAUD_PERIOD;
                ASCIIOut(i) <= serialDataOut_pin;
            --report "Recieved data bit " & integer'image(i) & " = "& std_logic'image(serialDataOut_pin) severity note;
            end loop;
            wait for BAUD_PERIOD;
            CharOut <= to_character(ASCIIOut);
            if serialDataOut_pin = '1' then
                CharOut <= to_character(ASCIIOut);
            else -- No stop bit detected.
                ASCIIOut <= "XXXXXXXX";
                CharOut  <= '?';
            end if;
            wait for 20ns;
        end process;


        debug_LED : process(LED_hi_pin, LED_lo_pin) begin
            if false and not (LED_hi_pin = '0' and LED_lo_pin = '0') then
                report "LED high = " & std_logic'image(LED_hi_pin) &
                ", LED low = " & std_logic'image(LED_lo_pin) severity note;
            end if;

        end process;

        debug_CharOut : process(CharOut) begin
            if ASCIIOut = X"20" then
                report "Space character received." severity note;
            else
                report "Character received from UART = '" & CharOut & "' (0x" & to_hstring(ASCIIOut) & ")." severity note;
            end if;
        end process;

        debug_CharIn : process(CharIn) begin
            report "Character sent to UART = " & CharIn & " (0x" & to_hstring(ASCIIIn) & ")." severity note;
        end process;
    end;
