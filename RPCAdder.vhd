----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:05:58 11/25/2017 
-- Design Name: 
-- Module Name:    RPCAdder - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RPCAdder is
    Port ( PC : in  STD_LOGIC_VECTOR(15 DOWNTO 0);
           RPC : out  STD_LOGIC_VECTOR(15 DOWNTO 0));
end RPCAdder;

architecture Behavioral of RPCAdder is

begin
		RPC <= PC + 1;


end Behavioral;

