----------------------------------------------------------------------------------
--��Ҫ���WB, MEM, EXE�Ŀ����ź�
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:26:32 11/19/2017 
-- Design Name: 
-- Module Name:    ID_EXE - Behavioral 
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
entity IDEXRegister is
	port(
		clk 		: in STD_LOGIC;
		rst 		: in STD_LOGIC;
		-- control signal 
		IDEXFlush	: in STD_LOGIC;
		-- input control signal
		ID_RegDst	: in STD_LOGIC_VECTOR(3 downto 0);
		ID_ALUOp	: in STD_LOGIC_VECTOR(3 downto 0);
		ID_ALUSrcB	: in STD_LOGIC;
		ID_ALURes  	: in STD_LOGIC_VECTOR(1 downto 0);
		ID_Jump		: in STD_LOGIC;
		ID_BranchOp	: in STD_LOGIC_VECTOR(1 downto 0);
		ID_Branch 	: in STD_LOGIC;
		ID_MemRead	: in STD_LOGIC;
		ID_MemWrite	: in STD_LOGIC;
		ID_MemToRead: in STD_LOGIC;
		ID_RegWrite : in STD_LOGIC;
		-- input
		ID_PC 		: in STD_LOGIC_VECTOR(15 downto 0);
		ID_reg1		: in STD_LOGIC_VECTOR(15 downto 0);
		ID_reg2		: in STD_LOGIC_VECTOR(15 downto 0);
		ID_raddr1	: in STD_LOGIC_VECTOR(3 downto 0);
		ID_raddr2	: in STD_LOGIC_VECTOR(3 downto 0);
		ID_imm		: in STD_LOGIC_VECTOR(15 downto 0);
		ID_RPC 		: in STD_LOGIC_VECTOR(15 downto 0);
		-- output control signal
		EX_RegDst	: out STD_LOGIC_VECTOR(3 downto 0);
		EX_ALUOp	: out STD_LOGIC_VECTOR(3 downto 0);
		EX_ALUSrcB	: out STD_LOGIC;
		EX_ALURes  	: out STD_LOGIC_VECTOR(1 downto 0);
		EX_Jump		: out STD_LOGIC;
		EX_BranchOp	: out STD_LOGIC_VECTOR(1 downto 0);
		EX_Branch 	: out STD_LOGIC;
		EX_MemRead	: out STD_LOGIC;
		EX_MemWrite	: out STD_LOGIC;
		EX_MemToRead: out STD_LOGIC;
		EX_RegWrite : out STD_LOGIC;
		-- output
		EX_PC 		: out STD_LOGIC_VECTOR(15 downto 0);
		EX_reg1		: out STD_LOGIC_VECTOR(15 downto 0);
		EX_reg2		: out STD_LOGIC_VECTOR(15 downto 0);
		EX_raddr1	: out STD_LOGIC_VECTOR(3 downto 0);
		EX_raddr2	: out STD_LOGIC_VECTOR(3 downto 0);
		EX_imm		: out STD_LOGIC_VECTOR(15 downto 0);
		EX_RPC 		: out STD_LOGIC_VECTOR(15 downto 0)
	);
end IDEXRegister;


architecture Behavioral of IDEXRegister is
	signal state : clockState := c0 ;
begin
	process(clk, rst)
	begin
		if(rst = '0') then
			EX_RegDst <= (others => '1');
			EX_ALUOp <= (others => '0');
			EX_ALUSrcB <= '0' ;
			EX_ALURes <= (others => '0');
			EX_Jump <=  '0' ;
			EX_BranchOp <= (others => '0') ;
			EX_Branch <=  '0' ;
			EX_MemRead <=  '0' ;
			EX_MemWrite <=  '0' ;
			EX_MemToRead <=  '0' ;
			EX_RegWrite <=  '0' ;
			EX_PC <= (others => '0');
			EX_reg1 <= (others => '0');
			EX_reg2 <= (others => '0');
			EX_raddr1 <= (others => '1');
			EX_raddr2 <= (others => '1');
			EX_imm <= (others => '0');
			EX_RPC <= (others => '0');
			state <= c0 ;
		elsif(clk'event and clk='1') then
			case state is
				when c0=>
					if(IDEXFlush = '1') then
						EX_RegDst <= (others => '1');
						EX_ALUOp <= (others => '0');
						EX_ALUSrcB <= '0' ;
						EX_ALURes <= (others => '0');
						EX_Jump <=  '0' ;
						EX_BranchOp <= (others => '0') ;
						EX_Branch <=  '0' ;
						EX_MemRead <=  '0' ;
						EX_MemWrite <=  '0' ;
						EX_MemToRead <=  '0' ;
						EX_RegWrite <=  '0' ;
						EX_PC <= (others => '0');
						EX_reg1 <= (others => '0');
						EX_reg2 <= (others => '0');
						EX_raddr1 <= (others => '1');
						EX_raddr2 <= (others => '1');
						EX_imm <= (others => '0');
						EX_RPC <= (others => '0');
					else
						EX_RegDst <= ID_RegDst;
						EX_ALUOp <= ID_ALUOp;
						EX_ALUSrcB <= ID_ALUSrcB;
						EX_ALURes <= ID_ALURes;
						EX_Jump <= ID_Jump;
						EX_BranchOp <= ID_BranchOp;
						EX_Branch <= ID_Branch;
						EX_MemRead <= ID_MemRead;
						EX_MemWrite <= ID_MemWrite;
						EX_MemToRead <= ID_MemToRead;
						EX_RegWrite <= ID_RegWrite;
						EX_PC <= ID_PC;
						EX_reg1 <= ID_reg1;
						EX_reg2 <= ID_reg2;
						EX_raddr1 <= ID_raddr1;
						EX_raddr2 <= ID_raddr2;
						EX_imm <= ID_imm;
						EX_RPC <= ID_RPC;
					end if;
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

