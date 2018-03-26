----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:36:27 11/23/2017 
-- Design Name: 
-- Module Name:    ALUResMux - Behavioral 
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

entity ALUResMux is
    Port ( ALURes       	: in  STD_LOGIC_VECTOR(1 DOWNTO 0);
           ALUResult       : in  STD_LOGIC_VECTOR(15 DOWNTO 0);
           PC           	: in  STD_LOGIC_VECTOR(15 DOWNTO 0);
           RPC          	: in  STD_LOGIC_VECTOR(15 DOWNTO 0);
           ALUMuxResult    : out  STD_LOGIC_VECTOR(15 DOWNTO 0) );
end ALUResMux;

architecture Behavioral of ALUResMux is

begin
    ALUMuxResult <= RPC when ALURes = "10" else
                    PC when ALURes = "01" else
                    ALUResult ;

end Behavioral;

