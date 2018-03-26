library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package KeyboardConstant is

	constant kb_A: std_logic_vector(7 downto 0) := "00011100";    
	constant kb_B: std_logic_vector(7 downto 0) := "00110010";
	constant kb_C: std_logic_vector(7 downto 0) := "00100001";
	constant kb_D: std_logic_vector(7 downto 0) := "00100011";
	constant kb_E: std_logic_vector(7 downto 0) := "00100100";
	constant kb_F: std_logic_vector(7 downto 0) := "00101011";
	constant kb_G: std_logic_vector(7 downto 0) := "00110100";
	constant kb_H: std_logic_vector(7 downto 0) := "00110011";
	constant kb_I: std_logic_vector(7 downto 0) := "01000011";
	constant kb_J: std_logic_vector(7 downto 0) := "00111011";
	constant kb_K: std_logic_vector(7 downto 0) := "01000010";
	constant kb_L: std_logic_vector(7 downto 0) := "01001011";
	constant kb_M: std_logic_vector(7 downto 0) := "00111010";
	constant kb_N: std_logic_vector(7 downto 0) := "00110001";
	constant kb_O: std_logic_vector(7 downto 0) := "01000100";
	constant kb_P: std_logic_vector(7 downto 0) := "01001101";
	constant kb_Q: std_logic_vector(7 downto 0) := "00010101";
	constant kb_R: std_logic_vector(7 downto 0) := "00101101";
	constant kb_S: std_logic_vector(7 downto 0) := "00011011";
	constant kb_T: std_logic_vector(7 downto 0) := "00101100";
	constant kb_U: std_logic_vector(7 downto 0) := "00111100";
	constant kb_V: std_logic_vector(7 downto 0) := "00101010";
	constant kb_W: std_logic_vector(7 downto 0) := "00011101";
	constant kb_X: std_logic_vector(7 downto 0) := "00100010";
	constant kb_Y: std_logic_vector(7 downto 0) := "00110101";
	constant kb_Z: std_logic_vector(7 downto 0) := "00011010";
	constant kb_0: std_logic_vector(7 downto 0) := "01000101";
	constant kb_1: std_logic_vector(7 downto 0) := "00010110";
	constant kb_2: std_logic_vector(7 downto 0) := "00011110";
	constant kb_3: std_logic_vector(7 downto 0) := "00100110";
	constant kb_4: std_logic_vector(7 downto 0) := "00100101";
	constant kb_5: std_logic_vector(7 downto 0) := "00101110";
	constant kb_6: std_logic_vector(7 downto 0) := "00110110";
	constant kb_7: std_logic_vector(7 downto 0) := "00111101";
	constant kb_8: std_logic_vector(7 downto 0) := "00111110";
	constant kb_9: std_logic_vector(7 downto 0) := "01000110";
	constant kb_space: std_logic_vector(7 downto 0) := "00101001";
	constant kb_comma: std_logic_vector(7 downto 0) := "01000001";
	constant kb_dot: std_logic_vector(7 downto 0) := "01001001";
	constant kb_exclaim: std_logic_vector(7 downto 0) := "01001010";
	constant kb_smile: std_logic_vector(7 downto 0) := "01010010";
	constant kb_NULL: std_logic_vector(7 downto 0) := "00000000";
	constant kb_EXIT: std_logic_vector(7 downto 0) := "01011010"; --ENTER

	constant kb_bksp : std_logic_vector(7 downto 0) := "01100110";
end KeyboardConstant;

package body KeyboardConstant is

end KeyboardConstant;
	