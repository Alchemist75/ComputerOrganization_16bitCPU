library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package CpuConstant is

	-- command(15 downto 11)

	constant PRE5_ADDIU: std_logic_vector(4 downto 0) := 		"01001";
	constant PRE5_ADDIU3: std_logic_vector(4 downto 0) := 		"01000";

	constant PRE5_B: std_logic_vector(4 downto 0) := 			"00010";
	constant PRE5_BEQZ: std_logic_vector(4 downto 0) := 		"00100";
	constant PRE5_BNEZ: std_logic_vector(4 downto 0) := 		"00101";

	constant PRE5_LI: std_logic_vector(4 downto 0) := 			"01101";
	constant PRE5_LW: std_logic_vector(4 downto 0) := 			"10011";
	constant PRE5_LW_SP: std_logic_vector(4 downto 0) := 		"10010";
	constant PRE5_MFIH: std_logic_vector(4 downto 0) := 		"11110";

	constant PRE5_NOP: std_logic_vector(4 downto 0) := 			"00001";

	constant PRE5_SW: std_logic_vector(4 downto 0) := 			"11011";
	constant PRE5_SW_SP: std_logic_vector(4 downto 0) := 		"11010";

	constant PRE5_MOVE: std_logic_vector(4 downto 0) := 		"01111";

	------------------
	constant PRE5_ADDU_SUBU: std_logic_vector(4 downto 0) := 	"11100";
	constant PRE5_SLL_SRA: std_logic_vector(4 downto 0) := 		"00110";
	------------------

	----- PRE5 is 11101
	constant SUF5_AND: std_logic_vector(4 downto 0) :=			"01100";
	constant SUF5_CMP: std_logic_vector(4 downto 0) :=			"01010";
	constant SUF5_OR: std_logic_vector(4 downto 0) :=			"01101";
	constant SUF5_SLTU: std_logic_vector(4 downto 0) :=			"00011";

	constant SUF8_JR: std_logic_vector(7 downto 0) :=			"00000000";
	constant SUF8_MFPC: std_logic_vector(7 downto 0) :=			"01000000";
	constant SUF8_JALR: std_logic_vector(7 downto 0) :=			"11000000";
	------------------


	constant PRE8_SW_RS: std_logic_vector(7 downto 0) := 		"01100010";
	constant PRE8_ADDSP: std_logic_vector(7 downto 0) := 		"01100011";
	constant PRE8_BTEQZ: std_logic_vector(7 downto 0) := 		"01100000";
	constant PRE8_MTSP: std_logic_vector(7 downto 0) := 		"01100100";

	constant JRRA: std_logic_vector(15 downto 0) := 			"1110100000100000";

	-- RegSrcA, RegSrcB
	-- 通用寄存器的值为 0000 - 0111

	constant R0_ADDR: std_logic_vector(3 downto 0) := 	"0000";
	constant R1_ADDR: std_logic_vector(3 downto 0) := 	"0001";
	constant R2_ADDR: std_logic_vector(3 downto 0) := 	"0010";
	constant R3_ADDR: std_logic_vector(3 downto 0) := 	"0011";
	constant R4_ADDR: std_logic_vector(3 downto 0) := 	"0100";
	constant R5_ADDR: std_logic_vector(3 downto 0) := 	"0101";
	constant R6_ADDR: std_logic_vector(3 downto 0) := 	"0110";
	constant R7_ADDR: std_logic_vector(3 downto 0) := 	"0111";
	constant REG_SP: std_logic_vector(3 downto 0) := 	"1000";
	constant REG_T: std_logic_vector(3 downto 0) := 	"1001";
	constant REG_IH: std_logic_vector(3 downto 0) := 	"1010";
	constant REG_RA: std_logic_vector(3 downto 0) := 	"1011";
	constant REG_NO: std_logic_vector(3 downto 0) :=	"1111";

	type clockState is (c0,c1,c2,c3,c4,c5) ;

end CpuConstant;

package body CpuConstant is

end CpuConstant;