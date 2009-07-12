LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE work.components.all;

ENTITY Controls IS
	GENERIC(
		n : INTEGER := 16;
		addr_size : INTEGER := 3;
		opcode_size : INTEGER := 4
	);
	PORT(
		instruction : in std_logic_vector(n-1 downto 0);
		ID_EX_rt_addr : in std_logic_vector(addr_size-1 downto 0);
		prev_ID_EX_MemRead, clock : in std_logic;  	-- if previously we had a 'lw' command
		PCWrite, PCSrc, IF_ID_Write : out std_logic;
		ID_EX_RegDst : out std_logic;
		ID_EX_ALUop : out std_logic_vector(1 downto 0);
		ID_EX_ALUSrc, ID_EX_Branch, ID_EX_MemRead, ID_EX_MemWrite, ID_EX_MemtoReg, ID_EX_RegWrite : out std_logic
	);
END Controls;


ARCHITECTURE struct OF Controls IS
	signal opcode : std_logic_vector(opcode_size-1 downto 0);
	signal curr_rs_addr, curr_rt_addr, prev_rt_addr : std_logic_vector(addr_size-1 downto 0);
	signal flush, RegDst, ALUSrc, branch, MemRead, MemWrite, MemtoReg, RegWrite, reset : std_logic;
	signal ALUop : std_logic_vector(1 downto 0);
BEGIN
	opcode <= instruction(n-1 downto n-opcode_size);
	curr_rs_addr <= instruction(n-opcode_size-addr_size-1 downto n-opcode_size-2*addr_size);
	curr_rt_addr <= instruction(n-opcode_size-2*addr_size-1 downto n-opcode_size-3*addr_size);
	
	ControlUnit : Control	generic map(opcode_size)
				port map(opcode, RegDst, ALUop, ALUSrc, branch, MemRead, MemWrite, MemtoReg, RegWrite);
	
	HazardUnit : Hazard 	port map(curr_rs_addr, curr_rt_addr, prev_rt_addr, branch, prev_ID_EX_MemRead, reset, clock,
					PCWrite, PCSrc, IF_ID_Write, flush);

	FlushMux : FlushCtrl 	port map(MemtoReg, RegWrite, branch, MemRead, MemWrite, RegDst, ALUop, ALUSrc, flush, ID_EX_MemtoReg, 
					ID_EX_RegWrite, ID_EX_Branch, ID_EX_MemRead, ID_EX_MemWrite, ID_EX_RegDst, ID_EX_ALUop, ID_EX_ALUSrc);
END struct;


-- hohoho! Play time, who's your dady ?
--
--                                                                  +---------------------->-----------------+
--                                        +---------+               |    +----------+                        |
--  >--[instruction]--->--+---[opcode]--->| CONTROL |--->--[branch]-+->--| FlushMux |--->--[ID_EX_Branch]    |
--                        |               | Unit    |--->--[RegDst]--->--|          |--->--[ID_EX_RegDst]    |
--                        |               |         |--->--[ALUop]---->--|          |--->--[ID_EX_ALUop]     |
--                        |               |         |--->--[ALUSrc]--->--|          |--->--[ID_EX_ALUSrc]    V
--                        |               |         |--->--[MemRead]-->--|          |--->--[ID_EX_MemRead]   |
--                        |               |         |--->--[MemWrite]->--|          |--->--[ID_EX_MemWrite]  |
--                        |               |         |--->--[MemtoReg]->--|          |--->--[ID_EX_MemtoReg]  |
--                        |               |         |--->--[RegWrite]->--|          |--->--[ID_EX_RegWrite]  |
--                        |               +---------+                    +----------+                        |
--                        |                                                    |                             |
--                        |                     +--------+                     +-----<---+                   |
--                        +---[curr_rs_addr]--->|        |--->--[PCWrite]------>         |                   |
--                        |                     | Hazard |--->--[PCSrc]-------->         |                   V
--                        +---[curr_rt_addr]--->| Unit   |--->--[IF_ID_Write]-->         |                   |
--  >--[prev_rt_addr]--------->---------------->|        |                               |                   |
--  >--[prev_ID_EX_MemRead]--->---------------->|        |--->--[flush]-------->---------+                   |
--                    +-->----[branch]--------->|        |                                                   |
--                    |                         +--------+                                                   |
--                    +----------------<------------------<-------------------<--------------------<---------+
--

