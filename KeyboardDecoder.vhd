----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:40:01 12/05/2017 
-- Design Name: 
-- Module Name:    KeyboardDecoder - Behavioral 
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
use KeyboardConstant.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity KeyboardDecoder is
    Port ( scancode : in  STD_LOGIC_VECTOR(7 DOWNTO 0);
			  clk, rst : in STD_LOGIC ;
           outputcode : out  STD_LOGIC_VECTOR(7 DOWNTO 0));
end KeyboardDecoder;

architecture Behavioral of KeyboardDecoder is
	shared variable readtype : std_logic ;
begin
	process(clk,rst)
	begin
	if(rst='0') then
		outputcode <= "00000000" ;
		readtype := '0' ;
	elsif (clk'event and clk='1') then
		case readtype is
			when '0' =>
				outputcode <= "00000000" ;
				if (scancode = "11110000" or scancode = "11100000") then
					readtype := '1' ;
				end if ;
			when '1' =>
				readtype := '0' ;
				case (scancode) is
					when kb_A=> outputcode <= "01000001" ;
					when kb_B=> outputcode <= "01000010" ;
					when kb_C=> outputcode <= "01000011" ;
					when kb_D=> outputcode <= "01000100" ;
					when kb_E=> outputcode <= "01000101" ;
					when kb_F=> outputcode <= "01000110" ;
					when kb_G=> outputcode <= "01000111" ;
					when kb_H=> outputcode <= "01001000" ;
					when kb_I=> outputcode <= "01001001" ;
					when kb_J=> outputcode <= "01001010";
					when kb_K=> outputcode <= "01001011";
					when kb_L=> outputcode <= "01001100";
					when kb_M=> outputcode <= "01001101";
					when kb_N=> outputcode <= "01001110";
					when kb_O=> outputcode <= "01001111";
					when kb_P=> outputcode <= "01010000";
					when kb_Q=> outputcode <= "01010001";
					when kb_R=> outputcode <= "01010010";
					when kb_S=> outputcode <= "01010011";
					when kb_T=> outputcode <= "01010100";
					when kb_U=> outputcode <= "01010101";
					when kb_V=> outputcode <= "01010110";
					when kb_W=> outputcode <= "01010111";
					when kb_X=> outputcode <= "01011000";
					when kb_Y=> outputcode <= "01011001";
					when kb_Z=> outputcode <= "01011010";
					when kb_0=> outputcode <= "00110000";	
					when kb_1=> outputcode <= "00110001";	
					when kb_2=> outputcode <= "00110010";	
					when kb_3=> outputcode <= "00110011";	
					when kb_4=> outputcode <= "00110100";	
					when kb_5=> outputcode <= "00110101";	
					when kb_6=> outputcode <= "00110110";	
					when kb_7=> outputcode <= "00110111";	
					when kb_8=> outputcode <= "00111000";	
					when kb_9=> outputcode <= "00111001";
					when kb_space=> outputcode <= "11111110";
					when kb_dot=> outputcode <= "00101110" ;
					when kb_comma=> outputcode <= "00101100";
					when kb_exclaim=> outputcode <= "00100001";
					when kb_smile=> outputcode <= "00000001";
					when kb_exit=> outputcode <= "11111111" ;
					when kb_bksp => outputcode <= "11111110";
					when others => outputcode <= "00000000" ;
										readtype := '1' ;
				end case;
			when others =>
			end case ;
	end if;
	end process ;
end Behavioral;

