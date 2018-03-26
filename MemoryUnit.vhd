----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:45:15 11/26/2017 
-- Design Name: 
-- Module Name:    MemoryUnit - Behavioral 
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

entity MemoryUnit is
	port(
			clk 		: in STD_LOGIC;
			rst 		: in STD_LOGIC;
			-- input control signal
			MemWrite : in STD_LOGIC;		--'1':§Õ
			MemRead 	: in STD_LOGIC;		--'1':??
			isMem		: in STD_LOGIC;
			-- RAM1								--?????(BF00~BF03)
			Ram1_OE 		: out STD_LOGIC;
			Ram1_WE 		: out STD_LOGIC;
			Ram1_EN 		: out STD_LOGIC;
			Ram1_Addr	: out STD_LOGIC_VECTOR(17 downto 0);
			Ram1_Data	: inout STD_LOGIC_VECTOR(15 downto 0);
			-- input
			addr 		: in STD_LOGIC_VECTOR(15 downto 0);
			wdata 		: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			rdata 		: out STD_LOGIC_VECTOR(15 downto 0);
			
			-- RAM2								--???????(0000~3FFF), ???????(4000~FFFF), ??????(8000~BEFF), ???????(C000~FFFF)
			Ram2_OE		: out STD_LOGIC;
			Ram2_WE 		: out STD_LOGIC;
			Ram2_EN 		: out STD_LOGIC;
			Ram2_Addr 	: out STD_LOGIC_VECTOR(17 downto 0);
			Ram2_Data	: inout STD_LOGIC_VECTOR(15 downto 0);
			-- input
			PC 			: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			inst 			: out STD_LOGIC_VECTOR(15 downto 0);
			
			--????
			data_ready	: in STD_LOGIC;
			tbre			: in STD_LOGIC;
			tsre			: in STD_LOGIC;
			wrn			: out STD_LOGIC;
			rdn			: out STD_LOGIC;
			
			--FLASH								--???????
			FLASH_ADDR 	: out STD_LOGIC_VECTOR(22 downto 0);
			FLASH_DATA	: inout STD_LOGIC_VECTOR(15 downto 0);
			FLASH_BYTE	: out STD_LOGIC := '1';		--flash??????, ????'1'
			FLASH_VPEN	: out STD_LOGIC := '1';		--flash§Õ????, ????'1'
			FLASH_RP		: out STD_LOGIC := '1';		--'1'???flash????, ????'1'
			FLASH_CE		: out STD_LOGIC := '0';		--flash???
			FLASH_OE		: out STD_LOGIC := '1';		--flash?????, '0'??§¹, ??¦Æ????????'1'
			FLASH_WE		: out STD_LOGIC := '1';		--flash§Õ???
			
			--output
			FLASH_FINISH: out STD_LOGIC := '0'		--'0':¦Ä????	'1':??????????????RAM2
																--????????????, ???PC?IF????
				);
end MemoryUnit;

architecture Behavioral of MemoryUnit is

type state is (s0, s1, s2, s3, s4, s5);
signal mem_state : state;
signal rflag : std_logic := '0';		--rflag='1'????????????????ram1_data??????Ñk?????????????

