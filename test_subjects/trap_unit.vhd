-- KANAKARAKIS IOANNIS p3060190
-- DAGLAS SPUROS p3060190
-- PAPAEUSTATHIOU ANARGUROS p3060131
library ieee;
use ieee.std_logic_1164.all;

entity trap_unit is
	port (
		opcode : in std_logic_vector(3 downto 0);
		wb_in : in std_logic_vector(1 downto 0);
		mem_in : in std_logic_vector (2 downto 0); 
		ex_in : in std_logic_vector(3 downto 0);
		updatePc : out std_logic;
		wb_out : out std_logic_vector(1 downto 0);
		mem_out : out std_logic_vector (2 downto 0); 
		ex_out : out std_logic_vector(3 downto 0)
	);
end trap_unit;


architecture behavior of trap_unit is
	constant EOR : std_logic_vector(3 downto 0) := "0110";
begin
	flush : process(opcode)
	begin
		case opcode is
			when EOR =>
				updatePc <= '0';  -- stop updating pc and flush
				wb_out <= (OTHERS => '0');
				mem_out <= (OTHERS => '0');
				ex_out <= (OTHERS => '0');
			when OTHERS => 
				-- do not interfere 
				updatePc <= '1'; 
				wb_out <= wb_in;
				mem_out <= mem_in;
				ex_out <= ex_in;
		end case;
	end process;
end behavior;

