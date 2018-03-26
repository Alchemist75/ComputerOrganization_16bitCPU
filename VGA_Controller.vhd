library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
entity VGA_Controller is
	port (
		reset	: in  std_logic;
		CLK_in	: in  std_logic;			--50Mʱ������

	-- data
		r0, r1, r2, r3, r4,r5,r6,r7 : in std_logic_vector(15 downto 0);


		PC : in std_logic_vector(15 downto 0);
		CM : in std_logic_vector(15 downto 0);
		Tdata : in std_logic_vector(15 downto 0);
		SPdata : in std_logic_vector(15 downto 0);
		IHdata : in std_logic_vector(15 downto 0);
		inputcode : in std_logic_vector(7 downto 0);
	-- font rom
		romAddr : out std_logic_vector(10 downto 0);
		romData : in std_logic_vector(7 downto 0);
	--VGA Side
		hs,vs	: out std_logic;		--��ͬ������ͬ���ź�
		oRed	: out std_logic_vector (2 downto 0);
		oGreen	: out std_logic_vector (2 downto 0);
		oBlue	: out std_logic_vector (2 downto 0)
	);		
end entity VGA_Controller;

architecture behave of VGA_Controller is

--VGA
	signal CLK,CLK_2	: std_logic;
	signal rt,gt,bt	: std_logic_vector (2 downto 0);
	signal hst,vst	: std_logic;
	signal x		: std_logic_vector (9 downto 0);		--X����
	signal y		: std_logic_vector (8 downto 0);		--Y����
	
	shared variable dx : integer range 0 to 7;
	shared variable intx, inty, tmp : integer range 0 to 640;
	shared variable i, j, cur_x, cur_y : integer range 0 to 40;

	shared variable lastint : std_logic_vector(7 downto 0);
	type data_type is array(0 to 8) of std_logic_vector(7 downto 0);
	signal data : data_type;
	shared variable count : integer range 0 to 801;
	shared variable code : integer range 0 to 100;
	shared variable cursor_cnt : integer range 0 to 50000000;
	signal mode 	: std_logic := '1';
begin
CLK<=CLK_2;
 -----------------------------------------------------------------------
	process (CLK_in)
	begin
		if CLK_in'event and CLK_in = '1' then	--��50M�����źŶ���Ƶ
			CLK_2 <= not CLK_2;
		end if;
	end process;
		

 -----------------------------------------------------------------------
	process (CLK, reset)	--������������������������
	begin
		if reset = '0' then
			x <= (others => '0');
		elsif CLK'event and CLK = '1' then
			if x = 799 then
				x <= (others => '0');
			else
				x <= x + 1;
			end if;
		end if;
	end process;

  -----------------------------------------------------------------------
	 process (CLK, reset)	--����������������������
	 begin
	  	if reset = '0' then
	   		y <= (others => '0');
	  	elsif CLK'event and CLK = '1' then
				if x = 799 then
	    		if y = 524 then
	     			y <= (others => '0');
	    		else
	     			y <= y + 1;
	    		end if;
	   		end if;
	  	end if;
	 end process;
 
  -----------------------------------------------------------------------
	 process (CLK, reset)	--��ͬ���źŲ�����ͬ�������ǰ��16��
	 begin
		  if reset = '0' then
		   hst <= '1';
		  elsif CLK'event and CLK = '1' then
		   	if x >= 656 and x < 752 then
		    	hst <= '0';
		   	else
		    	hst <= '1';
		   	end if;
		  end if;
	 end process;
 
 -----------------------------------------------------------------------
	 process (CLK, reset)	--��ͬ���źŲ�����ͬ�������ǰ��0��
	 begin
	  	if reset = '0' then
	   		vst <= '1';
	  	elsif CLK'event and CLK = '1' then
	   		if y >= 490 and y< 492 then
	    		vst <= '0';
	   		else
	    		vst <= '1';
	   		end if;
	  	end if;
	 end process;
 -----------------------------------------------------------------------
	 process (CLK, reset)	--��ͬ���ź����
	 begin
	  	if reset = '0' then
	   		hs <= '0';
	  	elsif CLK'event and CLK = '1' then
	   		hs <=  hst;
	  	end if;
	 end process;

 -----------------------------------------------------------------------
	 process (CLK, reset)	--��ͬ���ź����
	 begin
	  	if reset = '0' then
	   		vs <= '0';
	  	elsif CLK'event and CLK='1' then
	   		vs <=  vst;
	  	end if;
	 end process;

