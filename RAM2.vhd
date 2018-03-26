----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:49:20 11/20/2017 
-- Design Name: 
-- Module Name:    RAM1 - Behavioral 
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

entity RAM2 is
    Port ( CLK : in  STD_LOGIC;
			  RST: in	STD_LOGIC;
           ADDR_IN : in  STD_LOGIC_VECTOR (17 downto 0);
           DATA_IN : in  STD_LOGIC_VECTOR (15 downto 0);
           op : in  STD_LOGIC_VECTOR (1 downto 0); 		--op(1): 使能(使能:0, 非使能:1); op(0): 读或写 (0,1)
           DATA_OUT : out  STD_LOGIC_VECTOR (15 downto 0);
           RAM2_ADDR : out  STD_LOGIC_VECTOR (17 downto 0);
           RAM2_DATA : inout  STD_LOGIC_VECTOR (15 downto 0);
           RAM2_OE : out  STD_LOGIC;
           RAM2_WE : out  STD_LOGIC;
           RAM2_EN : out  STD_LOGIC);
			  --rdn, wrn					--一定要关闭
end RAM2;

architecture Behavioral of RAM2 is

begin
	process(CLK, RST, op)
	begin
		if(RST = '0') then
			RAM2_EN <= '1';
			RAM2_OE <= '1';
			RAM2_WE <= '1';
			RAM2_ADDR <= "000000000000000000";
			RAM2_DATA <= "0000000000000000";
		end if;
		
		if(op(1) = '0') then
			RAM2_EN <= '0';
			case op(0) is
				when '0' =>		--读取
					RAM2_OE <= CLK;
					RAM2_WE <= '1';
					DATA_OUT <= RAM2_DATA;--是否上升沿时, 读取?? 或者一直连接DATA_OUT, 也没关系?
					RAM2_DATA <= "ZZZZZZZZZZZZZZZZ";	--OE为0之前, 操作?
				when '1' =>		--写入
					RAM2_WE <= CLK;
					RAM2_OE <= '1';
					RAM2_DATA <= DATA_IN;--是否下降沿时, 写入??--这个应该没问题
				when others =>
					RAM2_OE <= '1';
					RAM2_WE <= '1';
			end case;
			RAM2_ADDR <= ADDR_IN;
		else 
			RAM2_EN <= '1';
			RAM2_OE <= '1';
			RAM2_WE <= '1';
			RAM2_ADDR <= "000000000000000000";
			RAM2_DATA <= "0000000000000000";
		end if;
	end process;

end Behavioral;

