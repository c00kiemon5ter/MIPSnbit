LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE work.components.all;

ENTITY Processor IS
	GENERIC(
		n : INTEGER := 16;
		addr_size : INTEGER := 3;
		opcode_size : INTEGER := 4;
		imm_size : INTEGER := 6
	);
	PORT(
		pipe_clock : in std_logic;		 -- IF_ID | ID_DEC | DEC_EX | EX_MEM | MEM_WB + !PC 
		clock : in std_logic;			 -- used by all other units
		regOUT : out std_logic_vector(n*8-1+n downto 0); 	 -- pros othoni (REGs + PC) | 127+16
		instructionAD : out std_logic_vector(n-1 downto 0);	 -- PC_OUT
		instr : in std_logic_vector(n-1 downto 0):= x"0000";	 -- INSTR_MEM_OUT | insrtuction
		dataAD : out std_logic_vector(n-1 downto 0);		 -- DATA_MEM_Address_to_{write|read}
		fromData : in std_logic_vector(n-1 downto 0):= x"0000";	 -- DATA_MEM_OUT | eg. lw..
		toData : out std_logic_vector(n-1 downto 0);		 -- DATA_MEM_IN | eg. sw..
		DataWriteFlag : out std_logic 				 -- DATA_MEM_Write_access
	);
END Processor;


ARCHITECTURE structure OF Processor IS

component Register_IF_ID is
	generic (
		n : INTEGER := 16
	);
	port (
  		inPC, inInstruction : IN std_logic_vector(n-1 downto 0);
  		clk, IF_Flush, IF_ID_Write : IN std_logic;
  		outPC, outInstruction : OUT std_logic_vector(n-1 downto 0)
	 );
end component;

	signal PCout, nextPC, IF_ID_PC, branch_address, instruction, muxPCout : std_logic_vector(n-1 downto 0);
	signal pc_carry, PCsrc, IF_ID_Write, updatePC : std_logic;
	
	signal write_data, rs_data, rt_data, extnd, shifted : std_logic_vector(n-1 downto 0);
	signal equal, branch_carry : std_logic;
	
	signal RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, PCupdate, reset, flush, ID_EX_MemRead : std_logic;
	signal ID_EX_RT_address : std_logic_vector(addr_size-1 downto 0);
	signal ALUop, fls_wb : std_logic_vector(1 downto 0);
	signal fls_ex : std_logic_vector(3 downto 0);
	signal fls_mem : std_logic_vector(2 downto 0);
BEGIN

	-- -- ----------- -- --
	-- --    FETCH    -- --
	-- -- ----------- -- --

	-- write to pc or not ?
	PCreg : PC 	generic map (n)
			port map (NOT pipe_clock, updatePC, muxPCout, PCout);
	-- select between PC+4 or Branch_Address
	MUX_2_TO_1 : mux2to1 	generic map(n)
				port map(nextPC, branch_address, PCsrc, muxPCout);
	-- add +4 to current pc
	PC_Adder : Adder 	generic map (n)
				port map (PCout, (n-1 downto 3 => '0') & "100", pc_carry, nextPC);
	-- give Instruction_Mem the next PC address to fetch next Instruction(instr)
	instructionAD <= PCout;
	-- store values in IF_ID_Reg
	IF_ID : Register_IF_ID 	generic map(n)
				port map(nextPC, instr, pipe_clock, IF_ID_Write, PCupdate, IF_ID_PC, instruction);
	



	-- -- ------------ -- --
	-- --    DECODE    -- --
	-- -- ------------ -- --
	
	-- our registers
	RegisterFile : RegFile 	generic map(n, addr_size)
				port map(clock, RegWrite, write_data, instruction(n-opcode_size-1 downto n-opcode_size-addr_size), 
								instruction(n-opcode_size-addr_size-1 downto n-opcode_size-2*addr_size), 
								instruction(n-opcode_size-2*addr_size-1 downto n-opcode_size-3*addr_size), 
								rs_data, rt_data);
	-- sign extension for immidiate values
	sing_extension : sign_ext 	generic map(n,imm_size)
					port map(instruction(imm_size-1 downto 0), extnd);
	
	-- NOTE: We could skip the following and use the zero_out from the ALU in 'Execute' stage
	-- NOTE: and be slow, lol, that's weak, we are fast, we are too fast,..
	-- Check if the read-registers' values are the same, that'd be zero in ALU
	comparator : compare 	generic map(n)
				port map(rs_data, rt_data, equal);
	-- select the next command address according to the previous prediction
	PCsrcCheck : AndGate 	port map(equal, fls_mem(2), PCsrc); -- fls_mem(2) is Branch
	-- align the address, shift left logical by two
	SLL2 : shift_left_2 	generic map(n)
				port map(extnd, shifted);
	-- Adder to calculate branch address
	BranchAdder : Adder 	generic map(n)
				port map(shifted, IF_ID_PC, branch_carry, branch_address); 




	-- -- -------------- -- --
	-- --    CONTROLS    -- --
	-- -- -------------- -- --
	
	-- The Control
	ControlUnit : Control 	generic map(opcode_size)
				port map(	instruction(n-1 downto n-opcode_size), 
						RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUop);
	-- Flush Control 
	FlushCtrlUnit : FlushCtrl 	port map(	RegWrite & MemtoReg, 
							Branch & MemRead & MemWrite, 
							RegDst & ALUop & ALUSrc, 
							flush, fls_wb, fls_mem, fls_ex);
	-- Hazard Unit
	HazardUnit : hazard 	port map(	instruction(n-opcode_size-1 downto n-opcode_size-addr_size), 
						instruction(n-opcode_size-addr_size-1 downto n-opcode_size-2*addr_size), 
						ID_EX_RT_Address, Branch, ID_EX_MemRead, reset, clock, 
						updatePC, PCupdate, IF_ID_Write, flush);
	
	
	
	-- -- ------------- -- --
	-- --    EXECUTE    -- --
	-- -- ------------- -- --

END structure;

