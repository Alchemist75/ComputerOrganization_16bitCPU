----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:01:06 11/26/2017 
-- Design Name: 
-- Module Name:    PCRegister - Behavioral 
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
use CpuConstant.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PCRegister is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           PCIn : in  STD_LOGIC_VECTOR(15 DOWNTO 0);
           PCOut : out  STD_LOGIC_VECTOR(15 DOWNTO 0));
end PCRegister;

architecture Behavioral of PCRegister is
	signal state : clockState := c0 ;
begin
	
process (clk, rst)
begin
	if(rst = '0') then
		PCOut <= (others => '0') ;
		state <= c0 ;
	elsif (clk'event and clk='1') then
		case state is 
			when c0 =>
				PCOut <= PCIn ;
				state <= c1 ;
			when c1 =>
				state <= c2 ;
			when c2 =>
				state <= c3;
			when c3 =>
				state <= c0;
			when others =>
				state <= c0 ;
		end case;
	end if ;
end process ;

end Behavioral;

