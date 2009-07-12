LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE work.components.all;

ENTITY Decode IS
	GENERIC(
		n : INTEGER := 16;
		addr_size : INTEGER := 3;
		opcode_size : INTEGER := 4;
		imm_size : INTEGER := 6
	);
	PORT(
		instruction, IF_ID_PC, data : in std_logic_vector(n-1 downto 0);
		RegWrite, isBranch, clock : in std_logic;
		opcode : out std_logic_vector(opcode_size-1 downto 0);
		ID_EX_rs_data, ID_EX_rt_data, ID_EX_extended, branch_pc : out std_logic_vector(n-1 downto 0);
		ID_EX_rd_addr : out std_logic_vector(addr_size-1 downto 0);
		PCSrc : out std_logic
	);
END Decode;


ARCHITECTURE struct OF Decode IS
	signal rs_addr, rt_addr, rd_addr : std_logic_vector(addr_size-1 downto 0);
	signal imm : std_logic_vector(imm_size-1 downto 0);
	signal rs_data, rt_data, extended, shifted : std_logic_vector(n-1 downto 0);
	signal equal, branch_carry : std_logic;
BEGIN
	opcode <= instruction(n-1 downto n-opcode_size);
	rd_addr <= instruction(n-opcode_size-1 downto n-opcode_size-addr_size);
	rs_addr <= instruction(n-opcode_size-addr_size-1 downto n-opcode_size-2*addr_size);
	rt_addr <= instruction(n-opcode_size-2*addr_size-1 downto n-opcode_size-3*addr_size);
	imm <= instruction(n-opcode_size-2*addr_size-1 downto 0);

	-- the register file
	Reg_File : RegFile 	generic map(n, addr_size)
				port map(clock, RegWrite, data, rd_addr, rs_addr, rt_addr, rs_data, rt_data);
	
	-- sign extend unit
	sign_extend : sign_ext 	generic map(n, imm_size)
				port map(imm, extended);

	-- shift left logical by 2, align address space
	SLL2 : shift_left_2 	generic map(n)
				port map(extended, shifted);

	-- compare unit, improvement to calculate branch at decode, if read reg's are equal that's zero in ALU
	comparator : compare 	generic map(n)
				port map(rs_data, rt_data, equal);

	-- select if next command is nextPC address, or the new branch_address
	PCSrcDecide : AndGate 	port map(equal, isBranch, PCSrc);
	
	-- Adder to calculate branch address
	BranchAdder : Adder 	generic map(n)
				port map(shifted, IF_ID_PC, branch_carry, branch_pc); 

	-- assign output pins
	ID_EX_rs_data <= rs_data;
	ID_EX_rt_data <= rt_data;
	ID_EX_extended <= extended;
	ID_EX_rd_addr <= rd_addr;
END struct;


-- THIS IS ASCII ART !! Enjoy ;-) 
--   
--   -->--[instruction]---+----[opcode]----->--{_CONTROL_UNIT_}
--                        |                          +------<-------[RegWrite]---<---
--                        |                          |
--                        |                   +-------------+                                       +---<---[isBranch]--<---
--                        +---[rs_addr]--->---|             |--->---[rs_data]--+---[ID_EX_rs_data]  |
--                        |                   |   RegFile   |                  |                    |     +-------------+
--                        +---[rt_addr]--->---|             |          +------------+               +->---|             |
--                        |                   |             |          | comparator |--->---[equal]--->---| PCSrcDecide |--->--[PCSrc]
--                        +---[rd_addr]--->---|             |          +------------+                     +-------------+
--                        |                   |             |                  | 
--                        +---[data]---->-----|             |--->---[rt_data]--+---[ID_EX_rt_data]
--   ---->------[clock]---|--->--------->-----|             |
--                        |                   +-------------+
--                        |
--                        |                  +-------------+
--                        +---[imm]------->--| sign_extend |--->---[extended]--+----[ID_EX_extended]
--                                           +-------------+                   |
--                                                                             |
--                                                                         +------+                  +-------------+
--                                                                         | SLL2 |--->--[shifted]-->| BranchAdder |--->--[branch_pc]
--                                                                         +------+  +--[IF_ID_PC]-->|             |
--                                                                                   |               +-------------+
--                                                                          ---->----+
--

