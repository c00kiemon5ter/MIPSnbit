-- KANAKARAKIS IOANNIS p3060190
-- DAGLAS SPUROS p3060190
-- PAPAEUSTATHIOU ANARGUROS p3060131
library ieee;
use ieee.std_logic_1164.all;
use work.components.mux2to1;
use work.components.mux3to1;

entity selectorB is
	generic ( 
		n : integer := 16 
	);
	port (	
		rt, ex_mem, mem_wb, imm	: in std_logic_vector(n-1 downto 0);
		selB : in std_logic_vector(1 downto 0);
		q : out std_logic_vector(n-1 downto 0)
	);
end selectorB;


architecture behavior of selectorB is
begin
	selecetorB : process(selB)
	begin
		case selB is
			when "00" =>
				q <= rt;
			when "01" =>
				q <= ex_mem;
			when "10" =>
				q <= mem_wb;
			when "11" =>
				q <= imm;
			when OTHERS =>
				q <= (OTHERS => 'U');
		end case;
	end process;
end behavior;

