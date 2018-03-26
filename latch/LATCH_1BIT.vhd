----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:32:23 11/19/2017 
-- Design Name: 
-- Module Name:    LATCH_1BIT - Behavioral 
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

entity LATCH_1BIT is
    Port ( CLK : in  STD_LOGIC;
		   RST: in STD_LOGIC;
           D : in  STD_LOGIC;
           Q : out  STD_LOGIC);
end LATCH_1BIT;

architecture Behavioral of LATCH_1BIT is

begin
	process(RST, CLK, D)
	begin
		if RST = '0'
			then Q <= '0';
		elsif CLK'EVENT and CLK = '1'
			then Q <= D;
		end if;
	end process;
end Behavioral;

