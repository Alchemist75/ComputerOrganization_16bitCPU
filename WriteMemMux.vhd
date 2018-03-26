library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity WriteMemMux is
    Port ( ForwardWriteMem		: in  STD_LOGIC_VECTOR(1  downto 0);
           reg2         		: in  STD_LOGIC_VECTOR(15 downto 0);
           MEM_ALUResult   		: in  STD_LOGIC_VECTOR(15 downto 0);
           WB_ALUResult    		: in  STD_LOGIC_VECTOR(15 downto 0);
           MemWriteData    		: out STD_LOGIC_VECTOR(15 downto 0));
end WriteMemMux;

architecture Behavioral of WriteMemMux is

begin
    MemWriteData <= WB_ALUResult when ForwardWriteMem = "10" else
                MEM_ALUResult when ForwardWriteMem = "01" else
                reg2 ;
end Behavioral;
