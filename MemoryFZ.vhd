library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MemoryUnit is
	port(
			clk 		: in STD_LOGIC;
			rst 		: in STD_LOGIC;
			-- input control signal
			MemWrite    : in STD_LOGIC;		
			MemRead 	: in STD_LOGIC;		
			isMem		: in STD_LOGIC;
			-- RAM1								
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
			
			-- RAM2								
			Ram2_OE		: out STD_LOGIC;
			Ram2_WE 		: out STD_LOGIC;
			Ram2_EN 		: out STD_LOGIC;
			Ram2_Addr 	: out STD_LOGIC_VECTOR(17 downto 0);
			Ram2_Data	: inout STD_LOGIC_VECTOR(15 downto 0);
			-- input
			PC 			: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			inst 			: out STD_LOGIC_VECTOR(15 downto 0);
			
			data_ready	: in STD_LOGIC;
			tbre			: in STD_LOGIC;
			tsre			: in STD_LOGIC;
			wrn			: out STD_LOGIC;
			rdn			: out STD_LOGIC;
			
			--FLASH								
			FLASH_ADDR 	: out STD_LOGIC_VECTOR(22 downto 0);
			FLASH_DATA	: inout STD_LOGIC_VECTOR(15 downto 0);
			FLASH_BYTE	: out STD_LOGIC := '1';		
			FLASH_VPEN	: out STD_LOGIC := '1';		
			FLASH_RP		: out STD_LOGIC := '1';		
			FLASH_CE		: out STD_LOGIC := '0';		
			FLASH_OE		: out STD_LOGIC := '1';	
			FLASH_WE		: out STD_LOGIC := '1';		
			--output
			FLASH_FINISH: out STD_LOGIC := '0'		
				);
end MemoryUnit;

architecture Behavioral of MemoryUnit is

type state is (s0, s1, s2, s3, s4, s5);
signal mem_state : state;
signal rflag : std_logic := '0';		

--flash
signal flash_state : state;
signal flash_finished : std_logic := '0';
signal current_addr : std_logic_vector(15 downto 0) := (others => '0');
shared variable cnt : integer := 0;
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
			mem_state <= s6 when flash_finished = '1' else s0 ;
			--flash_state <= s0;
			current_addr <= (others => '0');
		elsif (clk'event and clk = '1') then
            case mem_state is
                when s6 => 
                    tmp_MemRead := MemRead ;
                    tmp_MemWrite := MemWrite ;
                    tmp_isMem	:= isMem ;
                    tmp_PC := PC ;
                    tmp_addr := addr ;
                    tmp_wdata := wdata ;
                    tmp_inst := (others => '0') ;
                    mem_state <= s7;
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
                    Ram_Addr := tmp_addr when tmp_IsMem = '1' else tmp_PC ;
                    Ram_Data := tmp_wdata ;
                    case (MemWrite&RamAddr) is
                        when "11011111100000000" =>
                            rflag <= '0';
                            wrn <= '0';
                            Ram1_Data(7 downto 0) <= Ram_Data(7 downto 0);
                        when "01011111100000000" =>
                            rflag <= '0';
                            rdn <= '0';
                        when "01011111100000001" =>
                            rdata(15 downto 2) <= (others => '0');
                            rdata(1) <= data_ready;
                            rdata(0) <= tsre and tbre;
                            if(rflag = '0') then 
                                Ram1_Data <= (others => 'Z');
                                rflag <= '1'; 
                            end if;
                        when others => 
                            if(MemWrite = '1') then
                                rflag <= '0';
                                Ram2_WE <= '0';
                                Ram2_Addr(15 downto 0) <= Ram_Addr;
                                Ram2_Data <= Ram_Data;
                            else 								
                                if(tmp_isMem = '0')	then
                                    wrn <= '1';	
                                    rdn <= '1';	
                                end if;
                                Ram2_OE <= '0';
                                Ram2_Addr(15 downto 0) <= Ram_Addr;
                                Ram2_Data <= (others => 'Z');
                            end if;
                    end case ;
                when s7 =>
                    mem_state <= s8 ;
                when s8 =>
                    mem_state <= s9 ;
                    case (MemWrite&RamAddr) is
                        when "11011111100000000" =>
                            wrn <= '1';
                        when "01011111100000000" =>
                            rdn <= '1';
                            rdata(15 downto 8) <= (others => '0');
							rdata(7 downto 0) <= Ram1_Data(7 downto 0);
                        when "01011111100000001" =>
                            null ;
                        when others => 
                            if(MemWrite = '1') then
                                Ram2_WE <= '1' ;
                            else 		
                                Ram2_OE <= '1';	
                                if(tmp_isMem = '0')	then
                                    tmp_inst := Ram2_Data ;
                                else 
                                    rdata <= Ram2_Data ;	
                                end if;							
                            end if;
                    end case ;
                when s9 => 
                    mem_state <= s6 ;     

                when s0 =>
                    cnt := cnt + 1 ;		--WE??0
                    if (cnt > 20000) then 
                        cnt := 0 ;  
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
                        
                        mem_state <= s1;
                    end if ;                   
                when s1 =>	
                    FLASH_DATA <= x"00FF";
                    mem_state <= s2;
                    
                when s2 =>
                    FLASH_WE <= '1';
                    mem_state <= s3;
                    
                when s3 =>		
                    FLASH_ADDR <= "000000" & current_addr & '0';	
                    FLASH_DATA <= (others => 'Z');
                    FLASH_OE <= '0';
                    mem_state <= s4;
                    
                when s4 =>		
                    FLASH_OE <= '1';	
                    Ram2_WE <= '0';
                    Ram2_Addr <= "00" & current_addr;
                    Ram2_Data <= FLASH_DATA;
                    mem_state <= s5;
                
                when s5 =>		
                    Ram2_WE <= '1';
                    current_addr <= current_addr + '1';
                    if (current_addr > x"0249") then 
                        mem_state <= s6;
                    else
                        mem_state <= s0;
                    end if ;

                when others =>
                    mem_state <= s0;

            end case ;
        end if ;
	end process;

	flash_finished <=  '1' when (current_addr > x"0249") else '0' ; 

	FLASH_FINISH <= flash_finished;
	
end Behavioral;
