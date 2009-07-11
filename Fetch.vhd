library ieee;
use ieee.std_logic_1164.all;

USE work.components.all;

entity fetch is
	generic(
		n : INTEGER := 16;
		addr_size : INTEGER := 3;
		opcode_size : INTEGER := 4;
		imm_size : INTEGER := 6
	);
	port(
		PCsrc, updatePC, pipe_clock : in std_logic;
		branch_address : in std_logic_vector(n-1 downto 0);
		PCout : out std_logic_vector(n-1 downto 0)
	);
end fetch;


architecture behav of fetch is
	signal outpc, nextPC, muxPCout : std_logic_vector(n-1 downto 0);
	signal pc_carry : std_logic;
begin
	-- -- ----------- -- --
	-- --    FETCH    -- --
	-- -- ----------- -- --

	-- write to pc or not ?
	PCreg : PC 	generic map (n)
			port map (NOT pipe_clock, updatePC, muxPCout, outpc);
	-- select between PC+4 or Branch_Address
	MUX_2_TO_1 : mux2to1 	generic map(n)
				port map(nextPC, branch_address, PCsrc, muxPCout);
	-- add +4 to current pc
	PC_Adder : Adder 	generic map (n)
				port map (outpc, (n-1 downto 3 => '0') & "100", pc_carry, nextPC);
	PCout <= outpc;
end behav;


