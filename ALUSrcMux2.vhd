----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:30:15 11/23/2017 
-- Design Name: 
-- Module Name:    ALUSrcMux2 - Behavioral 
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

entity ALUSrcMux2 is
    Port ( ForwardB     : in  STD_LOGIC_VECTOR(1  downto 0);
           ALUSrcB      : in  STD_LOGIC ;
           reg2         : in  STD_LOGIC_VECTOR(15 downto 0);
           MEM_ALUResult   : in  STD_LOGIC_VECTOR(15 downto 0);
           WB_ALUResult    : in  STD_LOGIC_VECTOR(15 downto 0);
           imm          : in  STD_LOGIC_VECTOR(15 downto 0);
           src2         : out STD_LOGIC_VECTOR(15 downto 0));
end ALUSrcMux2;

architecture Behavioral of ALUSrcMux2 is
begin
    src2 <= WB_ALUResult when ForwardB = "10" else
            MEM_ALUResult when ForwardB = "01" else
            imm when (ForwardB = "00" and ALUSrcB = '1') else
            reg2 ;
end Behavioral;
