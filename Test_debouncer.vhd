--------------------------------------------------------------------------------
-- Title       : EEE3027, Digital Design with VHDL - Assignment II
-- Project     : UART Calculator
--------------------------------------------------------------------------------
-- File        : Test_UART.vhd
-- University  : University of Surrey
-- Created     : Sat May  4 20:28:55 2024
-- Platform    : Vivado 2022.2
-- Standard    : VHDL-2008
-------------------------------------------------------------------------------
-- Description: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use std.env.finish;
use work.Utils.all;
use work.Clock_Utils.all;
use work.multi_components.all;




entity Test_debouncer is end; -- runs forever, use break!!

architecture Structure of Test_debouncer is

    signal clk       : STD_LOGIC;
    signal signal_in : std_logic;

    signal DELAY0_out : STD_LOGIC;
    signal DELAY1_out : STD_LOGIC;
    signal DELAY2_out : STD_LOGIC;
    signal DELAY3_out : STD_LOGIC;
    signal DELAY4_out : STD_LOGIC;
    signal DELAY5_out : STD_LOGIC;
    signal DELAY6_out : STD_LOGIC;
    signal DELAY7_out : STD_LOGIC;

begin
    C : Clock(clk, 10 ns, 10 ns);


    delay0 : debouncer
        generic map (0
        )
        port map(clk,
            signal_in,
            DELAY0_out
        );



    delay1 : debouncer
        generic map (1)
        port map(clk,signal_in,DELAY1_out);


    delay2 : debouncer
        generic map (2)
        port map(clk,signal_in,DELAY2_out);




    delay3 : debouncer
        generic map (3)
        port map(clk,signal_in,DELAY3_out);



    delay4 : debouncer
        generic map (4)
        port map(clk,signal_in,DELAY4_out);



    delay5 : debouncer
        generic map (5, true)
        port map(clk,signal_in,DELAY5_out);



    delay6 : debouncer
        generic map (6)
        port map(clk,signal_in,DELAY6_out);



    delay7 : debouncer
        generic map (7)
        port map(clk,signal_in,DELAY7_out);




    -- different process for validation
    testbench : process
        variable delay : time := 200ns;

    begin

        for i in 0 to 100 loop
            wait for delay;
            signal_in <= '1';
            wait for 2*delay;
            signal_in <= '0';
            delay     := delay - 20 ns;
            report "Delay = " & time'image(delay) severity note;
        end loop;


    end process testbench;


end;
