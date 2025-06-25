--------------------------------------------------------------------------------
-- Title       : EEE3027, Digital Design with VHDL - Assignment II
-- Project     : UART Calculator
--------------------------------------------------------------------------------
-- File        : lab_design_top_calc.vhd
-- University  : University of Surrey
-- Created     : Sat May  4 20:28:55 2024
-- Platform    : Vivado 2022.2
-- Standard    : VHDL-2008
-------------------------------------------------------------------------------
-- Description: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lab_design_top_calc is

   generic (
      BAUD_RATE   : integer := 115200;
      CLOCK_RATE  : integer := 50000000;
      DELAY_VALUE : integer := 50000000;
      DEBUG_MODE  : boolean := false
   );


   port (
      reset_pin         : in  STD_LOGIC;
      clock_pin         : in  STD_LOGIC;
      serialDataIn_pin  : in  STD_LOGIC;
      serialDataOut_pin : out STD_LOGIC;
      LED_hi_pin        : out STD_LOGIC;
      LED_lo_pin        : out STD_LOGIC;
      DIP_pins          : in  STD_LOGIC_VECTOR (3 downto 0)
   );

end entity lab_design_top_calc;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.multi_components.all;
use work.Utils.all;

architecture structural of lab_design_top_calc is

   signal parallelDataOut   : std_logic_vector(7 downto 0) := (others => 'U');
   signal dataValid         : std_logic                    := 'U';
   signal parallelDataIn    : std_logic_vector(7 downto 0) := (others => 'U');
   signal transmitRequest   : std_logic                    := 'U';
   signal tx_ready          : std_logic                    := 'U';
   signal send_character    : std_logic                    := 'U';
   signal character_to_send : std_logic_vector(7 downto 0) := (others => 'U');
   signal DIP_debounced     : std_logic_vector(3 downto 0) := (others => '0');
   signal gnd               : std_logic                    := '0';

begin

   make_UART : UART

      generic map (
         BAUD_RATE  => BAUD_RATE,
         CLOCK_RATE => CLOCK_RATE
      )

      port map(
         reset           => reset_pin,
         clock           => clock_pin,
         serialDataIn    => serialDataIn_pin,
         parallelDataOut => parallelDataOut,
         dataValid       => dataValid,
         parallelDataIn  => parallelDataIn,
         transmitRequest => transmitRequest,
         txIsReady       => tx_ready,
         serialDataOut   => serialDataOut_pin
      );

   calc : component calculator
      generic map (
         CLOCK_FREQUENCY => CLOCK_RATE,
         DEBUG_MODE      => false
      )
      PORT MAP(
         reset              => reset_pin,
         clk                => clock_pin,
         charFromUART_valid => dataValid,
         transmitRequest    => transmitRequest,
         charFromUART       => parallelDataOut,
         charToUART         => parallelDataIn,
         tx_ready           => tx_ready,
         LED_hi             => LED_hi_pin,
         LED_lo             => LED_lo_pin
      );

   DIP_debouncers : for i in 0 to 3 generate

      dbncr : debouncer

         generic map (
            DELAY_VALUE => DELAY_VALUE
         )

         port map(
            clk        => clock_pin,
            signal_in  => DIP_pins(i),
            signal_out => DIP_debounced(i)
         );
   end generate DIP_debouncers;

   debug_ParallelDataIn : process (transmitRequest) begin
      if DEBUG_MODE and transmitRequest = '1' then
         report "ParallelDataIn = 0x" & to_hstring(ParallelDataIn) severity note;
      end if; end process;

      debug_ParallelDataOut : process (dataValid) begin
         if DEBUG_MODE and dataValid = '1' then
            report "ParallelDataOut = 0x" & to_hstring(ParallelDataOut) severity note;
         end if; end process;

         -- debug_DIP_dbncd : process(DIP_debounced) begin
         ---    report "DIP_debounced = " & std_logic'image(DIP_debounced(0)) & std_logic'image(DIP_debounced(1))& std_logic'image(DIP_debounced(2))& std_logic'image(DIP_debounced(3))severity note;
         --    end process;

         -- debug_DIP : process(DIP_pins) begin
         --    report "DIP = " & std_logic'image(DIP_pins(0)) & std_logic'image(DIP_pins(1))& std_logic'image(DIP_pins(2))& std_logic'image(DIP_pins(3))severity note;
         --    end process;

      end structural;