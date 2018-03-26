library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity top is
	port(
		clk 		: in STD_LOGIC;
		rst 		: in STD_LOGIC;
		ps_clk 	: in STD_LOGIC;
		ps_data 	: in STD_LOGIC;
		led0, led1 	: out STD_LOGIC_VECTOR(6 downto 0);
		led		: out STD_LOGIC_VECTOR(7 downto 0)
	);
end top;

architecture behave of top is
	component Keyboard is
		port (
			rst 		: in STD_LOGIC;
			clkin 		: in STD_LOGIC; -- PS2 clk and data
			datain 		: in STD_LOGIC;
			fclk 		: in STD_LOGIC; -- filter clock
			scancode 	: out std_logic_vector(7 downto 0) -- scan code signal output
		);
	end component ;

	component seg7 is
		port(
			code		: in std_logic_vector(3 downto 0);
			seg_out 	: out std_logic_vector(6 downto 0)
		);
	end component;

	component divEven is
		port(
			clk: in std_logic;
			div: out std_logic
		);
	end component;

	signal scancode : std_logic_vector(7 downto 0);
begin
	u0 : Keyboard 
	port map(
		rst 			=> rst,
		clkin 		=> ps_clk,
		datain 		=> ps_data,
		fclk 			=> clk,
		scancode 	=> scancode
	);

end behave;

