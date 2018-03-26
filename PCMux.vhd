----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:55:05 11/23/2017 
-- Design Name: 
-- Module Name:    PCMux - Behavioral 
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

entity PCMux is
    Port ( Jump 		: in  STD_LOGIC;
           branchJudge 	: in  STD_LOGIC;
           PCStall 		: in  STD_LOGIC;
           PC 			: in  STD_LOGIC_VECTOR(15 downto 0);
           NPC 		: in  STD_LOGIC_VECTOR(15 downto 0);
           PCAddImm 		: in  STD_LOGIC_VECTOR(15 downto 0);
           reg1 		: in  STD_LOGIC_VECTOR(15 downto 0);
           PCOut 		: out  STD_LOGIC_VECTOR(15 downto 0);
			  
			  FLASH_FINISH: in STD_LOGIC
	) ;
end PCMux;

architecture Behavioral of PCMux is
begin
	PCOut <= (others => '0') when FLASH_FINISH = '0' else
				PCAddImm when (PCStall = '0' and Jump = '0' and branchJudge = '1') else
				PC when PCStall = '1' else
				reg1 when (PCStall = '0' and Jump = '1') else 
				NPC ;
end Behavioral;

