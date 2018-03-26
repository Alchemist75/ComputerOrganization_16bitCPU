library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clock is
	port(
		rst		: in STD_LOGIC;
		clk 	: in STD_LOGIC;
		clk0	: out STD_LOGIC;
		clk1 	: out STD_LOGIC;
		clk2	: out STD_LOGIC;
		clk3 	: out STD_LOGIC
	);
end clock;

architecture Behavioral of clock is
	signal count : natural range 0 to 3 := 0;
begin
	process(clk, rst)
	begin
		clk0 <= clk ;
		if (rst = '0') then
			clk0 <= '0';
			clk1 <= '0';
			clk2 <= '0';
			clk3 <= '0';
			count <= 0 ;
		elsif rising_edge(clk) then
			case count is
				when 0 =>
					clk1 <= '1';
					clk2 <= '0';
					clk3 <= '0';
				when 1 =>
					clk1 <= '0';
					clk2 <= '1';
					clk3 <= '0';
				when others =>
					clk1 <= '0';
					clk2 <= '0';
					clk3 <= '0';					
			end case;

			if (count = 1) then
				count <= 0;
			else 
				count <= count + 1;
			end if;
		end if;
	end process;
end Behavioral;
