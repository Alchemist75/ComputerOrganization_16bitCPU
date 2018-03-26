----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:59:32 11/20/2017 
-- Design Name: 
-- Module Name:    ZERO_EXTEND_18BIT - Behavioral 
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

entity ZERO_EXTEND_18BIT is
    Port ( D_16BIT : in  STD_LOGIC_VECTOR (15 downto 0);
           Q_18BIT : out  STD_LOGIC_VECTOR (17 downto 0));
end ZERO_EXTEND_18BIT;

architecture Behavioral of ZERO_EXTEND_18BIT is

begin
	Q_18BIT <= "00" & D_16BIT;
end Behavioral;

