library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MemController is
	port(
		MemWrite		: in std_logic;
		MemRead		: in std_logic;

		isMem			: out std_logic
	);
end MemController;

architecture Behavioral of MemController is

begin
	isMem <= (MemRead or MemWrite) ;
end Behavioral;