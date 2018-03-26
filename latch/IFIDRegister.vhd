----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:17:33 11/19/2017 
-- Design Name: 
-- Module Name:    IF_ID - Behavioral 
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

entity IFIDRegister is
    Port ( 
		rst 		: in STD_LOGIC;
		clk 		: in STD_LOGIC;
		-- control signal
		IFIDStall	: in STD_LOGIC;
		IFIDFlush	: in STD_LOGIC;
		-- input
		IF_PC		: in STD_LOGIC_VECTOR(15 downto 0);
		IF_inst		: in STD_LOGIC_VECTOR(15 downto 0);
		IF_RPC		: in STD_LOGIC_VECTOR(15 downto 0);
		-- output
		ID_PC		: out STD_LOGIC_VECTOR(15 downto 0);
		ID_inst		: out STD_LOGIC_VECTOR(15 downto 0);
		ID_RPC		: out STD_LOGIC_VECTOR(15 downto 0)
	);
end IFIDRegister;

architecture Behavioral of IFIDRegister is
	signal state : clockState := c0 ;
begin
	process(clk, rst)
	begin
		if(rst = '0') then
			ID_PC <= (others => '0');
			ID_inst <= (others => '0');
			ID_RPC <= (others => '0');
			state <= c0 ;
		elsif(clk'event and clk='1') then
			case state is 
				when c0 =>
					if(IFIDStall = '1') then
						null;
					elsif(IFIDFlush = '1') then
						ID_PC <= (others => '0');
						ID_inst <= "0000100000000000";
						ID_RPC <= (others => '0');
					else
						ID_PC <= IF_PC;
						ID_inst <= IF_inst;
						ID_RPC <= IF_RPC;
					end if;
					state <= c1 ;
				when c1 =>
					state <= c2 ;
				when c2 =>
					state <= c3;
				when c3 =>
					state <= c0;
				when others =>
					state <= c0 ;
			end case;
		end if;
	end process;
end Behavioral;

