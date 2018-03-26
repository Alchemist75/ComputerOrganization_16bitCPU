----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:45:46 11/28/2017 
-- Design Name: 
-- Module Name:    clockForClock - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clockForClock is
    Port ( clk : in  STD_LOGIC;
			  rst : in	STD_LOGIC;
           clkForClock : out  STD_LOGIC);
end clockForClock;

architecture Behavioral of clockForClock is
	signal count : natural range 0 to 6 := 0;
begin
	process(clk, rst)
	begin
		if (rst = '0') then
			clkForClock <= '0';
			count <= 0 ;
		elsif rising_edge(clk) then
			case count is
				when 0 =>
					clkForClock <= '1';
				when 1 =>
					clkForClock <= '0';
				when 2 =>
					clkForClock <= '0';
				when 3 =>
					clkForClock <= '0';
				when 4 =>
					clkForClock <= '0';
				when others =>
					clkForClock <= '0';				
			end case;

			if (count = 4) then
				count <= 0;
			else 
				count <= count + 1;
			end if;
		end if;
	end process;

end Behavioral;

