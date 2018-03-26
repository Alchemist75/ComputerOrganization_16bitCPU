----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:04:20 11/09/2017 
-- Design Name: 
-- Module Name:    SerialPort - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SerialPort is
	Port( 
		clk			: in STD_LOGIC;
		rst			: in STD_LOGIC;
		data_in		: in STD_LOGIC_VECTOR(7 downto 0);
		tsre			: in STD_LOGIC;
		tbre			: in STD_LOGIC;
		data_ready	: in STD_LOGIC;

		-- RAM1 Data Bus
		data 			: inout STD_LOGIC_VECTOR(7 downto 0); 
		rdn			: out STD_LOGIC;
		wrn			: out STD_LOGIC;
		RAM1_EN		: out STD_LOGIC;
		RAM1_OE 		: out STD_LOGIC;
		RAM1_RW 		: out STD_LOGIC;
		data_out		: out STD_LOGIC_VECTOR(7 downto 0) -- led
	);
end SerialPort;

architecture bhv of SerialPort is
	type states is (r0, r1, r2, r3, t0, t1, t2, t3, t4, t5);
	signal state 	: states := t0;

begin
	process(clk, rst)
		variable saved_data : STD_LOGIC_VECTOR(7 downto 0) ;
	begin
		if rst = '0' then
			state <= r0;
			RAM1_EN <= '1';
			RAM1_OE <= '1';
			RAM1_RW <= '1';
		elsif rising_edge(clk) then
			case state is
				when r0 =>
					RAM1_EN <= '1';
					RAM1_OE <= '1';
					RAM1_RW <= '1';
					state <= r1;
				when r1 =>
					rdn <= '1';
					data <= "ZZZZZZZZ";
					state <= r2;
				when r2 =>
					if (data_ready = '1') then 
						rdn <= '0';
						state <= r3;
					elsif (data_ready = '0') then
						state <= r1;
					end if;
				when r3 =>
					data_out <= data;
					saved_data := data;
					rdn <= '1';
					state <= t0;
				when t0 =>
					wrn <= '1';
					RAM1_EN <= '1';
					RAM1_OE <= '1';
					RAM1_RW <= '1';
					state <= t1;
				when t1 =>
					data <= saved_data + '1';
					wrn <= '0';
					state <= t2;
				when t2 =>
					wrn <= '1';
					state <= t3;
				when t3 =>
					if (tbre = '1') then 
						state <= t4;
					end if;
				when t4 =>
					if (tsre = '1') then 
						state <= t5;
					end if;
				when others =>
					state <= r0;
			end case;
		end if;
	end process;
end bhv;