--flash
signal flash_state : state;
signal flash_finished : std_logic := '0';
signal current_addr : std_logic_vector(15 downto 0) := (others => '0');
shared variable cnt : integer := 0;	--???????????????????FLASH?????
shared variable tmp_MemRead : std_logic ;
shared variable tmp_MemWrite : std_logic ;
shared variable tmp_isMem : std_logic ;
shared variable tmp_PC : std_logic_vector(15 downto 0) ;
shared variable tmp_addr : std_logic_vector(15 downto 0) ;
shared variable tmp_wdata : std_logic_vector(15 downto 0) ;
shared variable tmp_inst : std_logic_vector(15 downto 0) ;
begin
	process(clk, rst)
	variable Ram_Addr: STD_LOGIC_VECTOR(15 downto 0);
	variable Ram_Data: STD_LOGIC_VECTOR(15 downto 0);
	begin			
		if(rst = '0') then
			Ram1_EN <= '1';
			Ram1_OE <= '1';
			Ram1_WE <= '1';
			Ram2_OE <= '1';
			Ram2_WE <= '1';
			wrn <= '1';
			rdn <= '1';
			rflag <= '0';
			
			Ram1_Addr <= (others => '0');
			Ram2_Addr <= (others => '0');
			
			rdata <= (others => '0');
			inst <= (others => '0');
			
			mem_state <= s0;
			flash_state <= s0;
			
			current_addr <= (others => '0');
			
		elsif (clk'event and clk = '1') then
			if (mem_state = s0) then
				tmp_MemRead := MemRead ;
				tmp_MemWrite := MemWrite ;
				tmp_isMem	:= isMem ;
				tmp_PC := PC ;
				tmp_addr := addr ;
				tmp_wdata := wdata ;
				else null ;
			end if;
			if(flash_finished = '1') then
				FLASH_BYTE <= '1';
				FLASH_VPEN <= '1';
				FLASH_RP <= '1';
				FLASH_CE <= '1';
				Ram1_EN <= '1';
				Ram1_OE <= '1';
				Ram1_WE <= '1';
				Ram1_Addr(17 downto 0) <= (others => '0');
				Ram2_EN <= '0';
				Ram2_OE <= '1';
				Ram2_WE <= '1';
				Ram2_Addr(17 downto 16) <= "00";
				wrn <= '1';
				rdn <= '1';
				
				if(tmp_IsMem = '1') then			--??MEM, ????????addr, wdata
					Ram_Addr := tmp_addr;
					Ram_Data := tmp_wdata;
				else								--??IF, ????????PC
					Ram_Addr := tmp_PC;
			--		if PCKeep = '0' then		--PCMUX, ????????????????????
			--			ram2_addr(15 downto 0) <= PCMuxOut;
			--		elsif PCKeep = '1' then
			--			ram2_addr(15 downto 0) <= PCOut;
			--		end if;
				end if;


				if(tmp_MemWrite = '1') then	--RAM2/????§Õ??
					tmp_inst := "0000100000000000" ;
					case mem_state is
						when s0 =>
							rflag <= '0';		--##################
							if(Ram_Addr = x"BF00") then --???????§Õ??
								wrn <= '0';
								--Ram1_Addr(15 downto 0) <= Ram_Addr;
								Ram1_Data(7 downto 0) <= Ram_Data(7 downto 0);
							else								 --RAM2???§Õ??
								Ram2_WE <= '0';
								Ram2_Addr(15 downto 0) <= Ram_Addr;
								Ram2_Data <= Ram_Data;
							end if;
							mem_state <= s1;

						when s3 =>
							if(Ram_Addr = x"BF00") then --????§Õ??
								wrn <= '1';
							else								 --RAM2§Õ??
								Ram2_WE <= '1';
							end if;
							mem_state <= s0;
						when s2 =>
							mem_state <= s3;
						when s1 =>
							mem_state <= s2;
						when others =>
							mem_state <= s0;
					end case;
					inst <= tmp_inst;
				else
					case mem_state is
						when s0 =>
							if(Ram_Addr = x"BF01") then --???????????
								rdata(15 downto 2) <= (others => '0');
								rdata(1) <= data_ready;
								rdata(0) <= tsre and tbre;
								if(rflag = '0') then --???????????¦Æ??????????????/§Õ????????
									Ram1_Data <= (others => 'Z');--??????ram1_data???????
									rflag <= '1'; --???????????????????????rdn??'0'???????????§Õ????rflag='0'????????§Õ?????????
								end if;
								
							elsif(Ram_Addr = x"BF00") then --?????????????
								rflag <= '0';
								rdn <= '0';
							else 									 --?????RAM2
								if(tmp_isMem = '0')	then
									wrn <= '1';	--##################
									rdn <= '1';	--##################
								end if;
								Ram2_OE <= '0';
								Ram2_Addr(15 downto 0) <= Ram_Addr;
								Ram2_Data <= (others => 'Z');							
							end if;
							mem_state <= s1;
							tmp_inst := "0000100000000000" ;
						
						when s3 =>
							if(Ram_Addr = x"BF01") then		--????????(???)
								null;
							elsif(Ram_Addr = x"BF00") then	--??????????
								rdn <= '1';
								rdata(15 downto 8) <= (others => '0');
								rdata(7 downto 0) <= Ram1_Data(7 downto 0);
							else										--?????
								Ram2_OE <= '1';
								if(tmp_IsMem = '1') then	--??MEM, ????????rdata
									rdata <= Ram2_Data;
								else						--??IF, ????????inst
									tmp_inst := Ram2_Data;
								end if;
							end if;	
							mem_state <= s0;
						when s2 =>
							mem_state <= s3;
						when s1 =>
							mem_state <= s2;
							
						when others =>
							mem_state <= s0;
					end case;
					inst <= tmp_inst;
				end if; --RAM2§Õ/??
			else
				if( cnt >= 10000) then
					cnt := 0;
					
					case flash_state is
						when s0 =>		--WE??0
							Ram2_EN <= '0';
							Ram2_WE <= '0';
							Ram2_OE <= '1';
							wrn <= '1';
							rdn <= '1';
							FLASH_WE <= '0';
							FLASH_OE <= '1';
							
							FLASH_BYTE <= '1';
							FLASH_VPEN <= '1';
							FLASH_RP <= '1';
							FLASH_CE <= '0';
							
							flash_state <= s1;
							
						when s1 =>		--???????
							FLASH_DATA <= x"00FF";
							flash_state <= s2;
							
						when s2 =>
							FLASH_WE <= '1';
							flash_state <= s3;
							
						when s3 =>		--??????
							FLASH_ADDR <= "000000" & current_addr & '0';	--??????????????????22~1, ????????6¦Ë(22~17)?block???, ???(16~1)?block?????.
																			--?????????????block
							FLASH_DATA <= (others => 'Z');
							FLASH_OE <= '0';
							flash_state <= s4;
							
						when s4 =>		--???????, ???§Õ?????
							FLASH_OE <= '1';	
							Ram2_WE <= '0';
							Ram2_Addr <= "00" & current_addr;
							Ram2_Data <= FLASH_DATA;
							flash_state <= s5;
						
						when s5 =>		--§Õ?????
							Ram2_WE <= '1';
							current_addr <= current_addr + '1';
							flash_state <= s0;
						
							
						when others =>
							flash_state <= s0;
					end case;
					
					if (current_addr > x"0249") then		--??????????kernel.bin???????????
						flash_finished <= '1';
					end if;
				else
					if (cnt < 10000) then
						cnt := cnt + 1;
					end if;
				end if;	--cnt
			end if; --flash_finished
		end if;	--rst and clk's raise
	end process;
	
	FLASH_FINISH <= flash_finished;
	
end Behavioral;
