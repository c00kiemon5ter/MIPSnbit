-- KANAKARAKIS IOANNIS p3060190
-- DAGLAS SPUROS p3060190
-- PAPAEUSTATHIOU ANARGUROS p3060131
library ieee; 
use ieee.std_logic_1164.all;
use work.components.mux3to1;

entity selectorA is
	generic (
		n : integer := 16
	);
	port ( 
		rs, ex_mem, mem_wb : in std_logic_vector(n-1 downto 0);
		selA : in std_logic_vector(1 downto 0);
		q : out std_logic_vector(n-1 downto 0)
	);
end selectorA;


architecture structure of selectorA is
begin
	selectorA : mux3to1 port map (rs, ex_mem, mem_wb, selA, q);
end structure;

