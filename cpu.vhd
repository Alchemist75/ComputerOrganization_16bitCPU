library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cpu is
	port(
		rst			: in STD_LOGIC;
		--clk 			: in STD_LOGIC;
		clk_board	: in STD_LOGIC;
		clk_button	: in STD_LOGIC;
		clksignal	: in STD_LOGIC;

		-- Serial Port
		dataReady	: in STD_LOGIC;
		tbre		: in STD_LOGIC;
		tsre		: in STD_LOGIC;
		rdn			: inout	STD_LOGIC;
		wrn			: inout	STD_LOGIC;

		-- RAM1 
		Ram1_OE		: out STD_LOGIC;
		Ram1_WE		: out STD_LOGIC;
		Ram1_EN		: out STD_LOGIC;
		Ram1_Addr	: out STD_LOGIC_VECTOR(17 downto 0);
		Ram1_Data	: inout STD_LOGIC_VECTOR(15 downto 0);

		-- RAM2
		Ram2_OE		: out STD_LOGIC;
		Ram2_WE		: out STD_LOGIC;
		Ram2_EN		: out STD_LOGIC;
		Ram2_Addr	: out STD_LOGIC_VECTOR(17 downto 0);
		Ram2_Data	: inout STD_LOGIC_VECTOR(15 downto 0);
		
		-- LED
		led			: out STD_LOGIC_VECTOR(15 downto 0);
		showclk		: out STD_LOGIC_VECTOR(6 downto 0);

		-- VGA
		hs, vs 		: out STD_LOGIC;
		redOut		: out STD_LOGIC_VECTOR(2 downto 0);
		greenOut 	: out STD_LOGIC_VECTOR(2 downto 0);
		blueOut 	: out STD_LOGIC_VECTOR(2 downto 0);
		
		-- PS2
		ps_clk		: in STD_LOGIC;
		ps_data		: in STD_LOGIC;
		
		-- FLASH								--监控程序
		FLASH_ADDR 	: out STD_LOGIC_VECTOR(22 downto 0);
		FLASH_DATA	: inout STD_LOGIC_VECTOR(15 downto 0);
		FLASH_BYTE	: out STD_LOGIC := '1';		--flash操作模式, 常置'1'
		FLASH_VPEN	: out STD_LOGIC := '1';		--flash写保护, 常置'1'
		FLASH_RP		: out STD_LOGIC := '1';		--'1'表示flash工作, 常置'1'
		FLASH_CE		: out STD_LOGIC := '0';		--flash使能
		FLASH_OE		: out STD_LOGIC := '1';		--flash读使能, '0'有效, 每次都操作后值'1'
		FLASH_WE		: out STD_LOGIC := '1'		--flash写使能
	);
end cpu;

