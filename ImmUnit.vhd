----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:49:45 11/23/2017 
-- Design Name: 
-- Module Name:    ImmUnit - Behavioral 
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

entity ImmUnit is
    Port ( ImmSrc : in  STD_LOGIC_VECTOR(2 DOWNTO 0);
           ExtendOp : in  STD_LOGIC;
           inst : in  STD_LOGIC_VECTOR(15 DOWNTO 0);
           immOut : out  STD_LOGIC_VECTOR(15 DOWNTO 0));
end ImmUnit;

architecture Behavioral of ImmUnit is
    shared variable sign :  STD_LOGIC ;
    shared variable tmp_imm :  STD_LOGIC_VECTOR(15 DOWNTO 0) ;
begin
	process(ImmSrc,ExtendOp,inst)
	begin
        case ImmSrc is
            when "000" => sign := inst(10);
            when "001" => sign := inst(7) ;
            when "010" => sign := inst(4) ;
            when "011" => sign := inst(4) ;
            when "100" => sign := inst(3) ;
            when others => sign := '0' ;
        end case ;
        if (ExtendOp = '1') then 
            sign := '0' ;
        end if ;
        tmp_imm := ( others => sign ) ;
        case ImmSrc is
            when "000" => immout <= tmp_imm(15 downto 11) & inst(10 downto 0) ;
            when "001" => immout <= tmp_imm(15 downto  8) & inst( 7 downto 0) ;
            when "010" => immout <= tmp_imm(15 downto  5) & inst( 4 downto 0) ;
            when "011" => immout <= tmp_imm(15 downto  3) & inst( 4 downto 2) ;
            when "100" => immout <= tmp_imm(15 downto  4) & inst( 3 downto 0) ;
				when others =>
        end case ;
	end process ;
		

end Behavioral;

 