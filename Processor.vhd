LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE work.components.all;

ENTITY Processor IS
	GENERIC(
		n : INTEGER := 16;
		addr_size : INTEGER := 3;
		opcode_size : INTEGER := 4;
		imm_size : INTEGER := 6;
		reg_num : INTEGER := 8
	);
	PORT(
		pipe_clock : in std_logic;		 -- IF_ID | ID_DEC | DEC_EX | EX_MEM | MEM_WB + !PC 
		clock : in std_logic;			 -- used by all other units
		regOUT : out std_logic_vector(n*reg_num-1+n downto 0); 	 -- pros othoni (REGs + PC) | 127+16
		instructionAD : out std_logic_vector(n-1 downto 0);	 -- PC_OUT
		instr : in std_logic_vector(n-1 downto 0):= x"0000";	 -- INSTR_MEM_OUT | insrtuction
		dataAD : out std_logic_vector(n-1 downto 0);		 -- DATA_MEM_Address_to_{write|read}
		fromData : in std_logic_vector(n-1 downto 0):= x"0000";	 -- DATA_MEM_OUT | eg. lw..
		toData : out std_logic_vector(n-1 downto 0);		 -- DATA_MEM_IN | eg. sw..
		DataWriteFlag : out std_logic 				 -- DATA_MEM_Write_access
	);
END Processor;

ARCHITECTURE structure OF Processor IS
	-- Fetch use
	signal PCSrc, PCWrite : std_logic;
	signal branch_pc, PCtoIMem, PC_to_IF_ID : std_logic_vector(n-1 downto 0);
	-- IF_ID_Reg
	signal IF_ID_Flush, IF_ID_Write : std_logic;
	signal PC_from_IF_ID, instruction : std_logic_vector(n-1 downto 0);
	-- Decode use
	signal RegWrite : std_logic;
	signal data, rs_data_to_ID_EX, rt_data_to_ID_EX, extended_to_ID_EX : std_logic_vector(n-1 downto 0);
	signal rs_addr_to_ID_EX, rt_addr_to_ID_EX, rd_addr_to_ID_EX : std_logic_vector(addr_size-1 downto 0);
	signal registers : std_logic_vector(n*reg_num-1 downto 0); 
	-- Control use
	signal opcode : std_logic_vector(opcode_size-1 downto 0);
	signal PCSrc_no_use : std_logic;
	signal RegDst_to_ID_EX : std_logic;
	signal ALUop_to_ID_EX : std_logic_vector(1 downto 0);
	signal ALUSrc_to_ID_EX, Branch_to_ID_EX, MemRead_to_ID_EX : std_logic;
	signal MemWrite_to_ID_EX, MemtoReg_to_ID_EX, RegWrite_to_ID_EX : std_logic;
	-- ID_EX_Reg
	signal MemtoReg_from_ID_EX, RegWrite_from_ID_EX : std_logic;
	signal Branch_from_ID_EX, MemRead_from_ID_EX, MemWrite_from_ID_EX : std_logic;
	signal RegDst_from_ID_EX, ALUSrc_from_ID_EX : std_logic;
	signal ALUop_from_ID_EX : std_logic_vector(1 downto 0);
	signal PC_from_ID_EX, rs_data_from_ID_EX, rt_data_from_ID_EX, extended_from_ID_EX : std_logic_vector(n-1 downto 0);
	signal rs_addr_from_ID_EX, rt_addr_from_ID_EX, rd_addr_from_ID_EX : std_logic_vector(addr_size-1 downto 0);
	-- Execute use
	signal ALUresult_to_EX_MEM : std_logic_vector(n-1 downto 0);
	signal MemtoReg_to_EX_MEM, RegWrite_to_EX_MEM : std_logic;
	signal zero_to_EX_MEM, Branch_to_EX_MEM, MemRead_to_EX_MEM, MemWrite_to_EX_MEM : std_logic;
	signal rd_addr_to_EX_MEM : std_logic_vector(addr_size-1 downto 0);
	-- EX_MEM_Reg
	signal MemtoReg_from_EX_MEM, RegWrite_from_EX_MEM : std_logic;
	signal Branch_from_EX_MEM, MemRead_from_EX_MEM, MemWrite_from_EX_MEM : std_logic;
	signal PC_from_EX_MEM, ALUresult_from_EX_MEM, rt_data_from_EX_MEM : std_logic_vector(n-1 downto 0);
	signal zero_from_EX_MEM : std_logic;
	signal rd_addr_from_EX_MEM : std_logic_vector(addr_size-1 downto 0);
	-- WriteBack use
	-- MEM_WB_Reg
	signal data_from_MEM_WB : std_logic_vector(n-1 downto 0);
	signal rd_addr_from_MEM_WB : std_logic_vector(addr_size-1 downto 0);
	signal RegWrite_from_MEM_WB : std_logic;
