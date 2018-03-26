----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:38:33 11/19/2017 
-- Design Name: 
-- Module Name:    EXE_MEM - Behavioral 
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
use CpuConstant.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity EXMEMRegister is
	port(
		clk			: in STD_LOGIC;
		rst			: in STD_LOGIC;
		-- input control signal
		EX_RegDst 	: in STD_LOGIC_VECTOR(3 downto 0);
		EX_MemRead	: in STD_LOGIC;
		EX_MemWrite	: in STD_LOGIC;
		EX_MemToRead: in STD_LOGIC;
		EX_RegWrite	: in STD_LOGIC;
		-- input
		EX_ALUResult	: in STD_LOGIC_VECTOR(15 downto 0);
		EX_reg2		: in STD_LOGIC_VECTOR(15 downto 0);
		-- output control signal
		MEM_RegDst 	: out STD_LOGIC_VECTOR(3 downto 0);
		MEM_MemRead	:	out STD_LOGIC;
		MEM_MemWrite:	out STD_LOGIC;
		MEM_MemToRead:	out STD_LOGIC;
		MEM_RegWrite:	out STD_LOGIC;
		-- output
		MEM_ALUResult	: out STD_LOGIC_VECTOR(15 downto 0);
		MEM_reg2	: out STD_LOGIC_VECTOR(15 downto 0)
	);
end EXMEMRegister;


architecture Behavioral of EXMEMRegister is
	signal state : clockState := c0 ;
begin
	process(clk, rst)
	begin
		if(rst = '0') then
			MEM_RegDst <= (others => '1');
			MEM_MemRead <= '0';
			MEM_MemWrite <= '0';
			MEM_MemToRead <= '0';
			MEM_RegWrite <= '0';
			MEM_ALUResult <= (others => '0');
			MEM_reg2 <= (others => '0');
			state <= c0 ;
		elsif(clk'event and clk='1') then
			case state is
				when c0 => 
					state <= c1 ;
					MEM_RegDst <= EX_RegDst;
					MEM_MemRead <= EX_MemRead;
					MEM_MemWrite <= EX_MemWrite;
					MEM_MemToRead <= EX_MemToRead;
					MEM_RegWrite <= EX_RegWrite;
					MEM_ALUResult <= EX_ALUResult;
					MEM_reg2 <= EX_reg2;
				when c1 => state <= c2 ;
				when c2 =>
					state <= c3;
				when c3 =>
					state <= c0;
				when others => state <= c0 ;
			end case ;
		end if;
	end process;
end Behavioral;