-----------------------------------------------------------------------
	process(CLK, reset)
		variable tmpint : integer range 0 to 500 ;
		variable tmpchar : std_logic_vector(7 downto 0) ;
	begin
		if (reset = '0') then
			data <= (others => (others => '0')) ;
			count := 0; 
		else 
			if(clk'event and clk = '1') then
				if (inputcode = "11111111") then
					mode <= not mode;
				elsif (inputcode = "11111110") then
					count := count - 1;
					data(count) <= "00000000";
					cur_x := count mod 32;
					cur_y := count / 32;
				elsif (inputcode /= "00000000") then
					data(count) <= inputcode;
					count := count + 1;
					cur_x := count mod 32;
					cur_y := count / 32;
				end if;
			end if ;
		end if;
	end process;


	process(reset,clk,x,y) -- XY���궨λ����
	begin  
		if reset='0' then
			      rt   <= "000";
					gt	<= "000";
					bt	<= "000";	
					cursor_cnt := 0;
		elsif(clk'event and clk='1')then 
			if (mode = '0') then
				if (x >= 39 and x <= 47) then
					if (y >= 64 and y <= 71) or (y >= 80 and y <= 87) or (y >= 96 and y <= 103) or (y >= 112 and y <= 119)
						or (y >= 128 and y <= 135) or (y >= 144 and y <= 151) or (y >= 160 and y <= 167) or (y >= 176 and y<= 183)
						then
						if x = 39 then
							inty := conv_integer(y);
							romAddr <= conv_std_logic_vector(82 * 8 + inty mod 8,11);--R
						else
							dx := 7 - (conv_integer(x) - 40);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					else
						rt <= (others => '0');
						gt <= (others => '0');
						bt <= (others => '0');
					end if;
				elsif (x >= 49 and x <= 57) then
					if (y >= 64 and y <= 71) or (y >= 80 and y <= 87) or (y >= 96 and y <= 103) or (y >= 112 and y <= 119)
						or (y >= 128 and y <= 135) or (y >= 144 and y <= 151) or (y >= 160 and y <= 167) or (y >= 176 and y<= 183)
						then -- 0 ~ 7
						if (x = 49) then
							inty := conv_integer(y);
							romAddr <= conv_std_logic_vector(((inty - 64) / 16  + 48) * 8 + inty mod 8, 11);
						else
							dx := 7 - (conv_integer(x) - 50);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					else
						rt <= (others => '0');
						gt <= (others => '0');
						bt <= (others => '0');
					end if;
				elsif (x >= 69 and x <= 77) then
					if (y >= 64 and y <= 71) then -- r0 3
						if (x = 69) then 
							inty := conv_integer(y);
							tmp := conv_integer(r0(15 downto 12));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 70);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 80 and y <= 87) then --r1 3
						if (x = 69) then 
							inty := conv_integer(y);
							tmp := conv_integer(r1(15 downto 12));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 70);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 96 and y<= 103) then --r2 3
						if (x = 69) then 
							inty := conv_integer(y);
							tmp := conv_integer(r2(15 downto 12));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 70);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 112 and y<= 119) then -- r3 3
						if (x = 69) then 
							inty := conv_integer(y);
							tmp := conv_integer(r3(15 downto 12));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 70);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 128 and y<= 135) then --r4 3
						if (x = 69) then 
							inty := conv_integer(y);
							tmp := conv_integer(r4(15 downto 12));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 70);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 144 and y <= 151) then -- r5 3
						if (x = 69) then 
							inty := conv_integer(y);
							tmp := conv_integer(r5(15 downto 12));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 70);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 160 and y <= 167) then -- r6 3
						if (x = 69) then 
							inty := conv_integer(y);
							tmp := conv_integer(r6(15 downto 12));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 70);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 176 and y <= 183) then -- r7 3
						if (x = 69) then 
							inty := conv_integer(y);
							tmp := conv_integer(r7(15 downto 12));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 70);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					else 
						rt <= (others => '0');
						gt <= (others => '0');
						bt <= (others => '0');
					end if;
				elsif (x >= 79 and x <= 87) then
					if (y >= 64 and y <= 71) then -- r0 2
						if (x = 79) then 
							inty := conv_integer(y);
							tmp := conv_integer(r0(11 downto 8));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 80);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 80 and y <= 87) then --r1 2
						if (x = 79) then 
							inty := conv_integer(y);
							tmp := conv_integer(r1(11 downto 8));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 80);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 96 and y<= 103) then --r2 2
						if (x = 79) then 
							inty := conv_integer(y);
							tmp := conv_integer(r2(11 downto 8));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 80);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 112 and y<= 119) then -- r3 2
						if (x = 79) then 
							inty := conv_integer(y);
							tmp := conv_integer(r3(11 downto 8));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 80);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 128 and y<= 135) then --r4 2
						if (x = 79) then 
							inty := conv_integer(y);
							tmp := conv_integer(r4(11 downto 8));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 80);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 144 and y <= 151) then -- r5 2
						if (x = 79) then 
							inty := conv_integer(y);
							tmp := conv_integer(r5(11 downto 8));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 80);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 160 and y <= 167) then -- r6 2
						if (x = 79) then 
							inty := conv_integer(y);
							tmp := conv_integer(r6(11 downto 8));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 80);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 176 and y <= 183) then -- r7 2
						if (x = 79) then 
							inty := conv_integer(y);
							tmp := conv_integer(r7(11 downto 8));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 80);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					else 
						rt <= (others => '0');
						gt <= (others => '0');
						bt <= (others => '0');
					end if;
				elsif (x >= 89 and x <= 97) then
					if (y >= 64 and y <= 71) then -- r0 1
						if (x = 89) then 
							inty := conv_integer(y);
							tmp := conv_integer(r0(7 downto 4));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 90);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 80 and y <= 87) then --r1 1
						if (x = 89) then 
							inty := conv_integer(y);
							tmp := conv_integer(r1(7 downto 4));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 90);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 96 and y<= 103) then --r2 1
						if (x = 89) then 
							inty := conv_integer(y);
							tmp := conv_integer(r2(7 downto 4));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 90);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 112 and y<= 119) then -- r3 1
						if (x = 89) then 
							inty := conv_integer(y);
							tmp := conv_integer(r3(7 downto 4));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 90);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 128 and y<= 135) then --r4 1
						if (x = 89) then 
							inty := conv_integer(y);
							tmp := conv_integer(r4(7 downto 4));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 90);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 144 and y <= 151) then -- r5 1
						if (x = 89) then 
							inty := conv_integer(y);
							tmp := conv_integer(r5(7 downto 4));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 90);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 160 and y <= 167) then -- r6 1
						if (x = 89) then 
							inty := conv_integer(y);
							tmp := conv_integer(r6(7 downto 4));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 90);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 176 and y <= 183) then -- r7 1
						if (x = 89) then 
							inty := conv_integer(y);
							tmp := conv_integer(r7(7 downto 4));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 90);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					else 
						rt <= (others => '0');
						gt <= (others => '0');
						bt <= (others => '0');
					end if;
				elsif (x >= 99 and x <= 107) then
					if (y >= 64 and y <= 71) then -- r0 0
						if (x = 99) then 
							inty := conv_integer(y);
							tmp := conv_integer(r0(3 downto 0));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 100);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 80 and y <= 87) then --r1 0
						if (x = 99) then 
							inty := conv_integer(y);
							tmp := conv_integer(r1(3 downto 0));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 100);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 96 and y<= 103) then --r2 0
						if (x = 99) then 
							inty := conv_integer(y);
							tmp := conv_integer(r2(3 downto 0));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 100);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 112 and y<= 119) then -- r3 0
						if (x = 99) then 
							inty := conv_integer(y);
							tmp := conv_integer(r3(3 downto 0));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 100);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 128 and y<= 135) then --r4 0
						if (x = 99) then 
							inty := conv_integer(y);
							tmp := conv_integer(r4(3 downto 0));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 100);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 144 and y <= 151) then -- r5 0
						if (x = 99) then 
							inty := conv_integer(y);
							tmp := conv_integer(r5(3 downto 0));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 100);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 160 and y <= 167) then -- r6 0
						if (x = 99) then 
							inty := conv_integer(y);
							tmp := conv_integer(r6(3 downto 0));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 100);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 176 and y <= 183) then -- r7 0
						if (x = 99) then 
							inty := conv_integer(y);
							tmp := conv_integer(r7(3 downto 0));
							if ( tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
							else 
								romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 100);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					else 
						rt <= (others => '0');
						gt <= (others => '0');
						bt <= (others => '0');
					end if;
				elsif ( x >= 149 and x <= 157) then 
					if ( y >= 64 and y <= 71) then --PC��P
						if (x = 149) then
							inty := conv_integer(y);
							romAddr <= conv_std_logic_vector( 80 * 8 + inty mod 8, 11);
						else
							dx := 7 - (conv_integer(x) - 150);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif ( y >= 80 and y <= 87) then -- CM��C
						if (x = 149) then
							inty := conv_integer(y);
							romAddr <= conv_std_logic_vector( 67 * 8 + inty mod 8, 11);
						else
							dx := 7 - (conv_integer(x) - 150);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif( y>= 112 and y <= 119) then -- SP��S
						if (x = 149) then
							inty := conv_integer(y);
							romAddr <= conv_std_logic_vector( 83 * 8 + inty mod 8, 11);
						else
							dx := 7 - (conv_integer(x) - 150);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif( y>= 128 and y <= 135) then -- IH��I
						if (x = 149) then
							inty := conv_integer(y);
							romAddr <= conv_std_logic_vector( 73 * 8 + inty mod 8, 11);
						else
							dx := 7 - (conv_integer(x) - 150);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					else 
						rt <= (others => '0');
						gt <= (others => '0');
						bt <= (others => '0');
					end if;
				elsif ( x >= 159 and x <= 167) then 
					if ( y >= 64 and y <= 71) then --PC��C
						if (x = 159) then
							inty := conv_integer(y);
							romAddr <= conv_std_logic_vector( 67 * 8 + inty mod 8, 11);
						else
							dx := 7 - (conv_integer(x) - 160);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 80 and y <= 87) then -- CM��M
						if (x = 159) then
							inty := conv_integer(y);
							romAddr <= conv_std_logic_vector( 77 * 8 + inty mod 8, 11);
						else
							dx := 7 - (conv_integer(x) - 160);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 96 and y <= 103) then --T
						if (x = 159) then
							inty := conv_integer(y);
							romAddr <= conv_std_logic_vector( 84 * 8 + inty mod 8, 11);
						else
							dx := 7 - (conv_integer(x) - 160);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif ( y >= 112 and y <= 119) then --SP��P
						if (x = 159) then
							inty := conv_integer(y);
							romAddr <= conv_std_logic_vector( 80 * 8 + inty mod 8, 11);
						else
							dx := 7 - (conv_integer(x) - 160);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif ( y >= 128 and y <= 135) then --IH��H
						if (x = 159) then
							inty := conv_integer(y);
							romAddr <= conv_std_logic_vector( 72 * 8 + inty mod 8, 11);
						else
							dx := 7 - (conv_integer(x) - 160);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					else 
						rt <= (others => '0');
						gt <= (others => '0');
						bt <= (others => '0');
					end if;
				elsif ( x >= 179 and x <= 187) then 
					if ( y >= 64 and y <= 71) then --PC 3
						if (x = 179) then
							inty := conv_integer(y);
							tmp := conv_integer(PC(15 downto 12));
							if (tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
							else 
								romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 180);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 80 and y <= 87) then -- CM 3
						if (x = 179) then
							inty := conv_integer(y);
							tmp := conv_integer(CM(15 downto 12));
							if (tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
							else 
								romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 180);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 96 and y <= 103) then -- T 3
						if (x = 179) then
							inty := conv_integer(y);
							tmp := conv_integer(Tdata(15 downto 12));
							if (tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
							else 
								romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 180);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 112 and y <= 119) then -- SP 3
						if (x = 179) then
							inty := conv_integer(y);
							tmp := conv_integer(SPdata(15 downto 12));
							if (tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
							else 
								romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 180);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 128 and y <= 135) then -- IH 3
						if (x = 179) then
							inty := conv_integer(y);
							tmp := conv_integer(IHdata(15 downto 12));
							if (tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
							else 
								romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 180);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					else 
						rt <= (others => '0');
						gt <= (others => '0');
						bt <= (others => '0');
					end if;
				elsif (x >= 189 and x <= 197) then
					if ( y >= 64 and y <= 71) then --PC 2
						if (x = 189) then
							inty := conv_integer(y);
							tmp := conv_integer(PC(11 downto 8));
							if (tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
							else 
								romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 190);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 80 and y <= 87) then --CM 2
						if (x = 189) then
							inty := conv_integer(y);
							tmp := conv_integer(CM(11 downto 8));
							if (tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
							else 
								romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 190);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 96 and y <= 103) then --T 2
						if (x = 189) then
							inty := conv_integer(y);
							tmp := conv_integer(Tdata(11 downto 8));
							if (tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
							else 
								romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 190);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 112 and y <= 119) then --SP 2
						if (x = 189) then
							inty := conv_integer(y);
							tmp := conv_integer(SPdata(11 downto 8));
							if (tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
							else 
								romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 190);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif (y >= 128 and y <= 135) then --IH 2
						if (x = 189) then
							inty := conv_integer(y);
							tmp := conv_integer(IHdata(11 downto 8));
							if (tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
							else 
								romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 190);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					else 
						rt <= (others => '0');
						gt <= (others => '0');
						bt <= (others => '0');
					end if;
				elsif (x >= 199 and x <= 207) then
					if ( y >= 64 and y <= 71) then --PC 1
						if (x = 199) then
							inty := conv_integer(y);
							tmp := conv_integer(PC(7 downto 4));
							if (tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
							else 
								romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 200);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif ( y >= 80 and y <= 87) then -- CM 1
						if (x = 199) then
							inty := conv_integer(y);
							tmp := conv_integer(CM(7 downto 4));
							if (tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
							else 
								romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 200);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif ( y >= 96 and y <= 103) then -- T 1
						if (x = 199) then
							inty := conv_integer(y);
							tmp := conv_integer(Tdata(7 downto 4));
							if (tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
							else 
								romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 200);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif ( y >= 112 and y <= 119) then -- SP 1
						if (x = 199) then
							inty := conv_integer(y);
							tmp := conv_integer(SPdata(7 downto 4));
							if (tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
							else 
								romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 200);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif ( y >= 128 and y <= 135) then -- IH 1
						if (x = 199) then
							inty := conv_integer(y);
							tmp := conv_integer(IHdata(7 downto 4));
							if (tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
							else 
								romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 200);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					
					else 
						rt <= (others => '0');
						gt <= (others => '0');
						bt <= (others => '0');
					end if;
				elsif (x >= 209 and x<= 217) then
					if ( y >= 64 and y <= 71) then --PC 0
						if (x = 209) then
							inty := conv_integer(y);
							tmp := conv_integer(PC(3 downto 0));
							if (tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
							else 
								romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 210);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif ( y >= 80 and y <= 87) then -- CM 0
						if (x = 209) then
							inty := conv_integer(y);
							tmp := conv_integer(CM(3 downto 0));
							if (tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
							else 
								romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 210);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif ( y >= 96 and y <= 103) then --T 0
						if (x = 209) then
							inty := conv_integer(y);
							tmp := conv_integer(Tdata(3 downto 0));
							if (tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
							else 
								romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 210);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif ( y >= 112 and y <= 119) then --SP 0
						if (x = 209) then
							inty := conv_integer(y);
							tmp := conv_integer(SPdata(3 downto 0));
							if (tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
							else 
								romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 210);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					elsif ( y >= 128 and y <= 135) then --IH 0
						if (x = 209) then
							inty := conv_integer(y);
							tmp := conv_integer(IHdata(3 downto 0));
							if (tmp <= 9) then
								romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
							else 
								romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
							end if;
						else
							dx := 7 - (conv_integer(x) - 210);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					else 
						rt <= (others => '0');
						gt <= (others => '0');
						bt <= (others => '0');
					end if;
				else
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			else 
				cursor_cnt := cursor_cnt + 1;
				if (cursor_cnt = 25000000) then
					cursor_cnt := 0;
				end if;
				if (x >= 64 and x <= 576 and y >= 48 and y <= 448) then 
					intx := conv_integer(x);
					inty := conv_integer(y);
					
					if (intx mod 16 >= 6 and intx mod 16 <= 14 and inty mod 16 >= 6 and inty mod 16 <= 13) then 
						if (intx mod 16 = 6) then
							i := (intx - 64) / 16;
							j := (inty - 48)  / 16;
							code := conv_integer(data(32 * j + i));
							romAddr <= conv_std_logic_vector(code * 8 + (inty - 6) mod 16, 11);
							if (i = cur_x and j = cur_y and cursor_cnt > 12500000) then
								rt <= (others => '1');
								gt <= (others => '1');
								bt <= (others => '1');
							else
								rt <= (others => '0');
								gt <= (others => '0');
								bt <= (others => '0');
							end if;
						else 
							dx := 7 - (intx mod 16 - 7);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					else 
						rt <= (others => '0');
						gt <= (others => '0');
						bt <= (others => '0');
					end if;
					
				else 
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			end if;
		end if;		 
	end process;	

-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
	process (hst, vst, rt, gt, bt)	--ɫ�����
	begin
		if ((hst = '1') and (vst = '1')) then
			oRed	<= rt;
			oGreen	<= gt;
			oBlue	<= bt;
		else
			oRed	<= (others => '0');
			oGreen	<= (others => '0');
			oBlue	<= (others => '0');
		end if;
	end process;

end behave;