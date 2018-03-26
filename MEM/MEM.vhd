----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:27:37 11/20/2017 
-- Design Name: 
-- Module Name:    MEM - Behavioral 
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

entity DataMemory is
    Port ( CLK : in  STD_LOGIC;
			  RST : in	STD_LOGIC;
           MemWrite : in  STD_LOGIC;					--Ϊ0ʱ, ʹ��
           MemRead : in  STD_LOGIC;
           Addr : in  STD_LOGIC_VECTOR (15 downto 0);
           WData : in  STD_LOGIC_VECTOR (15 downto 0);
           RData : out  STD_LOGIC_VECTOR (15 downto 0);
			  RAM1_ADDR : out  STD_LOGIC_VECTOR (17 downto 0);
           RAM1_DATA : inout  STD_LOGIC_VECTOR (15 downto 0);
           RAM1_OE : out  STD_LOGIC;
           RAM1_WE : out  STD_LOGIC;
           RAM1_EN : out  STD_LOGIC);
end DataMemory;

architecture Behavioral of DataMemory is

component RAM1
	port(CLK : in  STD_LOGIC;
			  RST: in	STD_LOGIC;
           ADDR_IN : in  STD_LOGIC_VECTOR (17 downto 0);
           DATA_IN : in  STD_LOGIC_VECTOR (15 downto 0);
           op : in  STD_LOGIC_VECTOR (1 downto 0); 		--op(1): ʹ��(ʹ��:0, ��ʹ��:1); op(0): ����д (0,1)
           DATA_OUT : out  STD_LOGIC_VECTOR (15 downto 0);
           RAM1_ADDR : out  STD_LOGIC_VECTOR (17 downto 0);
           RAM1_DATA : inout  STD_LOGIC_VECTOR (15 downto 0);
           RAM1_OE : out  STD_LOGIC;
           RAM1_WE : out  STD_LOGIC;
           RAM1_EN : out  STD_LOGIC);
end component;

component LOGIC_RAM1_OP
    port ( MemWrite : in  STD_LOGIC;
           MemRead : in  STD_LOGIC;
           op : out  STD_LOGIC_VECTOR (1 downto 0));
end component;

component ZERO_EXTEND_18BIT
    port ( D_16BIT : in  STD_LOGIC_VECTOR (15 downto 0);
           Q_18BIT : out  STD_LOGIC_VECTOR (17 downto 0));
end component;

signal op : std_logic_vector (1 downto 0);
signal Addr_18bit : std_logic_vector (17 downto 0);

begin
	u0:LOGIC_RAM1_OP port map(MemWrite, MemRead, op);
	u1:ZERO_EXTEND_18BIT port map(Addr, Addr_18bit);
	u2:RAM1 port map(CLK, RST, Addr_18bit, WData, op, RData, RAM1_ADDR, RAM1_DATA, RAM1_OE, RAM1_WE, RAM1_EN);

end Behavioral;

