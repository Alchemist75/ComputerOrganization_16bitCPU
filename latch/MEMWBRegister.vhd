----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:44:12 11/19/2017 
-- Design Name: 
-- Module Name:    MEM_WB - Behavioral 
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
use CpuConstant.all ;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MEMWBRegister is
    Port ( 
		clk 			: in STD_LOGIC;
		rst 			: in STD_LOGIC;
		-- input control signal
		MEM_MemRead	: in STD_LOGIC;
		MEM_MemWrite: in STD_LOGIC;
		MEM_MemToRead	: in STD_LOGIC;
		MEM_RegWrite	: in STD_LOGIC;
		-- input
		MEM_rdata 		: in STD_LOGIC_VECTOR(15 downto 0);
		MEM_ALUResult	: in STD_LOGIC_VECTOR(15 downto 0);
		MEM_RegDst		: in STD_LOGIC_VECTOR(3 downto 0);
		-- output control signal
		WB_LWSW			: out STD_LOGIC;
		WB_MemToRead	: out STD_LOGIC;
		WB_RegWrite 	: out STD_LOGIC;
		-- output
		WB_rdata 		: out STD_LOGIC_VECTOR(15 downto 0);
		WB_RegDst		: out STD_LOGIC_VECTOR(3 downto 0);
		WB_ALUResult	: out STD_LOGIC_VECTOR(15 downto 0)
	);
end MEMWBRegister;

architecture Behavioral of MEMWBRegister is
	signal state : clockstate := c0 ;
begin
	process(clk, rst)
	begin
		if(rst = '0') then
			WB_MemToRead <= '0';
			WB_RegWrite <= '0';
			WB_rdata <= (others => '0');
			WB_RegDst <= (others => '1');
			WB_ALUResult <= (others => '0');
			WB_LWSW <= '0';
			state <= c0 ;
		elsif(clk'event and clk='1') then
			case state is
				when c0 =>
					WB_MemToRead <= MEM_MemToRead;
					WB_RegWrite <= MEM_RegWrite;
					WB_rdata <= MEM_rdata;
					WB_RegDst <= MEM_RegDst;
					WB_ALUResult <= MEM_ALUResult;
					WB_LWSW <= MEM_MemRead or MEM_MemWrite ;
					state <= c1 ;
				when c1 => 
					state <= c2 ;
				when c2 =>
					state <= c3;
				when c3 =>
					state <= c0;
				when others => state <= c0 ;
			end case ;
		end if;
	end process;
end Behavioral;