BEGIN

	FetchStage : Fetch 	generic map(n)
				port map(PCSrc, PCWrite, branch_pc, pipe_clock, instructionAD, PC_to_IF_ID);
	
	IF_ID_Register : Register_IF_ID 	generic map(n)
						port map(PC_to_IF_ID, instr, pipe_clock, IF_ID_Flush, IF_ID_Write, PC_from_IF_ID, instruction);

	DecodeStage : Decode 	generic map(n, addr_size, opcode_size, imm_size, reg_num)
				port map(instruction, PC_from_IF_ID, data, RegWrite, Branch_from_ID_EX, clock,
					 opcode, rs_data_to_ID_EX, rt_data_to_ID_EX, extended_to_ID_EX, branch_pc, 
					 rs_addr_to_ID_EX, rt_addr_to_ID_EX, rd_addr_to_ID_EX, PCSrc, registers);
	regOUT <= registers & PC_to_IF_ID;

	ControlUnits : Controls generic map(n, addr_size, opcode_size)
				port map(instruction, rt_addr_from_ID_EX, MemRead_from_ID_EX, clock, 
					 PCWrite, PCSrc_no_use, IF_ID_Write, 
					 RegDst_to_ID_EX, ALUop_to_ID_EX, ALUSrc_to_ID_EX, 
					 Branch_to_ID_EX, MemRead_to_ID_EX, MemWrite_to_ID_EX,
					 MemtoReg_to_ID_EX, RegWrite_to_ID_EX);

	ID_EX_Register : Register_ID_EX		generic map(n, addr_size)
						port map(MemtoReg_to_ID_EX, RegWrite_to_ID_EX,
							 Branch_to_ID_EX, MemRead_to_ID_EX, MemWrite_to_ID_EX,
							 RegDst_to_ID_EX, ALUop_to_ID_EX, ALUSrc_to_ID_EX,
							 PC_from_IF_ID, rs_data_to_ID_EX, rt_data_to_ID_EX, extended_to_ID_EX, 
							 rs_addr_to_ID_EX, rt_addr_to_ID_EX, rd_addr_to_ID_EX, pipe_clock,
							 MemtoReg_from_ID_EX, RegWrite_from_ID_EX,
							 Branch_from_ID_EX, MemRead_from_ID_EX, MemWrite_from_ID_EX,
							 RegDst_from_ID_EX, ALUop_from_ID_EX, ALUSrc_from_ID_EX,
							 PC_from_ID_EX, rs_data_from_ID_EX, rt_data_from_ID_EX, extended_from_ID_EX,
							 rs_addr_from_ID_EX, rt_addr_from_ID_EX, rd_addr_from_ID_EX);

	ExecuteStage : Execute 	generic map(n, addr_size)
				port map(ALUop_from_ID_EX, ALUSrc_from_ID_EX, RegDst_from_ID_EX, 
					 MemtoReg_from_ID_EX, RegWrite_from_ID_EX, 
					 Branch_from_ID_EX, MemRead_from_ID_EX, MemWrite_from_ID_EX, 
					 extended_from_ID_EX, rs_data_from_ID_EX, rt_data_from_ID_EX,
					 ALUresult_from_EX_MEM, data_from_MEM_WB, 
					 rs_addr_from_ID_EX, rt_addr_from_ID_EX, rd_addr_from_ID_EX, 
					 rd_addr_from_EX_MEM, rd_addr_from_MEM_WB, 
					 RegWrite_from_EX_MEM, RegWrite_from_MEM_WB, clock,
					 zero_to_EX_MEM, ALUresult_to_EX_MEM, 
					 MemtoReg_to_EX_MEM, RegWrite_to_EX_MEM, 
					 Branch_to_EX_MEM, MemRead_to_EX_MEM, MemWrite_to_EX_MEM,
					 rd_addr_to_EX_MEM);
		
	EX_MEM_Register : Register_EX_MEM 	generic map(n, addr_size)
						port map(MemtoReg_to_EX_MEM, RegWrite_to_EX_MEM, 
							 Branch_to_EX_MEM, MemRead_to_EX_MEM, MemWrite_to_EX_MEM,
							 PC_from_ID_EX, ALUresult_to_EX_MEM, zero_to_EX_MEM, 
							 rt_data_from_ID_EX, rd_addr_to_EX_MEM, clock, 
							 MemtoReg_from_EX_MEM, RegWrite_from_EX_MEM,
							 Branch_from_EX_MEM, MemRead_from_EX_MEM, MemWrite_from_EX_MEM,
							 PC_from_EX_MEM, ALUresult_from_EX_MEM, zero_from_EX_MEM, 
							 rt_data_from_EX_MEM, rd_addr_from_EX_MEM);

	-- MemStage ? etc

--	MEM_WB_Register : Register_MEM_WB	generic map()
--						port map();
END structure;

