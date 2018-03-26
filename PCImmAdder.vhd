----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:08:09 11/25/2017 
-- Design Name: 
-- Module Name:    PCImmAdder - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL ;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PCImmAdder is
    Port ( PCIn : in  STD_LOGIC_VECTOR(15 DOWNTO 0);
           imm : in  STD_LOGIC_VECTOR(15 DOWNTO 0);
           PCOut : out  STD_LOGIC_VECTOR(15 DOWNTO 0));
end PCImmAdder;

architecture Behavioral of PCImmAdder is

begin
		PCOut <= PCIn + CONV_INTEGER(imm) ;
end Behavioral;

