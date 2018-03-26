----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:45:50 11/20/2017 
-- Design Name: 
-- Module Name:    LOGIC_RAM1_OP - Behavioral 
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

entity LOGIC_RAM1_OP is
    Port ( MemWrite : in  STD_LOGIC;
           MemRead : in  STD_LOGIC;
           op : out  STD_LOGIC_VECTOR (1 downto 0));
end LOGIC_RAM1_OP;

architecture Behavioral of LOGIC_RAM1_OP is

begin
	op(1) <= MemWrite AND MemRead;				--ֻҪһ��ʹ��, op(1)Ϊ0
	op(0) <= (NOT MemWrite AND MemRead);		--MemWrite:0, MemRead:1ʱ��д�� (ʣ�µ�������Ƕ�ȡ, ����д������Ӱ�����)
end Behavioral;

