----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:02:42 11/25/2017 
-- Design Name: 
-- Module Name:    PCAdder - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PCAdder is
    Port ( PC : in  STD_LOGIC_VECTOR(15 DOWNTO 0);
           NPC : out  STD_LOGIC_VECTOR(15 DOWNTO 0));
end PCAdder;

architecture Behavioral of PCAdder is

begin
		NPC <= PC + 1 ;

end Behavioral;

