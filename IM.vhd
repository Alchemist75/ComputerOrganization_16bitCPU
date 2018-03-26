----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:12:39 11/20/2017 
-- Design Name: 
-- Module Name:    IF - Behavioral 
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

entity InstructionMemory is
    Port ( 
		clk 		: in STD_LOGIC;
		rst 		: in STD_LOGIC;
		-- RAM2
		Ram2_OE		: out STD_LOGIC;
		Ram2_WE 		: out STD_LOGIC;
		Ram2_EN 		: out STD_LOGIC;
		Ram2_Addr 	: out STD_LOGIC_VECTOR(17 downto 0);
		Ram2_Data	: inout STD_LOGIC_VECTOR(15 downto 0);
		-- input
		PC 			: in STD_LOGIC_VECTOR(15 downto 0);
		-- output
		inst 			: out STD_LOGIC_VECTOR(15 downto 0));
end InstructionMemory;


architecture Behavioral of InstructionMemory is

component RAM2
    port ( CLK : in  STD_LOGIC;
           ADDR_IN : in  STD_LOGIC_VECTOR (17 downto 0);
           DATA_IN : in  STD_LOGIC_VECTOR (15 downto 0);
           op : in  STD_LOGIC_VECTOR (1 downto 0); 		--op(1): ʹ��(ʹ��:0, ��ʹ��:1); op(0): ����д (0,1)
           DATA_OUT : out  STD_LOGIC_VECTOR (15 downto 0);
           RAM2_ADDR : out  STD_LOGIC_VECTOR (17 downto 0);
           RAM2_DATA : inout  STD_LOGIC_VECTOR (15 downto 0);
           RAM2_OE : out  STD_LOGIC;
           RAM2_WE : out  STD_LOGIC;
           RAM2_EN : out  STD_LOGIC);
			  --rdn, wrn					--һ��Ҫ�ر�
end component;

component ZERO_EXTEND_18BIT
    port ( D_16BIT : in  STD_LOGIC_VECTOR (15 downto 0);
           Q_18BIT : out  STD_LOGIC_VECTOR (17 downto 0));
end component;

--signal op : std_logic_vector (1 downto 0);
signal PC_18bit : std_logic_vector (17 downto 0);

begin
	u0:ZERO_EXTEND_18BIT port map(PC, PC_18bit);
	u1:RAM2 port map(CLK, PC_18bit, "0000000000000000", "00", inst, RAM2_ADDR, RAM2_DATA, RAM2_OE, RAM2_WE, RAM2_EN);
	--												д���ź�Ϊ0...,    ���Ƕ�ȡ
end Behavioral;

