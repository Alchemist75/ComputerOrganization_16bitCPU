----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:09:30 11/23/2017 
-- Design Name: 
-- Module Name:    WriteDataMux - Behavioral 
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

entity WriteDataMux is
    Port ( MemToReg : in  STD_LOGIC ;
           rdata    : in  STD_LOGIC_VECTOR(15 DOWNTO 0);
           ALUResult   : in  STD_LOGIC_VECTOR(15 DOWNTO 0);
           wdata    : out  STD_LOGIC_VECTOR(15 DOWNTO 0));
end WriteDataMux;

architecture Behavioral of WriteDataMux is

begin
	wdata <= ALUResult when MemToReg = '0' else rdata ;
end Behavioral;

