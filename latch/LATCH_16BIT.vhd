----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:37:14 11/19/2017 
-- Design Name: 
-- Module Name:    LATCH_16BIT - Behavioral 
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

entity LATCH_16BIT is
    Port ( CLK : in  STD_LOGIC;
		   RST: in STD_LOGIC;
           D : in  STD_LOGIC_VECTOR (15 downto 0);
           Q : out  STD_LOGIC_VECTOR (15 downto 0));
end LATCH_16BIT;


architecture Behavioral of LATCH_16BIT is

component LATCH_1BIT
	port(CLK: in STD_LOGIC;
			RST: in STD_LOGIC;
			D: in STD_LOGIC;
			Q: out STD_LOGIC);
end component;

begin
	u0: for i in 0 to 15 generate
		ux:LATCH_1BIT port map(CLK, RST, D(i), Q(i));
	end generate;
end Behavioral;

