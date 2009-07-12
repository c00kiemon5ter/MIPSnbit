library ieee;
use ieee.std_logic_1164.all;

USE work.components.all;

entity fetch is
	generic(
		n : INTEGER := 16
	);
	port(
		PCSrc, updatePC : in std_logic;
		branch_pc : in std_logic_vector(n-1 downto 0);
		pipe_clock : in std_logic;
		PCtoIMem, PCtoIF_ID : out std_logic_vector(n-1 downto 0)
	);
end fetch;


architecture behav of fetch is
	signal PCval, nextPC, muxPCout : std_logic_vector(n-1 downto 0);
	signal pc_carry : std_logic;
begin
	-- -- ----------- -- --
	-- --    FETCH    -- --
	-- -- ----------- -- --

	-- the pc register
	PCreg : PC 	generic map (n)
			port map (NOT pipe_clock, updatePC, muxPCout, PCval);
	-- select between PC+4(nextPC) or branch address(branch_pc)
	PC_MUX : mux2to1 	generic map(n)
				port map(nextPC, branch_pc, PCSrc, muxPCout);
	-- add +4 to current pc
	PC_adder : Adder 	generic map (n)
				port map (PCval, (n-1 downto 3 => '0') & "100", pc_carry, nextPC);
	PCtoIMem <= PCval;
	PCtoIF_ID <= nextPC;
end behav;


-- THIS IS ASCII ART !! Enjoy ;-) 
--
--   +-----------<------------[branch_pc]-------------<---------------<------------------------{_DECODE_STAGE_} 
--   | +---------------<---------------[nextPC]------------<------------------+
--   | |                                                                      |
--   | |                                                 +----------+         |
--   V |                                           4---->| PC_adder |---->----+---[PCtoIF_ID]-->--{_IF_ID_Reg_}
--   | V                                           +---->|          |
--   | |                                           |     +----------+
--   | |     +---------+                 +-----+   |
--   | +---->|         |---[muxPCout]--->| PC  |---+--[PCval]---->----[PCtoIMem]----->----{_INSTUCTION_MEMORY_}
--   +------>| PC_MUX  |                 | reg |
--           +---------+                 +-----+
--                 |                        |
--                 |                        |
--   --[PCSrc]-->--+                        +-----<-----[updatePC]-------
--