architecture Behavioral of cpu is

	component HFCLOCK PORT 
	(
		CLKIN_IN : in std_logic; 
		CLKFX_OUT : out std_logic;
		CLK0_OUT : out std_logic
	);
	end component ;
	
	COMPONENT KeyboardDecoder
	PORT(
		scancode : IN std_logic_vector(7 downto 0);          
		outputcode : OUT std_logic_vector(7 downto 0);
		clk : in std_logic;
		rst : in std_logic
		);
	END COMPONENT;

	COMPONENT Keyboard
	PORT(
		rst : IN std_logic;
		clkin : IN std_logic;
		datain : IN std_logic;
		fclk : IN std_logic;          
		scancode : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	component Tryrom
		port (
				clka : in std_logic;
				addra : in std_logic_vector(10 downto 0);
				douta : out std_logic_vector(7 downto 0)
		);
	end component;
attribute box_type : string ;
attribute box_type of Tryrom : component is "black_box" ;
--	component Clock
--		port(
--			rst	: in STD_LOGIC;
--			clk 	: in STD_LOGIC;
--			clk0	: out STD_LOGIC;
--			clk1 	: out STD_LOGIC;
--			clk2	: out STD_LOGIC;
--			clk3 	: out STD_LOGIC
--		);
--	end component;
	
	component MemController
		port(
			MemRead	: in STD_LOGIC;
			MemWrite : in STD_LOGIC;
			
			isMem		: out STD_LOGIC
		);
	end component;

	component Controller
		port(
			rst 		: in STD_LOGIC;
			inst		: in STD_LOGIC_VECTOR(15 downto 0);
			--
			RegSrcA		: out STD_LOGIC_VECTOR(3 downto 0);
			RegSrcB		: out STD_LOGIC_VECTOR(3 downto 0);
			ImmSrc 		: out STD_LOGIC_VECTOR(2 downto 0);
			ExtendOp 	: out STD_LOGIC;
			RegDst 		: out STD_LOGIC_VECTOR(3 downto 0);
			ALUOp 		: out STD_LOGIC_VECTOR(3 downto 0);
			ALUSrcB 	: out STD_LOGIC;
			ALURes 		: out STD_LOGIC_VECTOR(1 downto 0);
			Jump 		: out STD_LOGIC;
			BranchOp 	: out STD_LOGIC_VECTOR(1 downto 0);
			Branch 		: out STD_LOGIC;
			MemRead 	: out STD_LOGIC;
			MemWrite 	: out STD_LOGIC;
			MemToReg 	: out STD_LOGIC;
			RegWrite 	: out STD_LOGIC
		);
	end component;

	component ForwardingUnit
		port(
			rst			: in std_Logic;
			-- control signal
			EX_ALUSrcB	: in STD_LOGIC;
			EX_MemWrite : in STD_LOGIC;
			MEM_RegDst	: in STD_LOGIC_VECTOR(3 downto 0);
			WB_RegDst	: in STD_LOGIC_VECTOR(3 downto 0);
			-- input
			EX_raddr1 	: in STD_LOGIC_VECTOR(3 downto 0);
			EX_raddr2 	: in STD_LOGIC_VECTOR(3 downto 0);
			-- output
			ForwardA	: out STD_LOGIC_VECTOR(1 downto 0);
			ForwardB 	: out STD_LOGIC_VECTOR(1 downto 0);
			ForwardWriteMem : out STD_LOGIC_VECTOR(1 downto 0) 
		);
	end component;

	component HazardDetectionUnit
		port(
			-- control signal
			EX_MemRead 	: in STD_LOGIC;
			EX_RegDst	:in STD_LOGIC_VECTOR(3 downto 0);
			-- input
			raddr1 		: in STD_LOGIC_VECTOR(3 downto 0);
			raddr2 		: in STD_LOGIC_VECTOR(3 downto 0);
			isMem	: in STD_LOGIC;
			
			-- output
			PCStall		: out STD_LOGIC;
			IFIDStall 	: out STD_LOGIC;
			IDEXFlush 	: out STD_LOGIC
		);
	end component;

	component MemoryUnit is
		port(
			clk 		: in STD_LOGIC;
			rst 		: in STD_LOGIC;		

			-- input control signal
			MemWrite 	: in STD_LOGIC;		--'1':锟
			MemRead 	: in STD_LOGIC;		--'1':锟
			isMem 	: in STD_LOGIC;
			
			-- RAM1							--涓轰覆锟紹F00~BF03)
			Ram1_OE 	: out STD_LOGIC;
			Ram1_WE 	: out STD_LOGIC;
			Ram1_EN 	: out STD_LOGIC;
			Ram1_Addr	: out STD_LOGIC_VECTOR(17 downto 0);
			Ram1_Data	: inout STD_LOGIC_VECTOR(15 downto 0);
			-- input
			addr 		: in STD_LOGIC_VECTOR(15 downto 0);
			wdata 		: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			rdata 		: out STD_LOGIC_VECTOR(15 downto 0);	
				
			-- RAM2								--录脿驴脴鲁脤脨貌(0000~3FFF), 脫脙禄搂鲁脤脨貌(4000~FFFF), 脧碌脥鲁脢媒戮脻(8000~BEFF), 脫脙禄搂脢媒戮脻(C000~FFFF)
			Ram2_OE		: out STD_LOGIC;
			Ram2_WE 		: out STD_LOGIC;
			Ram2_EN 		: out STD_LOGIC;
			Ram2_Addr 	: out STD_LOGIC_VECTOR(17 downto 0);
			Ram2_Data	: inout STD_LOGIC_VECTOR(15 downto 0);
			-- input
			PC 			: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			inst 			: out STD_LOGIC_VECTOR(15 downto 0);
				
			--麓庐驴脷
			data_ready	: in STD_LOGIC;
			tbre			: in STD_LOGIC;
			tsre			: in STD_LOGIC;
			wrn			: out STD_LOGIC;
			rdn			: out STD_LOGIC;
			
			-- FLASH								--监控程序
			FLASH_ADDR 	: out STD_LOGIC_VECTOR(22 downto 0);
			FLASH_DATA	: inout STD_LOGIC_VECTOR(15 downto 0);
			FLASH_BYTE	: out STD_LOGIC := '1';		--flash操作模式, 常置'1'
			FLASH_VPEN	: out STD_LOGIC := '1';		--flash写保护, 常置'1'
			FLASH_RP		: out STD_LOGIC := '1';		--'1'表示flash工作, 常置'1'
			FLASH_CE		: out STD_LOGIC := '0';		--flash使能
			FLASH_OE		: out STD_LOGIC := '1';		--flash读使能, '0'有效, 每次都操作后值'1'
			FLASH_WE		: out STD_LOGIC := '1';		--flash写使能
			
			--output
			FLASH_FINISH: out STD_LOGIC := '0'		--'0':未完成	'1':完成读监控程序到RAM2
																--这要转给控制器, 要把PC?IF?停顿
		);
	end component;

	--component 
	----------------------------
	--          IF            
	----------------------------
	component PCRegister
		port(
			clk 		: in STD_LOGIC;
			rst 		: in STD_LOGIC;
			PCIn 		: in STD_LOGIC_VECTOR(15 downto 0);
			PCOut		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component PCAdder
		port(
			PC 		: in STD_LOGIC_VECTOR(15 downto 0);
			NPC 		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component RPCAdder
		port(
			PC 			: in STD_LOGIC_VECTOR(15 downto 0);
			RPC 		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component PCMux
		port(
			-- control signal
			Jump		: in STD_LOGIC;
			BranchJudge	: in STD_LOGIC;
			PCStall		: in STD_LOGIC;
			--
			PC 			: in STD_LOGIC_VECTOR(15 downto 0);
			NPC			: in STD_LOGIC_VECTOR(15 downto 0);
			PCAddImm	: in STD_LOGIC_VECTOR(15 downto 0);
			reg1 	    : in STD_LOGIC_VECTOR(15 downto 0);
			--
			PCOut		: out STD_LOGIC_VECTOR(15 downto 0);
			
			FLASH_FINISH: in STD_LOGIC
		);
	end component;

	component IFIDRegister
		port(
			clk 		: in STD_LOGIC;
			rst 		: in STD_LOGIC;
			-- control signal
			IFIDStall 	: in STD_LOGIC;
			IFIDFlush 	: in STD_LOGIC;
			-- input
			IF_PC		: in STD_LOGIC_VECTOR(15 downto 0);
			IF_inst		: in STD_LOGIC_VECTOR(15 downto 0);
			IF_RPC		: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			ID_PC		: out STD_LOGIC_VECTOR(15 downto 0);
			ID_inst		: out STD_LOGIC_VECTOR(15 downto 0);
			ID_RPC		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;
	----------------------------
	--          ID            
	----------------------------
	component Registers
		port(
			clk 		: in STD_LOGIC;
			rst 		: in STD_LOGIC;
			-- control signal
			RegWrite 	: in STD_LOGIC;
			-- input
			raddr1		: in STD_LOGIC_VECTOR(3 downto 0);
			raddr2 		: in STD_LOGIC_VECTOR(3 downto 0);
			waddr 		: in STD_LOGIC_VECTOR(3 downto 0);
			wdata 		: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			reg1 		: out STD_LOGIC_VECTOR(15 downto 0);
			reg2 		: out STD_LOGIC_VECTOR(15 downto 0);
			
			showreg_r0  : out STD_LOGIC_VECTOR(15 downto 0);
			showreg_r1  : out STD_LOGIC_VECTOR(15 downto 0);
			showreg_r2  : out STD_LOGIC_VECTOR(15 downto 0);
			showreg_r3  : out STD_LOGIC_VECTOR(15 downto 0);
			showreg_r4  : out STD_LOGIC_VECTOR(15 downto 0);
			showreg_r5  : out STD_LOGIC_VECTOR(15 downto 0);
			showreg_r6  : out STD_LOGIC_VECTOR(15 downto 0);
			showreg_r7  : out STD_LOGIC_VECTOR(15 downto 0);
			showreg_T  : out STD_LOGIC_VECTOR(15 downto 0);
			showreg_IH  : out STD_LOGIC_VECTOR(15 downto 0);
			showreg_SP  : out STD_LOGIC_VECTOR(15 downto 0);
			showreg_RA  : out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component ImmUnit
		port(
			-- control signal
			ImmSrc		: in STD_LOGIC_VECTOR(2 downto 0);
			ExtendOp	: in STD_LOGIC;
			--
			inst 		: in STD_LOGIC_VECTOR(15 downto 0);
			--
			immOut		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component IDEXRegister
		port(
			clk 		: in STD_LOGIC;
			rst 		: in STD_LOGIC;
			-- control signal
			IDEXFlush 	: in STD_LOGIC;
			-- input control signal
			ID_RegDst	: in STD_LOGIC_VECTOR(3 downto 0);
			ID_ALUOp	: in STD_LOGIC_VECTOR(3 downto 0);
			ID_ALUSrcB	: in STD_LOGIC;
			ID_ALURes  	: in STD_LOGIC_VECTOR(1 downto 0);
			ID_Jump		: in STD_LOGIC;
			ID_BranchOp	: in STD_LOGIC_VECTOR(1 downto 0);
			ID_Branch 	: in STD_LOGIC;
			ID_MemRead	: in STD_LOGIC;
			ID_MemWrite	: in STD_LOGIC;
			ID_MemToRead: in STD_LOGIC;
			ID_RegWrite : in STD_LOGIC;
			-- input
			ID_PC 		: in STD_LOGIC_VECTOR(15 downto 0);
			ID_reg1		: in STD_LOGIC_VECTOR(15 downto 0);
			ID_reg2		: in STD_LOGIC_VECTOR(15 downto 0);
			ID_raddr1	: in STD_LOGIC_VECTOR(3 downto 0);
			ID_raddr2	: in STD_LOGIC_VECTOR(3 downto 0);
			ID_imm		: in STD_LOGIC_VECTOR(15 downto 0);
			ID_RPC 		: in STD_LOGIC_VECTOR(15 downto 0);
			-- output control signal
			EX_RegDst	: out STD_LOGIC_VECTOR(3 downto 0);
			EX_ALUOp	: out STD_LOGIC_VECTOR(3 downto 0);
			EX_ALUSrcB	: out STD_LOGIC;
			EX_ALURes  	: out STD_LOGIC_VECTOR(1 downto 0);
			EX_Jump		: out STD_LOGIC;
			EX_BranchOp	: out STD_LOGIC_VECTOR(1 downto 0);
			EX_Branch 	: out STD_LOGIC;
			EX_MemRead	: out STD_LOGIC;
			EX_MemWrite	: out STD_LOGIC;
			EX_MemToRead: out STD_LOGIC;
			EX_RegWrite : out STD_LOGIC;
			-- output
			EX_PC 		: out STD_LOGIC_VECTOR(15 downto 0);
			EX_reg1		: out STD_LOGIC_VECTOR(15 downto 0);
			EX_reg2		: out STD_LOGIC_VECTOR(15 downto 0);
			EX_raddr1	: out STD_LOGIC_VECTOR(3 downto 0);
			EX_raddr2	: out STD_LOGIC_VECTOR(3 downto 0);
			EX_imm		: out STD_LOGIC_VECTOR(15 downto 0);
			EX_RPC 		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;
	----------------------------
	--          EX            
	----------------------------
	component ALUSrcMux1
		port(
			-- control signal
			ForwardA	: in STD_LOGIC_VECTOR(1 downto 0);
			-- input
			reg1		: in STD_LOGIC_VECTOR(15 downto 0);
			MEM_ALUResult	: in STD_LOGIC_VECTOR(15 downto 0);
			WB_ALUResult	: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			src1		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component ALUSrcMux2
		port(
			-- control signal
			ForwardB	: in STD_LOGIC_VECTOR(1 downto 0);
			ALUSrcB		: in STD_LOGIC ;
			-- input
			reg2		: in STD_LOGIC_VECTOR(15 downto 0);
			MEM_ALUResult	: in STD_LOGIC_VECTOR(15 downto 0);
			WB_ALUResult	: in STD_LOGIC_VECTOR(15 downto 0);
			imm 		: in STD_LOGIC_VECTOR(15 downto 0) ;
			-- output
			src2		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;
	component WriteMemMux
		port(
			-- control signal
			ForwardWriteMem	: in STD_LOGIC_VECTOR(1 downto 0);
			-- input
			reg2		: in STD_LOGIC_VECTOR(15 downto 0);
			MEM_ALUResult	: in STD_LOGIC_VECTOR(15 downto 0);
			WB_ALUResult	: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			MemWriteData		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;
	component ALU
		port(
			-- input
			src1		: in STD_LOGIC_VECTOR(15 downto 0);
			src2		: in STD_LOGIC_VECTOR(15 downto 0);
			ALUOp		: in STD_LOGIC_VECTOR(3 downto 0);
			-- output
			result		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component ALUResMux
		port(
			-- control signal
			ALURes 		: in STD_LOGIC_VECTOR(1 downto 0);
			-- input 
			ALUResult 	: in STD_LOGIC_VECTOR(15 downto 0);
			PC 			: in STD_LOGIC_VECTOR(15 downto 0);
			RPC 		: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			ALUMuxResult: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component PCImmAdder
		port(
			PCIn		: in STD_LOGIC_VECTOR(15 downto 0);
			imm 		: in STD_LOGIC_VECTOR(15 downto 0);
			PCOut		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	component BranchUnit
		port(
			-- control signal
			ForwardA	: in STD_LOGIC_VECTOR(1 downto 0);
			Branch 		: in STD_LOGIC;
			BranchOp 	: in STD_LOGIC_VECTOR(1 downto 0);
			-- input
			reg1 		: in STD_LOGIC_VECTOR(15 downto 0);
			MEM_ALUResult 	: in STD_LOGIC_VECTOR(15 downto 0);
			WB_ALUResult 	: in STD_LOGIC_VECTOR(15 downto 0);
			-- output
			BranchJudge : out STD_LOGIC
		);
	end component;

	component EXMEMRegister
		port(
			clk 		: in STD_LOGIC;
			rst 		: in STD_LOGIC;
			-- input control signal
			EX_RegDst 	: in STD_LOGIC_VECTOR(3 downto 0);
			EX_MemRead	: in STD_LOGIC;
			EX_MemWrite	: in STD_LOGIC;
			EX_MemToRead: in STD_LOGIC;
			EX_RegWrite : in STD_LOGIC;
			-- input
			EX_ALUResult	: in STD_LOGIC_VECTOR(15 downto 0);
			EX_reg2		: in STD_LOGIC_VECTOR(15 downto 0);
			-- output control signal
			MEM_RegDst 	: out STD_LOGIC_VECTOR(3 downto 0);
			MEM_MemRead	: out STD_LOGIC;
			MEM_MemWrite: out STD_LOGIC;
			MEM_MemToRead: out STD_LOGIC;
			MEM_RegWrite: out STD_LOGIC;
			-- output
			MEM_ALUResult	: out STD_LOGIC_VECTOR(15 downto 0);
			MEM_reg2	: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;
	----------------------------
	--          MEM            
	----------------------------

	component MEMWBRegister 
		port(
			clk 		: in STD_LOGIC;
			rst 		: in STD_LOGIC;
			-- input control signal
			MEM_MemRead : in STD_LOGIC;
			MEM_MemWrite: in STD_LOGIC;
			MEM_RegDst 	: in STD_LOGIC_VECTOR(3 downto 0);
			MEM_MemToRead: in STD_LOGIC;
			MEM_RegWrite: in STD_LOGIC;
			-- input
			MEM_rdata 	: in STD_LOGIC_VECTOR(15 downto 0);
			MEM_ALUResult	: in STD_LOGIC_VECTOR(15 downto 0);
			-- output control signal
			WB_RegDst 	: out STD_LOGIC_VECTOR(3 downto 0);
			WB_MemToRead: out STD_LOGIC;
			WB_LWSW : out STD_LOGIC;
			WB_RegWrite : out STD_LOGIC;
			-- output
			WB_rdata 	: out STD_LOGIC_VECTOR(15 downto 0);
			WB_ALUResult	: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;
	----------------------------
	--          WB            
	----------------------------
	component WriteDataMux
		port(
			-- control signal
			MemToReg: in STD_LOGIC;
			-- input
			rdata 		: in STD_LOGIC_VECTOR(15 downto 0);
			ALUResult	: in STD_LOGIC_VECTOR(15 downto 0);
			-- oiutput
			wdata 		: out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

	----------------------------
	--    External Devices           
	----------------------------

	component VGA_Controller
		port (
			reset		: in  std_logic;
			CLK_in		: in  std_logic;

			-- data
			r0, r1, r2, r3, r4,r5,r6,r7 : in std_logic_vector(15 downto 0);


			PC 			: in std_logic_vector(15 downto 0);
			CM 			: in std_logic_vector(15 downto 0);
			Tdata 		: in std_logic_vector(15 downto 0);
			SPdata 		: in std_logic_vector(15 downto 0);
			IHdata 		: in std_logic_vector(15 downto 0);
			inputcode	: in std_logic_vector(7 downto 0);
			
			-- font rom
			romAddr 	: out std_logic_vector(10 downto 0);
			romData 	: in std_logic_vector(7 downto 0);

			--VGA Side
			hs, vs		: out std_logic;		--锟斤拷同锟斤拷锟斤拷锟斤拷同锟斤拷锟脚猴拷
			oRed		: out std_logic_vector (2 downto 0);
			oGreen		: out std_logic_vector (2 downto 0);
			oBlue		: out std_logic_vector (2 downto 0)
		);		
	end component;
	
	COMPONENT TryDCM
	PORT(
		CLKIN_IN : IN std_logic;
		RST_IN : IN std_logic;          
		CLKFX_OUT : OUT std_logic;
		CLKIN_IBUFG_OUT : OUT std_logic;
		CLK0_OUT : OUT std_logic
		);
	END COMPONENT;

	COMPONENT RstController
	PORT(
		rst: IN std_logic;
		FLASH_FINISH : IN std_logic;          
		rst_out : OUT std_logic
		);
	END COMPONENT;	

	----------------------------
	--         signals            
	----------------------------
	-- Clock
--	signal clk0 		: STD_LOGIC;
--	signal clk1 		: STD_LOGIC;
--	signal clk2 		: STD_LOGIC;
--	signal clk3 		: STD_LOGIC;

	-- Controller
	signal RegSrcA		: STD_LOGIC_VECTOR(3 downto 0);
	signal RegSrcB		: STD_LOGIC_VECTOR(3 downto 0);
	signal ImmSrc 		: STD_LOGIC_VECTOR(2 downto 0);
	signal ExtendOp 	: STD_LOGIC;
	signal RegDst 		: STD_LOGIC_VECTOR(3 downto 0);
	signal ALUOp 		: STD_LOGIC_VECTOR(3 downto 0);
	signal ALUSrcB 	: STD_LOGIC;
	signal ALURes 		: STD_LOGIC_VECTOR(1 downto 0);
	signal Jump 		: STD_LOGIC;
	signal BranchOp 	: STD_LOGIC_VECTOR(1 downto 0);
	signal Branch 		: STD_LOGIC;
	signal MemRead 		: STD_LOGIC;
	signal MemWrite 	: STD_LOGIC;
	signal MemToReg 	: STD_LOGIC;
	signal RegWrite 	: STD_LOGIC;

	-- ForwardingUnit
	signal ForwardA		: STD_LOGIC_VECTOR(1 downto 0);
	signal ForwardB 	: STD_LOGIC_VECTOR(1 downto 0);
	signal ForwardWriteMem 	: STD_LOGIC_VECTOR(1 downto 0);

	-- HazardDetectionUnit
	signal PCStall 		: STD_LOGIC;
	signal IFIDStall	: STD_LOGIC;
	signal IDEXFlush	: STD_LOGIC;

	-- MemoryUnit
	signal rdata 		: STD_LOGIC_VECTOR(15 downto 0);
	signal IF_inst 		: STD_LOGIC_VECTOR(15 downto 0) ;
	signal EX_isMem	: STD_LOGIC;

	-- PCRegister
	signal IF_PC 	 	: STD_LOGIC_VECTOR(15 downto 0);
	
	-- PCAdder
	signal IF_NPC 		 : STD_LOGIC_VECTOR(15 downto 0);

	-- RPCAdder
	signal IF_RPC 		 : STD_LOGIC_VECTOR(15 downto 0);

	-- PCMux
	signal PCMuxOut 	: STD_LOGIC_VECTOR(15 downto 0);

	-- IFIDRegister
	signal IFIDFlush	: STD_LOGIC ;
	signal ID_PC 		: STD_LOGIC_VECTOR(15 downto 0);
	signal ID_inst		: STD_LOGIC_VECTOR(15 downto 0);
	signal ID_RPC		: STD_LOGIC_VECTOR(15 downto 0);

	-- Registers
	signal ID_reg1 		: STD_LOGIC_VECTOR(15 downto 0);
	signal ID_reg2 		: STD_LOGIC_VECTOR(15 downto 0);

	signal showreg_r0 	: STD_LOGIC_VECTOR(15 downto 0);
	signal showreg_r1 	: STD_LOGIC_VECTOR(15 downto 0);
	signal showreg_r2 	: STD_LOGIC_VECTOR(15 downto 0);
	signal showreg_r3 	: STD_LOGIC_VECTOR(15 downto 0);
	signal showreg_r4 	: STD_LOGIC_VECTOR(15 downto 0);
	signal showreg_r5 	: STD_LOGIC_VECTOR(15 downto 0);
	signal showreg_r6 	: STD_LOGIC_VECTOR(15 downto 0);
	signal showreg_r7 	: STD_LOGIC_VECTOR(15 downto 0);
	signal showreg_T 	: STD_LOGIC_VECTOR(15 downto 0);
	signal showreg_SP 	: STD_LOGIC_VECTOR(15 downto 0);
	signal showreg_IH 	: STD_LOGIC_VECTOR(15 downto 0);
	signal showreg_RA 	: STD_LOGIC_VECTOR(15 downto 0);

	-- ImmUnit
	signal ID_immOut 		: STD_LOGIC_VECTOR(15 downto 0);
--ID_
	-- IDEXRegister
	signal EX_RegDst	: STD_LOGIC_VECTOR(3 downto 0);
	signal EX_ALUOp 	: STD_LOGIC_VECTOR(3 downto 0);
	signal EX_ALUSrcB	: STD_LOGIC;
	signal EX_ALURes 	: STD_LOGIC_VECTOR(1 downto 0);
	signal EX_Jump 		: STD_LOGIC;
	signal EX_BranchOp	: STD_LOGIC_VECTOR(1 downto 0);
	signal EX_Branch 	: STD_LOGIC;
	signal EX_MemRead 	: STD_LOGIC;
	signal EX_MemWrite	: STD_LOGIC;
	signal EX_MemToRead : STD_LOGIC;
	signal EX_RegWrite  : STD_LOGIC;
	signal EX_PC 		: STD_LOGIC_VECTOR(15 downto 0);
	signal EX_reg1 		: STD_LOGIC_VECTOR(15 downto 0);
	signal EX_reg2 		: STD_LOGIC_VECTOR(15 downto 0);
	signal EX_MemWriteData: STD_LOGIC_VECTOR(15 downto 0);
	signal EX_raddr1 	: STD_LOGIC_VECTOR(3 downto 0);
	signal EX_raddr2	: STD_LOGIC_VECTOR(3 downto 0);
	signal EX_imm 		: STD_LOGIC_VECTOR(15 downto 0);
	signal EX_RPC 		: STD_LOGIC_VECTOR(15 downto 0);

	-- ALUSrcMux1
	signal ALUSrc1 		: STD_LOGIC_VECTOR(15 downto 0);

	-- ALUSrcMux2
	signal ALUSrc2 		: STD_LOGIC_VECTOR(15 downto 0);

	-- ALU
	signal ALUResult	: STD_LOGIC_VECTOR(15 downto 0);

	-- ALUResMux
	signal ALUMuxResult	: STD_LOGIC_VECTOR(15 downto 0);

	-- PCImmAdder
	signal EX_PCAddImm	: STD_LOGIC_VECTOR(15 downto 0);

	-- BranchUnit
	signal EX_BranchJudge: STD_LOGIC;

	-- EXMEMRegister
	signal MEM_RegDst 	: STD_LOGIC_VECTOR(3 downto 0);
	signal MEM_MemRead 	: STD_LOGIC;
	signal MEM_MemWrite : STD_LOGIC;
	signal MEM_MemToRead: STD_LOGIC;
	signal MEM_RegWrite : STD_LOGIC;
	signal MEM_ALUResult 	: STD_LOGIC_VECTOR(15 downto 0);
	signal MEM_reg2 	: STD_LOGIC_VECTOR(15 downto 0);

	-- MEMWBRegister
	signal WB_RegDst	: STD_LOGIC_VECTOR(3 downto 0);
	signal WB_MemToRead : STD_LOGIC;
	signal WB_RegWrite 	: STD_LOGIC;
	signal WB_LWSW : STD_LOGIC;
	signal WB_rdata 	: STD_LOGIC_VECTOR(15 downto 0);
	signal WB_ALUResult 	: STD_LOGIC_VECTOR(15 downto 0);

	-- WriteDataMux
	signal WB_wdata 	: STD_LOGIC_VECTOR(15 downto 0);

	-- vga
	signal TryromAddr : std_logic_vector(10 downto 0);
	signal TryromData : std_logic_vector(7 downto 0);
	
	-- ps2
	signal scancode	: std_logic_vector(7 downto 0);
	signal inputcode	: std_logic_vector(7 downto 0);
	
	signal clk : std_logic ;
	signal clk_out : std_logic ;
	signal clk50 : std_logic ;

	signal FLASH_FINISH: STD_LOGIC;
	signal rst_out: STD_LOGIC;

begin

	Inst_HFCLOCK: HFCLOCK PORT MAP(
		CLKIN_IN => clk_board,
		CLKFX_OUT => clk_out,
		CLK0_OUT => clk50
	);

--	u0 : Clock
--	port map(
--		rst 		=> rst,
--		clk 		=> clk,
--		clk0 		=> clk0,
--		clk1 		=> clk1,
--		clk2 		=> clk2,
--		clk3 		=> clk3
--	);
	
	u1 : Controller
	port map(
		rst 		=> rst_out,
		inst 		=> ID_inst,
		RegSrcA		=> RegSrcA,
		RegSrcB 	=> RegSrcB,
		ImmSrc		=> ImmSrc,
		ExtendOp 	=> ExtendOp,
		RegDst 		=> RegDst,
		ALUOp 		=> ALUOp,
		ALUSrcB 	=> ALUSrcB,
		ALURes 		=> ALURes,
		Jump 		=> Jump,
		BranchOp 	=> BranchOp,
		Branch 		=> Branch,
		MemRead 	=> MemRead,
		MemWrite 	=> MemWrite,
		MemToReg 	=> MemToReg,
		RegWrite 	=> RegWrite
	); 

	u2 : ForwardingUnit
	port map(
		rst			=> rst,
		EX_ALUSrcB	=> EX_ALUSrcB,
		EX_MemWrite => EX_MemWrite,
		MEM_RegDst	=> MEM_RegDst,
		WB_RegDst	=> WB_RegDst,
		EX_raddr1 	=> EX_raddr1,
		EX_raddr2	=> EX_raddr2,
		ForwardA	=> ForwardA,
		ForwardB	=> ForwardB,
		ForwardWriteMem => ForwardWriteMem
	);

	u3 : HazardDetectionUnit
	port map(
		EX_MemRead 	=> EX_MemRead,
		EX_RegDst 	=> EX_RegDst,
		raddr1 		=> RegSrcA,
		raddr2 		=> RegSrcB,
		isMem			=> EX_isMem,
		PCStall 		=> PCStall,
		IFIDStall 	=> IFIDStall,
		IDEXFlush 	=> IDEXFlush
	);

	u30 : MemoryUnit
	port map(
		clk 		=> clk,
		rst 		=> rst,
		MemWrite 	=> EX_MemWrite,
		MemRead 	=> EX_MemRead,
		isMem		=> EX_isMem,
		Ram1_OE 	=> Ram1_OE,
		Ram1_WE 	=> Ram1_WE,
		Ram1_EN 	=> Ram1_EN,
		Ram1_Addr 	=> Ram1_Addr,
		Ram1_Data 	=> Ram1_Data,
		addr 		=> ALUMuxResult,
		wdata 		=> EX_MemWriteData,
		rdata 		=> rdata, --HERE was MEM_rdata
		Ram2_OE 	=> Ram2_OE,
		Ram2_WE 	=> Ram2_WE,
		Ram2_EN 	=> Ram2_EN,	
		Ram2_Addr 	=> Ram2_Addr,
		Ram2_Data 	=> Ram2_Data,
		PC 			=> PCMuxOut,
		inst 		=> IF_inst, --HERE was IF_inst, not right
		data_ready 	=> dataReady, 
		tbre 		=> tbre,
		tsre 		=> tsre,
		wrn 		=> wrn,
		rdn 		=> rdn,
		FLASH_ADDR 	=> FLASH_ADDR,
		FLASH_DATA	=> FLASH_DATA,
		FLASH_BYTE	=> FLASH_BYTE,
		FLASH_VPEN	=> FLASH_VPEN,
		FLASH_RP		=> FLASH_RP,
		FLASH_CE		=> FLASH_CE,
		FLASH_OE		=> FLASH_OE,
		FLASH_WE		=> FLASH_WE,
		FLASH_FINISH => FLASH_FINISH
	);

	u4 : PCRegister
	port map(
		clk 		=> clk,
		rst 		=> rst_out,
		PCIn 		=> PCMuxOut,
		PCOut 	=> IF_PC
	);

	u5 : PCAdder
	port map(
		PC			=> IF_PC,
		NPC 		=> IF_NPC
	);

	u6 : RPCAdder
	port map(
		PC 			=> PCMuxOut,
		RPC 		=> IF_RPC
	);

	u7 : PCMux
	port map(
		Jump 		=> EX_Jump,
		BranchJudge => EX_BranchJudge,
		PCStall		=> PCStall,
		PC 			=> IF_PC,
		NPC 		=> IF_NPC,
		PCAddImm 	=> EX_PCAddImm,
		reg1 		=> EX_reg1,
		PCOut 		=> PCMuxOut,
		FLASH_FINISH => FLASH_FINISH
	);

	u9 : IFIDRegister
	port map(
		clk 		=> clk,
		rst 		=> rst_out,
		IFIDStall 	=> IFIDStall,
		IFIDFlush	=> IFIDFlush,
		IF_PC 		=> IF_NPC,
		IF_inst 	=> IF_inst,
		IF_RPC		=> IF_RPC,
		ID_PC		=> ID_PC,
		ID_inst		=> ID_inst,
		ID_RPC 		=> ID_RPC
	);

	u10 : Registers
	port map(
		clk 		=> clk,
		rst 		=> rst_out,
		RegWrite 	=> WB_RegWrite,
		raddr1 		=> RegSrcA,
		raddr2 		=> RegSrcB,
		waddr 		=> WB_RegDst,
		wdata 		=> WB_wdata,
		reg1 		=> ID_reg1, 
		reg2 		=> ID_reg2,
		showreg_r0  => showreg_r0,
		showreg_r1  => showreg_r1,
		showreg_r2  => showreg_r2,
		showreg_r3  => showreg_r3,
		showreg_r4  => showreg_r4,
		showreg_r5  => showreg_r5,
		showreg_r6  => showreg_r6,
		showreg_r7  => showreg_r7,
		showreg_SP  => showreg_SP,
		showreg_IH  => showreg_IH,
		showreg_T  	=> showreg_T,
		showreg_RA  => showreg_RA

	);

	u11 : ImmUnit
	port map(
		ImmSrc 		=> ImmSrc,
		ExtendOp 	=> ExtendOp,
		inst 		=> ID_inst,
		immOut 		=> ID_immOut
	);

	u12 : IDEXRegister
	port map(
		clk 		=> clk,
		rst 		=> rst_out,
		IDEXFlush 	=> IDEXFlush,
		ID_RegDst 	=> RegDst,
		ID_ALUOp 	=> ALUOp,
		ID_ALUSrcB 	=> ALUSrcB,
		ID_ALURes 	=> ALURes,
		ID_Jump 	=> Jump,
		ID_BranchOp => BranchOp,
		ID_Branch 	=> Branch,
		ID_MemRead 	=> MemRead,
		ID_MemWrite => MemWrite,
		ID_MemToRead=> MemToReg,
		ID_RegWrite	=> RegWrite,
		ID_PC 		=> ID_PC,
		ID_reg1		=> ID_reg1,
		ID_reg2 	=> ID_reg2,
		ID_raddr1 	=> RegSrcA, 
		ID_raddr2	=> RegSrcB, 
		ID_imm 		=> ID_immOut,
		ID_RPC 		=> ID_RPC,
		EX_RegDst	=> EX_RegDst,
		EX_ALUOp 	=> EX_ALUOp,
		EX_ALUSrcB  => EX_ALUSrcB,
		EX_ALURes	=> EX_ALURes,
		EX_Jump 	=> EX_Jump,
		EX_BranchOp => EX_BranchOp,
		EX_Branch 	=> EX_Branch,
		EX_MemRead 	=> EX_MemRead,
		EX_MemToRead=> EX_MemToRead,
		EX_RegWrite => EX_RegWrite,
		EX_MemWrite => Ex_MemWrite,
		EX_PC 		=> EX_PC,
		EX_reg1 	=> EX_reg1,
		EX_reg2 	=> EX_reg2,
		EX_raddr1 	=> EX_raddr1,
		EX_raddr2 	=> EX_raddr2,
		EX_imm 		=> EX_imm,
		EX_RPC 		=> EX_RPC
	);

	u13 : ALUSrcMux1
	port map(
		ForwardA		=> ForwardA,
		reg1 			=> EX_reg1,
		MEM_ALUResult	=> MEM_ALUResult,
		WB_ALUResult 	=> WB_wdata,
		src1			=> ALUSrc1
	);

	u14 : ALUSrcMux2
	port map(
		ForwardB 		=> ForwardB,
		ALUSrcB 		=> EX_ALUSrcB,
		reg2 			=> EX_reg2,
		MEM_ALUResult 	=> MEM_ALUResult,
		WB_ALUResult 	=> WB_ALUResult,
		imm 			=> EX_imm,
		src2 			=> ALUSrc2
	);
	
	u145 : WriteMemMux
	port map(
		ForwardWriteMem	=> ForwardWriteMem,
		reg2 			=> EX_reg2,
		MEM_ALUResult	=> MEM_ALUResult,
		WB_ALUResult 	=> WB_wdata,
		MemWriteData	=> EX_MemWriteData
	);

	u15 : ALU
	port map(
		src1 		=> ALUSrc1,
		src2 		=> ALUSrc2,
		ALUOp 		=> EX_ALUOp,
		result 		=> ALUResult
	);

	u16 : ALUResMux
	port map(
		ALURes 		=> EX_ALURes,
		ALUResult 	=> ALUResult,
		PC 			=> EX_PC,
		RPC 		=> EX_RPC,
		ALUMuxResult=> ALUMuxResult
	);

	u17 : PCImmAdder
	port map(
		PCIn		=> EX_PC,
		imm 		=> EX_imm,
		PCOut 		=> EX_PCAddImm
	);

	u18 : BranchUnit
	port map(
		ForwardA 	=> ForwardA,
		Branch 		=> EX_Branch,
		BranchOp 	=> EX_BranchOp,
		reg1 		=> EX_reg1,
		MEM_ALUResult 	=> MEM_ALUResult,
		WB_ALUResult	=> WB_ALUResult,
		BranchJudge => EX_BranchJudge
	);

	u19 : EXMEMRegister
	port map(
		clk 			=> clk,
		rst 			=> rst_out,
		EX_RegDst 		=> EX_RegDst,
		EX_MemRead 		=> EX_MemRead,
		EX_MemWrite 	=> EX_MemWrite,
		EX_MemToRead	=> EX_MemToRead,
		EX_RegWrite 	=> EX_RegWrite,
		EX_ALUResult 	=> ALUMuxResult,
		EX_reg2 		=> EX_MemWriteData,
		MEM_RegDst 		=> MEM_RegDst,
		MEM_MemRead 	=> MEM_MemRead,
		MEM_MemWrite	=> MEM_MemWrite,
		MEM_MemToRead	=>MEM_MemToRead,
		MEM_RegWrite	=> MEM_RegWrite,
		MEM_ALUResult	=> MEM_ALUResult,
		MEM_reg2 		=> MEM_reg2
	);

	u21 : MEMWBRegister
	port map(
		clk 		=> clk,
		rst 		=> rst_out,
		MEM_MemRead 	=> MEM_MemRead,
		MEM_MemWrite	=> MEM_MemWrite,
		MEM_RegDst  => MEM_RegDst,
		MEM_MemToRead=>MEM_MemToRead,
		MEM_RegWrite=> MEM_RegWrite,
		MEM_rdata	=> rdata,
		MEM_ALUResult 	=> MEM_ALUResult,
		WB_LWSW		=> WB_LWSW,
		WB_RegDst	=> WB_RegDst,
		WB_MemToRead=> WB_MemToRead,
		WB_RegWrite => WB_RegWrite,
		WB_rdata 	=> WB_rdata,
		WB_ALUResult	=> WB_ALUResult
	);

	u22 : WriteDataMux
	port map(
		MemToReg 	=> WB_MemToRead,
		rdata 		=> WB_rdata,
		ALUresult 	=> WB_ALUResult,
		wdata 		=> WB_wdata
	);

	u23 : VGA_Controller
	port map(
		reset 		=> rst,
		clk_in 		=> clk50,
		r0 			=> showreg_r0,
		r1 			=> showreg_r1,
		r2 			=> showreg_r2,
		r3 			=> showreg_r3,
		r4 			=> showreg_r4,
		r5 			=> showreg_r5,
		r6 			=> showreg_r6,
		r7 			=> showreg_r7,
		PC 			=> IF_PC,
		CM 			=> IF_inst,
		Tdata 		=> ALUMuxResult,
		SPdata 		=> EX_reg2,
		IHdata 		=> rdata,
		inputcode 	=> inputcode,
		romAddr 	=> TryromAddr,
		romData 	=> TryromData,
		hs 			=> hs,
		vs 			=> vs,
		oRed 		=> redOut,
		oGreen 		=> greenOut,
		oBlue 		=> blueOut
	);
	
	u24 : Tryrom
	port map(
		clka => clk50,
		addra => TryromAddr,
		douta => TryromData
		);
		
	u26 : MemController
	port map(
			MemRead => EX_MemRead,
			MemWrite => EX_MemWrite,
			isMem => EX_isMem
		);
	
	u27: RstController
	port map(
			rst => rst,
			FLASH_FINISH => FLASH_FINISH,
			rst_out => rst_out
		);
		
	Inst_KeyboardDecoder: KeyboardDecoder 
	PORT MAP(
		clk => clk50 ,
		rst => rst ,
		scancode => scancode,
		outputcode => inputcode
	);
	Inst_Keyboard: Keyboard 
	PORT MAP(
		rst => rst,
		clkin => ps_clk,
		datain => ps_data,
		fclk => clk50,
		scancode => scancode
	);
	
	IFIDFlush <= (EX_BranchJudge or EX_Jump) and (not WB_LWSW) ;
	
	process (clk_out,rst,clk_button,clksignal)
	begin
		if rst = '0' then clk <= '0' ;
		elsif clksignal = '0' then clk <= clk_out ;
		else clk <= clk_button ;
		end if ;
	end process ;
	process (EX_RegDst, IF_inst, clk)
	begin
		led(15) <= EX_isMem;
		led(14) <= clk;
		led(13) <= PCStall;
		led(12 downto 8) <= IF_inst(4 downto 0);
		led(7 downto 0) <= inputcode(7 downto 0);
--		led(15 downto 13) <= show1 ;
--		led(12 downto 10) <= show2 ;
--		led(9 downto 7) <= show3 ;
--		led(6) <= hshow ;
--		led(5) <= vshow ;
		--led(15 downto 12) <= RegSrcA(3 downto 0) ;
		--led(11 downto 8) <= RegSrcB(3 downto 0) ;
		--led(7 downto 4) <= ID_immOut(3 downto 0) ;
		--led(3 downto 0) <= ALUMuxResult(3 downto 0) ;
 	end process ;
	
	process (EX_BranchJudge,BranchOp,EX_Jump,ForwardA,ForwardB)
	begin
		showclk(0) <= EX_BranchJudge ;
		showclk(1) <= EX_Jump ;
		showclk(3 downto 2) <= BranchOp ;
		showclk(5 downto 4) <= ForwardA ;
		showclk(6) <= ForwardB(1) or ForwardB(0) ;
	end process ;
	
	
end Behavioral;